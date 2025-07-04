
(define (problem crystal-quest-problem)
    (:domain crystal-quest)

    (:objects
        the-hero - hero
        Dawnmere Whispering-Forest Temple-of-Echoes-Outside Temple-of-Echoes-Inside - location
        magical-key - key
        crystal-of-light - crystal
        dark-warden - warden
    )

    (:init
        (at the-hero Dawnmere)
        (connected Dawnmere Whispering-Forest)
        (connected Whispering-Forest Dawnmere)
        (connected Whispering-Forest Temple-of-Echoes-Outside)
        (connected Temple-of-Echoes-Outside Whispering-Forest)
        (connected Temple-of-Echoes-Outside Temple-of-Echoes-Inside)
        (connected Temple-of-Echoes-Inside Temple-of-Echoes-Outside)
        (forest-spirit-location Whispering-Forest)
        (dark-warden-location Temple-of-Echoes-Inside)
    )

    (:goal
        (and
            (has the-hero crystal-of-light)
            (defeated dark-warden)
            (at the-hero Dawnmere)
            (temple-accessible the-hero)
            (has the-hero magical-key)
            (forest-spirit-helped)
        )
    )
)