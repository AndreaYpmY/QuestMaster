
(define (problem eldoria-quest-problem)
    (:domain eldoria-quest)

    (:objects
        hero - hero                              ; The chosen hero
        village-elder villager hunter dark-warden - npc    ; NPCs in village and temple
        dawnmere - village                      ; Village location
        whispering-forest - forest              ; Forest location
        temple-of-echoes - temple               ; Temple location
        magical-key - key                       ; Magical key item
        crystal-of-light - crystal              ; Crystal item
    )

    (:init
        ; Initial locations
        (at hero dawnmere)                      ; Hero starts in Dawnmere
        (at village-elder dawnmere)             ; Elder in village
        (at villager dawnmere)                  ; Villager in village
        (at hunter dawnmere)                     ; Hunter in village
        (at dark-warden temple-of-echoes)       ; Dark Warden guards temple

        ; Initial states
        (crystal-lost)                          ; Crystal is lost
        (dark-warden-guards-temple)             ; Dark Warden guards temple

        ; Hero initial knowledge and possessions
        ; Negative literals removed as per STRIPS limitations
    )

    (:goal
        (and
            (crystal-possessed hero)              ; Hero possesses the Crystal of Light
            (dark-warden-defeated)                 ; Dark Warden defeated
        )
    )
)