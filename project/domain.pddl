(define (domain quest-domain)
    (:requirements :strips :typing)
    (:types
        location character item obstacle reputation - object ; Define object types
    )
    (:predicates
        (at ?c - character ?l - location)                          ; Character is at location
        (has ?c - character ?i - item)                            ; Character has item
        (guarding ?o - obstacle ?l - location)                    ; Obstacle guards location
        (disposition-known ?sp - character)                       ; Forest spirit disposition known
        (charm-of-protection ?c - character)                      ; Character has charm of protection
        (reputation-kindness ?c - character)                      ; Character has kindness reputation
        (reputation-courage ?c - character)                       ; Character has courage reputation
        (wounded ?c - character)                                  ; Character is wounded or discouraged
        (rested ?c - character)                                   ; Character is rested and focused
        (key-held ?c - character)                                 ; Character possesses magical key
        (crystal-lost)                                            ; Crystal of Light is lost
        (crystal-possessed ?c - character)                        ; Character possesses Crystal of Light
        (warden-defeated)                                         ; Dark Warden defeated
        (warden-present ?o - obstacle ?l - location)              ; Dark Warden present at location
        (spirit-present ?l - location)                            ; Forest spirit present at location
        (traps-set ?c - character)                                ; Character has set traps or noted strategic points
        (kingdom-saved)                                           ; Kingdom of Eldoria saved
        (charm-possessed ?c - character)                          ; Character has charm (alias for clarity)
    )

    ;; Section 1 Actions
    (:action seek-village-elder-guidance
        :parameters (?hero - character ?village - location ?elder-hut - location ?warden - obstacle ?temple - location ?forest-spirit - character)
        :precondition (and (at ?hero ?village) (crystal-lost) (guarding ?warden ?temple))
        :effect (and
            (not (at ?hero ?village))                              ; Hero leaves village
            (at ?hero ?elder-hut)                                  ; Hero at elder's hut
            (charm-of-protection ?hero)                            ; Hero gains charm of protection
            (disposition-known ?forest-spirit)                     ; Forest spirit disposition known
        )
    )

    (:action head-directly-to-whispering-forest
        :parameters (?hero - character ?village - location ?forest - location ?warden - obstacle ?temple - location ?sword - item ?shield - item)
        :precondition (and (at ?hero ?village) (crystal-lost) (guarding ?warden ?temple))
        :effect (and
            (not (at ?hero ?village))                              ; Hero leaves village
            (at ?hero ?forest)                                     ; Hero at Whispering Forest
            (not (charm-of-protection ?hero))                      ; No charm
            (not (has ?hero ?sword))                                ; No weapons
            (not (has ?hero ?shield))
            (spirit-present ?forest)                               ; Forest spirit present
        )
    )

    (:action visit-blacksmith
        :parameters (?hero - character ?village - location ?blacksmith - location ?warden - obstacle ?temple - location ?sword - item ?shield - item)
        :precondition (and (at ?hero ?village) (crystal-lost) (guarding ?warden ?temple))
        :effect (and
            (not (at ?hero ?village))                              ; Hero leaves village
            (at ?hero ?blacksmith)                                 ; Hero at blacksmith
            (has ?hero ?sword)                                      ; Hero gains sword
            (has ?hero ?shield)                                     ; Hero gains shield
        )
    )

    ;; Section 2 Actions
    (:action enter-forest-with-charm
        :parameters (?hero - character ?elder-hut - location ?forest - location ?forest-spirit - character)
        :precondition (and (at ?hero ?elder-hut) (charm-of-protection ?hero) (disposition-known ?forest-spirit))
        :effect (and
            (not (at ?hero ?elder-hut))                            ; Hero leaves elder hut
            (at ?hero ?forest)                                     ; Hero at Whispering Forest
            (spirit-present ?forest)                               ; Forest spirit present
        )
    )

    (:action train-with-villagers
        :parameters (?hero - character ?elder-hut - location ?village - location)
        :precondition (and (at ?hero ?elder-hut) (charm-of-protection ?hero))
        :effect (and
            (not (at ?hero ?elder-hut))                            ; Hero leaves elder hut
            (at ?hero ?village)                                    ; Hero at village
            (reputation-kindness ?hero)                            ; Kindness enhanced
            (reputation-courage ?hero)                             ; Courage enhanced
            (charm-of-protection ?hero)                            ; Retain charm
        )
    )

    ;; Section 3 Actions
    (:action answer-honestly-to-spirit
        :parameters (?hero - character ?forest - location ?temple-entrance - location ?sword - item ?shield - item)
        :precondition (and (at ?hero ?forest) (spirit-present ?forest) (not (charm-of-protection ?hero)) (not (has ?hero ?sword)) (not (has ?hero ?shield)))
        :effect (and
            (not (at ?hero ?forest))                               ; Hero leaves forest
            (at ?hero ?temple-entrance)                            ; Hero before temple entrance
            (key-held ?hero)                                       ; Hero gains magical key
        )
    )

    (:action intimidate-spirit
        :parameters (?hero - character ?forest - location ?edge-forest - location)
        :precondition (and (at ?hero ?forest) (spirit-present ?forest))
        :effect (and
            (not (at ?hero ?forest))                               ; Hero cast out
            (at ?hero ?edge-forest)                                ; Hero at forest edge
            (wounded ?hero)                                        ; Hero wounded or discouraged
        )
    )

    ;; Section 4 Actions
    (:action venture-into-forest-armed
        :parameters (?hero - character ?blacksmith - location ?forest - location ?sword - item ?shield - item)
        :precondition (and (at ?hero ?blacksmith) (has ?hero ?sword) (has ?hero ?shield))
        :effect (and
            (not (at ?hero ?blacksmith))                           ; Hero leaves blacksmith
            (at ?hero ?forest)                                     ; Hero at Whispering Forest
            (spirit-present ?forest)                               ; Forest spirit present
        )
    )

    (:action seek-elder-guidance-from-blacksmith
        :parameters (?hero - character ?blacksmith - location ?elder-hut - location ?forest-spirit - character)
        :precondition (and (at ?hero ?blacksmith))
        :effect (and
            (not (at ?hero ?blacksmith))                           ; Hero leaves blacksmith
            (at ?hero ?elder-hut)                                  ; Hero at elder's hut
            (charm-of-protection ?hero)                            ; Hero gains charm
            (disposition-known ?forest-spirit)                     ; Forest spirit disposition known
        )
    )

    ;; Section 5 Actions
    (:action offer-help-to-forest-creature
        :parameters (?hero - character ?forest - location ?temple-entrance - location ?sword - item ?shield - item)
        :precondition (and (at ?hero ?forest) (spirit-present ?forest) (or (charm-of-protection ?hero) (has ?hero ?sword) (has ?hero ?shield)))
        :effect (and
            (not (at ?hero ?forest))                               ; Hero leaves forest
            (at ?hero ?temple-entrance)                            ; Hero near temple entrance
            (key-held ?hero)                                       ; Hero gains magical key
        )
    )

    (:action speak-truthfully-to-spirit
        :parameters (?hero - character ?forest - location ?temple-entrance - location ?sword - item ?shield - item)
        :precondition (and (at ?hero ?forest) (spirit-present ?forest) (or (charm-of-protection ?hero) (has ?hero ?sword) (has ?hero ?shield)))
        :effect (and
            (not (at ?hero ?forest))                               ; Hero leaves forest
            (at ?hero ?temple-entrance)                            ; Hero near temple entrance
            (key-held ?hero)                                       ; Hero gains magical key
        )
    )

    (:action attempt-persuasion
        :parameters (?hero - character ?forest - location ?edge-forest - location)
        :precondition (and (at ?hero ?forest) (spirit-present ?forest))
        :effect (and
            (not (at ?hero ?forest))                               ; Hero cast out
            (at ?hero ?edge-forest)                                ; Hero at forest edge
            (wounded ?hero)                                        ; Hero wounded or discouraged
        )
    )

    ;; Section 6 Actions
    (:action enter-forest-with-virtues
        :parameters (?hero - character ?village - location ?forest - location)
        :precondition (and (at ?hero ?village) (reputation-kindness ?hero) (reputation-courage ?hero) (charm-of-protection ?hero))
        :effect (and
            (not (at ?hero ?village))                              ; Hero leaves village
            (at ?hero ?forest)                                     ; Hero at Whispering Forest
            (spirit-present ?forest)                               ; Forest spirit present
        )
    )

    (:action delay-to-train-more
        :parameters (?hero - character ?village - location)
        :precondition (and (at ?hero ?village) (reputation-kindness ?hero) (reputation-courage ?hero))
        :effect (and
            (reputation-kindness ?hero)                            ; Kindness enhanced further (idempotent)
            (reputation-courage ?hero)                             ; Courage enhanced further (idempotent)
        )
    )

    ;; Section 7 Actions
    (:action enter-temple-with-key
        :parameters (?hero - character ?temple-entrance - location ?temple - location ?warden - obstacle)
        :precondition (and (at ?hero ?temple-entrance) (key-held ?hero) (crystal-lost))
        :effect (and
            (not (at ?hero ?temple-entrance))                      ; Hero enters temple
            (at ?hero ?temple)                                     ; Hero inside temple
            (warden-present ?warden ?temple)                       ; Dark Warden present
        )
    )

    (:action rest-before-temple
        :parameters (?hero - character ?temple-entrance - location)
        :precondition (and (at ?hero ?temple-entrance) (key-held ?hero))
        :effect (rested ?hero)                                      ; Hero rested and focused
    )

    ;; Section 8 Actions
    (:action regroup-after-failure
        :parameters (?hero - character ?edge-forest - location ?elder-hut - location ?forest-spirit - character)
        :precondition (and (at ?hero ?edge-forest) (wounded ?hero))
        :effect (and
            (not (at ?hero ?edge-forest))                           ; Hero leaves forest edge
            (at ?hero ?elder-hut)                                   ; Hero at elder's hut
            (charm-of-protection ?hero)                             ; Hero gains charm
            (disposition-known ?forest-spirit)                      ; Forest spirit disposition known
            (not (wounded ?hero))                                   ; Hero recovers
        )
    )

    (:action try-enter-forest-humbly
        :parameters (?hero - character ?edge-forest - location ?forest - location)
        :precondition (and (at ?hero ?edge-forest) (wounded ?hero))
        :effect (and
            (not (at ?hero ?edge-forest))                           ; Hero leaves forest edge
            (at ?hero ?forest)                                      ; Hero at Whispering Forest
            (spirit-present ?forest)                                ; Forest spirit present
            (not (wounded ?hero))                                   ; Hero recovers
        )
    )

    ;; Section 9 Actions
    (:action use-key-to-enter-temple
        :parameters (?hero - character ?temple-entrance - location ?temple - location ?warden - obstacle)
        :precondition (and (at ?hero ?temple-entrance) (key-held ?hero))
        :effect (and
            (not (at ?hero ?temple-entrance))                       ; Hero enters temple
            (at ?hero ?temple)                                      ; Hero inside temple
            (warden-present ?warden ?temple)                        ; Dark Warden present
        )
    )

    (:action scout-temple-perimeter
        :parameters (?hero - character ?temple-perimeter - location)
        :precondition (and (at ?hero ?temple-perimeter) (key-held ?hero))
        :effect (traps-set ?hero)                                   ; Hero has set traps or noted strategic points
    )

    ;; Section 10 Actions
    (:action enter-temple
        :parameters (?hero - character ?temple-perimeter - location ?temple - location ?warden - obstacle)
        :precondition (and (at ?hero ?temple-perimeter) (key-held ?hero))
        :effect (and
            (not (at ?hero ?temple-perimeter))                      ; Hero enters temple
            (at ?hero ?temple)                                      ; Hero inside temple
            (warden-present ?warden ?temple)                        ; Dark Warden present
        )
    )

    (:action set-traps-inside-temple
        :parameters (?hero - character ?warden - obstacle ?temple - location)
        :precondition (and (warden-present ?warden ?temple) (key-held ?hero) (at ?hero ?temple))
        :effect (traps-set ?hero)                                   ; Hero has set traps or noted strategic points
    )

    ;; Section 11 Actions
    (:action enter-forest-now
        :parameters (?hero - character ?village - location ?forest - location)
        :precondition (and (at ?hero ?village) (reputation-kindness ?hero) (reputation-courage ?hero))
        :effect (and
            (not (at ?hero ?village))                               ; Hero leaves village
            (at ?hero ?forest)                                      ; Hero at Whispering Forest
            (spirit-present ?forest)                                ; Forest spirit present
        )
    )

    (:action prepare-weapons-before-forest
        :parameters (?hero - character ?village - location ?blacksmith - location ?sword - item ?shield - item)
        :precondition (at ?hero ?village)
        :effect (and
            (not (at ?hero ?village))                               ; Hero leaves village
            (at ?hero ?blacksmith)                                  ; Hero at blacksmith
            (has ?hero ?sword)                                       ; Hero gains sword
            (has ?hero ?shield)                                      ; Hero gains shield
        )
    )

    ;; Section 12 Actions
    (:action engage-dark-warden-combat
        :parameters (?hero - character ?temple - location ?warden - obstacle)
        :precondition (and (at ?hero ?temple) (warden-present ?warden ?temple) (key-held ?hero))
        :effect (and
            (warden-defeated)                                       ; Dark Warden defeated
        )
    )

    (:action use-surroundings-for-advantage
        :parameters (?hero - character ?temple-perimeter - location)
        :precondition (and (at ?hero ?temple-perimeter) (key-held ?hero))
        :effect (traps-set ?hero)                                   ; Hero has set traps or noted strategic points
    )

    ;; Section 13 Actions
    (:action enter-temple-now
        :parameters (?hero - character ?alcove - location ?temple - location ?warden - obstacle)
        :precondition (and (at ?hero ?alcove) (rested ?hero) (key-held ?hero))
        :effect (and
            (not (at ?hero ?alcove))                                ; Hero leaves alcove
            (at ?hero ?temple)                                      ; Hero inside temple
            (warden-present ?warden ?temple)                        ; Dark Warden present
        )
    )

    (:action scout-temple-perimeter-from-alcove
        :parameters (?hero - character ?alcove - location ?temple-perimeter - location)
        :precondition (and (at ?hero ?alcove) (key-held ?hero))
        :effect (and
            (not (at ?hero ?alcove))                                ; Hero leaves alcove
            (at ?hero ?temple-perimeter)                            ; Hero at temple perimeter
            (traps-set ?hero)                                       ; Hero has set traps or noted strategic points
        )
    )

    ;; Section 14 Actions
    (:action ambush-dark-warden
        :parameters (?hero - character ?temple - location ?warden - obstacle)
        :precondition (and (at ?hero ?temple) (warden-present ?warden ?temple) (traps-set ?hero) (key-held ?hero))
        :effect (and
            (warden-defeated)                                       ; Dark Warden defeated
        )
    )

    (:action direct-confrontation
        :parameters (?hero - character ?temple - location ?warden - obstacle)
        :precondition (and (at ?hero ?temple) (warden-present ?warden ?temple) (key-held ?hero))
        :effect (and
            (warden-defeated)                                       ; Dark Warden defeated
        )
    )

    ;; Section 15 Actions
    (:action claim-crystal-and-exit
        :parameters (?hero - character ?temple - location ?village - location)
        :precondition (and (at ?hero ?temple) (warden-defeated))
        :effect (and
            (not (at ?hero ?temple))                                ; Hero leaves temple
            (at ?hero ?village)                                     ; Hero returns to village
            (crystal-possessed ?hero)                               ; Hero possesses Crystal of Light
            (kingdom-saved)                                         ; Kingdom saved
        )
    )

    ;; Section 17 Actions
    (:action celebrate-victory
        :parameters (?hero - character ?village - location)
        :precondition (and (at ?hero ?village) (crystal-possessed ?hero) (warden-defeated) (kingdom-saved))
        :effect (and)                                              ; End of quest (success), no effect
    )

    ;; Section 18 Actions
    (:action accept-defeat
        :parameters (?hero - character ?loc - location)
        :precondition (and (at ?hero ?loc) (not (key-held ?hero)) (not (crystal-possessed ?hero)) (not (warden-defeated)))
        :effect (and)                                              ; End of quest (failure), no effect
    )
)