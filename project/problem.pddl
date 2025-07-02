(define (problem crystal-recovery)
    (:domain dungeon-quest)                     ; References the dungeon-quest domain

    (:objects
        hero - character                          ; The main character (hero)
        darkwarden - character                    ; The antagonist (Dark Warden)
        village - location                        ; The village of Dawnmere
        whispering-forest - location              ; The Whispering Forest
        temple - location                         ; The Temple of Echoes
        ancient-artifact - item                   ; An artifact found in the forest
        magical-key - key                        ; The magical key needed to enter the temple
        crystal-of-light - item                   ; The Crystal of Light to be recovered
    )

    (:init
        ; Initial world state - where the story begins
        (at hero village)                         ; Hero starts in the village of Dawnmere
        (darkwarden-guarding temple)              ; Dark Warden guards the temple
        (crystal-lost)                           ; The Crystal of Light is lost
        (not (key-held hero))                    ; Hero does not have the magical key
    )

    (:goal
        (and 
            (not (crystal-lost))                   ; Goal: recover the Crystal of Light
            (defeated darkwarden)                  ; Dark Warden must be defeated
            (at hero temple)                        ; Hero must reach the temple
        )
    )
)