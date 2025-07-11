(define (domain eldoria-quest)
    (:requirements :strips :typing :negative-preconditions) ; Use STRIPS, typing, and negation

    (:types
        location character item - object          ; Basic object types
        hero npc - character                       ; Characters: hero and NPCs
        village forest temple - location           ; Locations: village, forest, temple
        key crystal - item                         ; Items: magical key and crystal
    )

    (:predicates
        ; Location predicates
        (at ?obj - object ?loc - location)        ; Object or character is at a location

        ; Item possession predicates
        (has ?char - character ?item - item)      ; Character has an item

        ; Knowledge and status predicates
        (knows-forest-spirit-test ?char - character) ; Hero knows about forest spirit's test
        (has-guidance-from-hunter ?char - character) ; Hero has hunter's guidance
        (has-rumors-about-temple ?char - character)  ; Hero has rumors about temple

        ; Item state predicates
        (magical-key-obtained ?char - character)  ; Hero obtained magical key
        (crystal-lost)                             ; Crystal is lost
        (crystal-visible)                          ; Crystal visible in temple
        (crystal-possessed ?char - character)     ; Hero possesses the Crystal of Light

        ; Location states
        (dark-warden-guards-temple)                ; Dark Warden guards temple
        (dark-warden-weakened)                      ; Dark Warden is weakened
        (dark-warden-defeated)                      ; Dark Warden is defeated

        ; Hero states
        (hero-rested)                               ; Hero has rested
        (hero-in-battle)                            ; Hero is in battle

        ; Environmental states
        (secret-entrance-found)                      ; Secret entrance to temple found
        (at-forest-spirit-glade ?char - character) ; Hero at forest spirit's glade
        (at-temple-entrance ?char - character)      ; Hero at temple entrance
        (inside-temple ?char - character)            ; Hero inside temple
        (injured ?char - character)                    ; Hero injured (minor)
        (distracted)                                 ; Dummy predicate for distract-warden action
    )

    (:action gather-info-elder
        :parameters (?h - hero ?elder - npc ?village - village)
        :precondition (and
            (at ?h ?village)                         ; Hero is in village
            (at ?elder ?village)                     ; Elder is in village
        )
        :effect (and
            (knows-forest-spirit-test ?h)           ; Hero gains knowledge of forest spirit's test
        )
    )

    (:action prepare-and-set-out
        :parameters (?h - hero ?from - location ?to - location)
        :precondition (and
            (at ?h ?from)                           ; Hero at starting location
        )
        :effect (and
            (at ?h ?to)                            ; Hero moves to Whispering Forest
            (not (at ?h ?from))                    ; Hero leaves previous location
            (hero-rested)                          ; Hero has prepared/rested
        )
    )

    (:action seek-hunter-guidance
        :parameters (?h - hero ?hunter - npc ?village - village)
        :precondition (and
            (at ?h ?village)                       ; Hero in village
            (at ?hunter ?village)                  ; Hunter in village
        )
        :effect (and
            (has-guidance-from-hunter ?h)          ; Hero gains hunter's guidance
        )
    )

    (:action talk-to-villager
        :parameters (?h - hero ?villager - npc ?village - village)
        :precondition (and
            (at ?h ?village)                       ; Hero in village
            (at ?villager ?village)               ; Villager in village
        )
        :effect (and
            (has-rumors-about-temple ?h)           ; Hero gains rumors about temple
        )
    )

    (:action seek-forest-spirit-glade
        :parameters (?h - hero ?forest - forest)
        :precondition (and
            (at ?h ?forest)                        ; Hero in Whispering Forest
        )
        :effect (and
            (at-forest-spirit-glade ?h)            ; Hero at forest spirit's glade
            (not (at ?h ?forest))
        )
    )

    (:action explore-deeper-forest
        :parameters (?h - hero ?forest - forest)
        :precondition (and
            (at ?h ?forest)                        ; Hero in Whispering Forest
        )
        :effect (and
            (injured ?h)                          ; Hero gets injured exploring deeper
        )
    )

    (:action follow-animal-tracks
        :parameters (?h - hero ?forest - forest)
        :precondition (and
            (at ?h ?forest)                        ; Hero in Whispering Forest
        )
        :effect (and
            (secret-entrance-found)                ; Following tracks leads to secret entrance found
        )
    )

    (:action rest
        :parameters (?h - hero ?loc - location)
        :precondition (and
            (at ?h ?loc)                          ; Hero at some location
        )
        :effect (and
            (hero-rested)                         ; Hero has rested
            (not (injured ?h))                    ; Hero recovers from injury if any
        )
    )

    (:action accept-test
        :parameters (?h - hero)
        :precondition (and
            (at-forest-spirit-glade ?h)           ; Hero at forest spirit's glade
            (not (magical-key-obtained ?h))       ; Hero does not have key yet
        )
        :effect (and
            (magical-key-obtained ?h)              ; Hero obtains magical key
        )
    )

    (:action injured-explore-forest
        :parameters (?h - hero ?forest - forest)
        :precondition (and
            (at ?h ?forest)
            (injured ?h)
        )
        :effect (and
            (at-forest-spirit-glade ?h)
            (not (at ?h ?forest))
        )
    )

    (:action proceed-temple-entrance
        :parameters (?h - hero ?forest - forest ?temple - temple)
        :precondition (and
            (magical-key-obtained ?h)
            (at ?h ?forest)
            (secret-entrance-found)
        )
        :effect (and
            (at-temple-entrance ?h)
            (not (at ?h ?forest))
            (at ?h ?temple)
        )
    )

    (:action leave-forest-spirit-glade
        :parameters (?h - hero ?forest - forest)
        :precondition (and
            (at-forest-spirit-glade ?h)
        )
        :effect (and
            (at ?h ?forest)
            (not (at-forest-spirit-glade ?h))
        )
    )

    (:action leave-temple-entrance
        :parameters (?h - hero ?temple - temple)
        :precondition (and
            (at-temple-entrance ?h)
        )
        :effect (and
            (at ?h ?temple)
            (not (at-temple-entrance ?h))
        )
    )

    (:action enter-temple
        :parameters (?h - hero ?temple - temple ?warden - npc)
        :precondition (and
            (at-temple-entrance ?h)
            (magical-key-obtained ?h)
            (dark-warden-guards-temple)
            (at ?warden ?temple)
        )
        :effect (and
            (inside-temple ?h)
            (hero-in-battle)
            (not (dark-warden-guards-temple))
            (not (at-temple-entrance ?h))
            (not (at ?h ?temple))
        )
    )

    (:action scout-temple-perimeter
        :parameters (?h - hero ?temple - temple)
        :precondition (and
            (at-temple-entrance ?h)
            (magical-key-obtained ?h)
        )
        :effect (and
            (secret-entrance-found)
        )
    )

    (:action call-out-warden
        :parameters (?h - hero ?temple - temple ?warden - npc)
        :precondition (and
            (at-temple-entrance ?h)
            (dark-warden-guards-temple)
            (magical-key-obtained ?h)
            (at ?warden ?temple)
        )
        :effect (and
            (dark-warden-weakened)
        )
    )

    (:action rest-before-battle
        :parameters (?h - hero ?loc - location)
        :precondition (and
            (or (at-temple-entrance ?h) (secret-entrance-found))
            (magical-key-obtained ?h)
        )
        :effect (and
            (hero-rested)
        )
    )

    (:action use-key-power
        :parameters (?h - hero)
        :precondition (and
            (hero-in-battle)
            (magical-key-obtained ?h)
            (not (dark-warden-weakened))
        )
        :effect (and
            (dark-warden-weakened)
        )
    )

    (:action direct-combat
        :parameters (?h - hero)
        :precondition (and
            (hero-in-battle)
            (not (dark-warden-defeated))
        )
        :effect (and
            (dark-warden-defeated)
            (not (hero-in-battle))
        )
    )

    (:action dodge-and-search-crystal
        :parameters (?h - hero)
        :precondition (and
            (hero-in-battle)
            (not (crystal-visible))
        )
        :effect (and
            (crystal-visible)
            (not (crystal-lost))
        )
    )

    (:action enter-secret-entrance
        :parameters (?h - hero ?temple - temple)
        :precondition (and
            (secret-entrance-found)
            (magical-key-obtained ?h)
            (at ?h ?temple)
        )
        :effect (and
            (inside-temple ?h)
            (hero-in-battle)
            (not (at ?h ?temple))
        )
    )

    (:action rush-grab-crystal
        :parameters (?h - hero)
        :precondition (and
            (hero-in-battle)
            (crystal-visible)
            (not (crystal-possessed ?h))
            (inside-temple ?h)
        )
        :effect (and
            (crystal-possessed ?h)
            (dark-warden-defeated)
            (not (hero-in-battle))
            (not (crystal-lost))
        )
    )

    (:action distract-warden
        :parameters (?h - hero)
        :precondition (and
            (hero-in-battle)
            (dark-warden-weakened)
            (not (dark-warden-defeated))
        )
        :effect (and
            (distracted)
        )
    )

    (:action disarm-warden
        :parameters (?h - hero)
        :precondition (and
            (hero-in-battle)
            (dark-warden-weakened)
            (not (dark-warden-defeated))
        )
        :effect (and
            (dark-warden-defeated)
            (not (hero-in-battle))
        )
    )

    (:action take-crystal
        :parameters (?h - hero)
        :precondition (and
            (dark-warden-defeated)
            (not (crystal-possessed ?h))
            (crystal-visible)
            (inside-temple ?h)
        )
        :effect (and
            (crystal-possessed ?h)
            (not (crystal-lost))
        )
    )
)

