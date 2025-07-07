(define (domain temple-quest)
    (:requirements :strips :typing :negative-preconditions) ; Use STRIPS, typing, and negation

    (:types
        location character item - object          ; Basic object types
        hero npc - character                      ; Characters: hero and NPCs
        village forest temple - location          ; Location types
        key crystal amulet - item                  ; Item types
    )

    (:predicates
        ; Location predicates
        (at ?c - character ?l - location)         ; Character is at location
        (connected ?l1 - location ?l2 - location) ; Locations are connected (bidirectional)
        
        ; Item possession predicates
        (has ?c - character ?i - item)             ; Character has item
        (item_at ?i - item ?l - location)          ; Item is at location
        
        ; Quest state predicates
        (crystal_possessed)                         ; Hero has the Crystal of Light
        (dark_warden_defeated)                      ; Dark Warden defeated
        (temple_accessible)                         ; Temple is accessible
        (magical_key_possessed)                      ; Hero has magical key
        (forest_spirit_helped)                       ; Forest spirit helped
        (elder_advice_received)                      ; Elder advice received
        (supplies_prepared)                          ; Supplies prepared
        (rested)                                    ; Hero rested
        (trained)                                   ; Hero trained with warriors
        (gift_offered)                              ; Gift offered to forest spirit
        (at_forest_spirit)                          ; Hero is at forest spirit location
        (in_combat_with_spirit)                      ; Hero is fighting forest spirit
        (temple_entrance_found)                      ; Temple entrance found
        (traps_set)                                 ; Traps set in forest
        (merchant_info_received)                     ; Merchant info received
        (map_found)                                 ; Map found
        (amulet_possessed)                           ; Hero has magical amulet
        (amulet_used)                               ; Amulet used
        (prepared_for_battle)                        ; Hero prepared for battle
        (in_battle_with_dark_warden)                 ; Hero fighting Dark Warden
        (negotiation_attempted)                       ; Negotiation attempted with Dark Warden
        (gift_accepted)                              ; Gift accepted by forest spirit
        (alternate_entrance_found)                    ; Alternate temple entrance found
    )

    (:action travel
        :parameters (?c - character ?from - location ?to - location)
        :precondition (and
            (at ?c ?from)                           ; Character is at starting location
            (connected ?from ?to)                   ; Locations are connected
        )
        :effect (and
            (at ?c ?to)                            ; Character moves to destination
            (not (at ?c ?from))                    ; Character leaves origin
        )
    )

    (:action visit_elder
        :parameters (?c - hero ?village - village)
        :precondition (at ?c ?village)
        :effect (and
            (elder_advice_received)                ; Hero receives elder advice
        )
    )

    (:action prepare_supplies
        :parameters (?c - hero ?village - village)
        :precondition (at ?c ?village)
        :effect (and
            (supplies_prepared)                    ; Supplies prepared
        )
    )

    (:action rest
        :parameters (?c - hero ?loc - location)
        :precondition (at ?c ?loc)
        :effect (and
            (rested)                              ; Hero rested
        )
    )

    (:action train_with_warriors
        :parameters (?c - hero ?village - village)
        :precondition (at ?c ?village)
        :effect (and
            (trained)                             ; Hero trained
        )
    )

    (:action search_forest_spirit
        :parameters (?c - hero ?forest - forest)
        :precondition (at ?c ?forest)
        :effect (at_forest_spirit)                 ; Hero found forest spirit
    )

    (:action answer_riddle
        :parameters (?c - hero)
        :precondition (at_forest_spirit)
        :effect (and
            (magical_key_possessed)                ; Hero obtains magical key
            (forest_spirit_helped)                 ; Forest spirit helped
            (not (at_forest_spirit))               ; Leaves forest spirit location
        )
    )

    (:action offer_gift
        :parameters (?c - hero)
        :precondition (at_forest_spirit)
        :effect (gift_offered)                      ; Gift offered to forest spirit
    )

    (:action fight_spirit
        :parameters (?c - hero)
        :precondition (at_forest_spirit)
        :effect (in_combat_with_spirit)             ; Combat initiated with spirit
    )

    (:action defeat_spirit
        :parameters (?c - hero)
        :precondition (in_combat_with_spirit)
        :effect (and
            (magical_key_possessed)                ; Hero obtains magical key
            (not (in_combat_with_spirit))          ; Combat ends
        )
    )

    (:action leave_forest_spirit
        :parameters (?c - hero ?forest - forest)
        :precondition (at_forest_spirit)
        :effect (and
            (not (at_forest_spirit))
            (at ?c ?forest)
        )
    )

    (:action find_temple_entrance
        :parameters (?c - hero ?forest - forest)
        :precondition (at ?c ?forest)
        :effect (temple_entrance_found)
    )

    (:action set_traps
        :parameters (?c - hero ?forest - forest)
        :precondition (at ?c ?forest)
        :effect (traps_set)
    )

    (:action talk_merchant
        :parameters (?c - hero ?village - village)
        :precondition (at ?c ?village)
        :effect (merchant_info_received)
    )

    (:action find_map
        :parameters (?c - hero ?village - village)
        :precondition (at ?c ?village)
        :effect (map_found)
    )

    (:action buy_amulet
        :parameters (?c - hero ?merchant - npc ?village - village)
        :precondition (and
            (at ?c ?village)
            (merchant_info_received)
        )
        :effect (amulet_possessed)
    )

    (:action use_amulet
        :parameters (?c - hero)
        :precondition (amulet_possessed)
        :effect (amulet_used)
    )

    (:action enter_temple
        :parameters (?c - hero ?temple - temple)
        :precondition (and
            (at ?c ?temple)
            (or (magical_key_possessed) (alternate_entrance_found))
        )
        :effect (temple_accessible)
    )

    (:action find_alternate_entrance
        :parameters (?c - hero ?temple - temple)
        :precondition (at ?c ?temple)
        :effect (alternate_entrance_found)
    )

    (:action prepare_for_battle
        :parameters (?c - hero ?temple - temple)
        :precondition (and
            (at ?c ?temple)
            (temple_accessible)
        )
        :effect (prepared_for_battle)
    )

    (:action confront_dark_warden
        :parameters (?c - hero ?temple - temple)
        :precondition (and
            (at ?c ?temple)
            (temple_accessible)
        )
        :effect (in_battle_with_dark_warden)
    )

    (:action defeat_dark_warden
        :parameters (?c - hero)
        :precondition (in_battle_with_dark_warden)
        :effect (and
            (dark_warden_defeated)
            (not (in_battle_with_dark_warden))
        )
    )

    (:action negotiate_dark_warden
        :parameters (?c - hero)
        :precondition (in_battle_with_dark_warden)
        :effect (negotiation_attempted)
    )

    (:action negotiation_success
        :parameters (?c - hero)
        :precondition (negotiation_attempted)
        :effect (dark_warden_defeated)
    )

    (:action obtain_crystal
        :parameters (?c - hero)
        :precondition (dark_warden_defeated)
        :effect (crystal_possessed)
    )

    (:action rest_in_camp
        :parameters (?c - hero ?loc - location)
        :precondition (at ?c ?loc)
        :effect (rested)
    )
)

