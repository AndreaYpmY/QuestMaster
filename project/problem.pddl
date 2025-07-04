
(define (problem temple-quest-problem)
    (:domain temple-quest)

    (:objects
        hero - hero
        dark-warden - dark-warden
        forest-spirit - forest-spirit

        dawnmere - village
        whispering-forest - forest
        temple-entrance - temple-entrance
        temple-inner - temple-inner
    )

    (:init
        (at hero dawnmere)
        (at dark-warden temple-inner)
        (at forest-spirit whispering-forest)

        (connected dawnmere whispering-forest)
        (connected whispering-forest dawnmere)
        (connected whispering-forest temple-entrance)
        (connected temple-entrance whispering-forest)
        (connected temple-entrance temple-inner)
        (connected temple-inner temple-entrance)
        (connected temple-entrance dawnmere)
        (connected dawnmere temple-entrance)
        (connected temple-inner dawnmere)
        (connected dawnmere temple-inner)
    )

    (:goal
        (and
            (has hero crystal-of-light)
            (dark-warden-defeated)
            (temple-accessible)
            (at hero dawnmere)
        )
    )
)