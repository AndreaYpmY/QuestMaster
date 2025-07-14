(define (problem quest-problem)
    (:domain quest-domain)

    (:objects
        hero forest-spirit - character                    ; The main hero and forest spirit characters
        dawnmere elder-hut blacksmith whispering-forest temple-of-echoes temple-entrance temple-perimeter alcove edge-forest - location
        dark-warden - obstacle                            ; The Dark Warden obstacle
        sword shield - item                               ; Items the hero can possess
    )

    (:init
        (at hero dawnmere)                                ; Hero starts in the village of Dawnmere
        (crystal-lost)                                    ; The Crystal of Light is lost
        (guarding dark-warden temple-of-echoes)          ; Dark Warden guards the temple
    )

    (:goal
        (and
            (crystal-possessed hero)                        ; Hero possesses the Crystal of Light
            (warden-defeated)                               ; Dark Warden is defeated
        )
    )
)