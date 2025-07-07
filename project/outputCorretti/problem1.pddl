

(define (problem temple-quest-problem)
    (:domain temple-quest)

    (:objects
        hero - hero                              ; The main character
        elder merchant forest_spirit dark_warden - npc ; NPCs
        Dawnmere - village                      ; Village location
        Whispering_Forest - forest              ; Forest location
        Temple_of_Echoes - temple               ; Temple location
        magical_key crystal amulet - item       ; Quest items
    )

    (:init
        ; Initial hero location
        (at hero Dawnmere)

        ; Initial states
        (not (crystal_possessed))
        (not (dark_warden_defeated))
        (not (temple_accessible))
        (not (magical_key_possessed))
        (not (forest_spirit_helped))
        (not (elder_advice_received))
        (not (supplies_prepared))
        (not (rested))
        (not (trained))
        (not (gift_offered))
        (not (at_forest_spirit))
        (not (in_combat_with_spirit))
        (not (temple_entrance_found))
        (not (traps_set))
        (not (merchant_info_received))
        (not (map_found))
        (not (amulet_possessed))
        (not (amulet_used))
        (not (prepared_for_battle))
        (not (in_battle_with_dark_warden))
        (not (negotiation_attempted))
        (not (gift_accepted))
        (not (alternate_entrance_found))

        ; Connections between locations
        (connected Dawnmere Whispering_Forest)
        (connected Whispering_Forest Dawnmere)
        (connected Whispering_Forest Temple_of_Echoes)
        (connected Temple_of_Echoes Whispering_Forest)
    )

    (:goal
        (and
            (crystal_possessed)                  ; Hero has the Crystal of Light
            (dark_warden_defeated)               ; Dark Warden defeated
            (temple_accessible)                  ; Temple accessed
            (at hero Dawnmere)                   ; Hero returned to Dawnmere
        )
    )
)