(define (problem dawnmere-quest-problem)
    (:domain dawnmere-quest)                                  ; Use the dawnmere-quest domain

    (:objects
        hero - hero                                           ; The main player character
        dark-warden - dark_warden                             ; The antagonist inside the temple
        forest-spirit - forest_spirit                         ; Helpful NPC in the forest

        dawnmere - village                                    ; Starting village location
        whispering-forest - forest                            ; Forest location
        temple-entrance temple-perimeter temple-chamber - location ; Temple locations

        crystal-of-light - crystal                             ; The Crystal of Light item
        magical-key - key                                     ; Magical key obtained from forest spirit
    )

    (:init
        ; Initial hero location is Dawnmere village
        (at hero dawnmere)                                    ; Hero starts in Dawnmere

        ; Initial quest states - all false at start
        (not (crystal_possessed))                             ; Hero does not possess the crystal
        (not (dark_warden_defeated))                          ; Dark Warden not defeated
        (not (temple_accessible))                             ; Temple is not accessible yet
        (not (forest_spirit_helped))                          ; Forest spirit not helped yet
        (not (magical_key_possessed))                         ; Magical key not possessed
        (not (temple_reached))                                ; Temple not reached
        (not (supplies_gathered))                             ; Supplies not gathered
        (not (rested))                                        ; Hero has not rested
        (not (quest_complete))                                ; Quest not complete

        ; Location connectivity (for narrative consistency)
        (connected dawnmere whispering-forest)                ; Dawnmere connected to Whispering Forest
        (connected whispering-forest temple-entrance)          ; Forest connected to Temple Entrance
        (connected temple-entrance temple-perimeter)            ; Temple entrance to perimeter
        (connected temple-perimeter temple-chamber)             ; Perimeter to inner chamber

        ; Characters locations
        (at dark-warden temple-chamber)                        ; Dark Warden inside temple chamber
        (at forest-spirit whispering-forest)                   ; Forest spirit in Whispering Forest
    )

    (:goal
        (and
            (quest_complete)                                   ; Quest must be completed
            (at hero dawnmere)                                 ; Hero returns to Dawnmere
            (crystal_possessed)                                ; Hero possesses the Crystal of Light
            (dark_warden_defeated)                             ; Dark Warden defeated
        )
    )
)