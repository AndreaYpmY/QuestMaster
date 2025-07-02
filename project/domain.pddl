(define (domain dawnmere-quest)
    (:requirements :strips :typing :negative-preconditions) ; Use STRIPS, typing, and negation

    (:types
        location character item - object               ; Basic object types
        hero - character                               ; The main player character
        village forest temple temple_entrance perimeter chamber - location ; Specific locations
        crystal key - item                             ; Important quest items
        dark_warden - character                        ; Antagonist character
        forest_spirit - character                      ; Helpful NPC
    )

    (:predicates
        ; Location predicates
        (at ?c - character ?l - location)             ; Character is at a location
        (accessible ?l - location)                     ; Location is accessible
        (connected ?from - location ?to - location)   ; Locations are connected

        ; Item possession predicates
        (has ?c - character ?i - item)                 ; Character has an item

        ; Quest state predicates
        (crystal_possessed)                             ; Crystal of Light is possessed
        (dark_warden_defeated)                          ; Dark Warden has been defeated
        (temple_accessible)                             ; Temple can be accessed
        (forest_spirit_helped)                          ; Forest spirit has been helped
        (magical_key_possessed)                         ; Magical key is possessed
        (temple_reached)                                ; Temple has been reached
        (supplies_gathered)                             ; Supplies have been gathered
        (rested)                                        ; Hero has rested
        (quest_complete)                                ; Quest is complete
    )

    ; Actions for hero movement and preparation
    (:action journey_to_whispering_forest
        :parameters (?h - hero ?from - location ?to - forest)
        :precondition (and
            (at ?h ?from)                               ; Hero is at starting location
            (or (equal ?from village) (equal ?from forest)) ; From village or forest
            (equal ?to forest)                          ; Destination is Whispering Forest
        )
        :effect (and
            (at ?h ?to)                                 ; Hero moves to Whispering Forest
            (not (at ?h ?from))                         ; Hero leaves previous location
        )
    )

    (:action prepare_in_dawnmere
        :parameters (?h - hero ?loc - village)
        :precondition (at ?h ?loc)                       ; Hero is in Dawnmere
        :effect (supplies_gathered)                      ; Supplies gathered
    )

    (:action wait_in_dawnmere
        :parameters (?h - hero ?loc - village)
        :precondition (at ?h ?loc)                       ; Hero is in Dawnmere
        :effect ()                                       ; No state change, delay action
    )

    (:action return_to_dawnmere
        :parameters (?h - hero ?from - location ?to - village)
        :precondition (and
            (at ?h ?from)                               ; Hero is at some location
            (or (equal ?from forest) (equal ?from temple_entrance)) ; From forest or temple entrance
            (equal ?to village)                          ; Destination is Dawnmere
        )
        :effect (and
            (at ?h ?to)                                 ; Hero returns to Dawnmere
            (not (at ?h ?from))                         ; Hero leaves previous location
        )
    )

    ; Actions related to the forest spirit and magical key
    (:action seek_forest_spirit
        :parameters (?h - hero ?f - forest_spirit ?loc - forest)
        :precondition (at ?h ?loc)                       ; Hero is in Whispering Forest
        :effect ()                                       ; Narrative action, no direct state change
    )

    (:action perform_deed_of_kindness
        :parameters (?h - hero ?loc - forest)
        :precondition (at ?h ?loc)                       ; Hero is in Whispering Forest
        :effect (and
            (forest_spirit_helped)                        ; Forest spirit helped
            (magical_key_possessed)                       ; Magical key obtained
        )
    )

    (:action recite_ancient_oath
        :parameters (?h - hero ?loc - forest)
        :precondition (at ?h ?loc)                       ; Hero is in Whispering Forest
        :effect (and
            (forest_spirit_helped)                        ; Forest spirit helped
            (magical_key_possessed)                       ; Magical key obtained
        )
    )

    (:action explore_forest_for_clues
        :parameters (?h - hero ?loc - forest)
        :precondition (at ?h ?loc)                       ; Hero is in Whispering Forest
        :effect ()                                       ; Narrative action, no direct state change
    )

    (:action follow_glowing_trail
        :parameters (?h - hero ?loc - forest)
        :precondition (at ?h ?loc)
        :effect ()                                       ; Leads to forest spirit encounter
    )

    (:action investigate_tree_markings
        :parameters (?h - hero ?loc - forest)
        :precondition (at ?h ?loc)
        :effect ()                                       ; Leads to forest spirit encounter
    )

    (:action rest_in_forest
        :parameters (?h - hero ?loc - forest)
        :precondition (and
            (at ?h ?loc)
            (forest_spirit_helped)
            (magical_key_possessed)
        )
        :effect (rested)                                 ; Hero has rested
    )

    (:action explore_forest_further
        :parameters (?h - hero ?loc - forest)
        :precondition (and
            (at ?h ?loc)
            (forest_spirit_helped)
            (magical_key_possessed)
        )
        :effect (rested)                                 ; Hero gains rest/exploration benefit
    )

    ; Actions related to temple access
    (:action proceed_to_temple_entrance
        :parameters (?h - hero ?from - forest ?to - temple_entrance)
        :precondition (and
            (at ?h ?from)
            (forest_spirit_helped)
            (magical_key_possessed)
            (equal ?from forest)
            (equal ?to temple_entrance)
        )
        :effect (and
            (at ?h ?to)                                 ; Hero moves to temple entrance
            (temple_accessible)                          ; Temple is accessible now
            (temple_reached)                             ; Temple reached
            (not (at ?h ?from))
        )
    )

    (:action scout_temple_perimeter
        :parameters (?h - hero ?loc - temple_entrance)
        :precondition (and
            (at ?h ?loc)
            (temple_accessible)
            (temple_reached)
        )
        :effect ()                                       ; Narrative scouting action
    )

    (:action find_secret_entrance
        :parameters (?h - hero ?from - perimeter ?to - chamber)
        :precondition (and
            (at ?h ?from)
            (temple_accessible)
            (temple_reached)
            (equal ?from perimeter)
            (equal ?to chamber)
        )
        :effect (and
            (at ?h ?to)                                 ; Hero sneaks inside temple chamber
            (not (at ?h ?from))
        )
    )

    (:action enter_temple_directly
        :parameters (?h - hero ?from - temple_entrance ?to - chamber)
        :precondition (and
            (at ?h ?from)
            (temple_accessible)
            (temple_reached)
            (equal ?from temple_entrance)
            (equal ?to chamber)
        )
        :effect (and
            (at ?h ?to)                                 ; Hero enters temple chamber directly
            (not (at ?h ?from))
        )
    )

    ; Actions related to confronting the Dark Warden
    (:action engage_dark_warden_battle
        :parameters (?h - hero ?dw - dark_warden ?loc - chamber)
        :precondition (and
            (at ?h ?loc)
            (at ?dw ?loc)
            (temple_accessible)
            (temple_reached)
            (not (dark_warden_defeated))
        )
        :effect (dark_warden_defeated)                   ; Dark Warden defeated
    )

    (:action attempt_negotiation_dark_warden
        :parameters (?h - hero ?dw - dark_warden ?loc - chamber)
        :precondition (and
            (at ?h ?loc)
            (at ?dw ?loc)
            (temple_accessible)
            (temple_reached)
            (not (dark_warden_defeated))
        )
        :effect ()                                       ; Negotiation attempt, no state change
    )

    (:action retrieve_crystal_of_light
        :parameters (?h - hero ?loc - chamber ?c - crystal)
        :precondition (and
            (at ?h ?loc)
            (dark_warden_defeated)
            (not (crystal_possessed))
        )
        :effect (crystal_possessed)                       ; Hero obtains the Crystal of Light
    )

    (:action exit_temple_return_dawnmere
        :parameters (?h - hero ?from - chamber ?to - village)
        :precondition (and
            (at ?h ?from)
            (crystal_possessed)
            (dark_warden_defeated)
            (equal ?from chamber)
            (equal ?to village)
        )
        :effect (and
            (at ?h ?to)                                 ; Hero returns to Dawnmere
            (quest_complete)                            ; Quest is complete
            (not (at ?h ?from))
        )
    )

    (:action celebrate_restoration
        :parameters (?h - hero ?loc - village)
        :precondition (and
            (at ?h ?loc)
            (quest_complete)
        )
        :effect ()                                       ; End of quest celebration, no state change
    )
)