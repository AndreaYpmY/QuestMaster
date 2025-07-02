
(define (problem dungeon-exploration-problem)
    (:domain dungeon-exploration)

    (:objects
        hero - hero
        dark-warden - dark-warden
        forest-spirit - forest-spirit

        dawnmere - village
        whispering-forest - forest
        temple-of-echoes - temple

        crystal-of-light - crystal
        magical-key - magical-key
        supplies - supplies
        gift-from-dawnmere - gift
    )

    (:init
        (at hero dawnmere)

        (alive hero)
        (not (armed hero))
        (not (has-key hero))
        (not (knows-oath hero))
        (not (rested hero))
        (not (proved-worthiness hero))
        (not (gift-offered hero))
        (not (trial-underway hero))
        (not (key-received hero))
        (not (has-guidance hero))
        (not (entered-temple hero))
        (not (scouted-temple hero))
        (not (found-weakness hero))
        (not (sneaking hero))
        (not (negotiating hero))
        (not (engaged-in-combat hero))
        (not (crystal-possessed hero))
        (not (escaped-with-crystal hero))

        (crystal-lost)

        (key-held-by-spirit)

        (alive dark-warden)
        (guards dark-warden temple-of-echoes)
        (alive forest-spirit)
        (nearby forest-spirit whispering-forest)
        (willing-to-help forest-spirit)
        (not (considering-aid forest-spirit))
        (not (defeated dark-warden))
        (not (alerted dark-warden))

        (connected dawnmere whispering-forest)
        (connected whispering-forest dawnmere)
        (connected whispering-forest temple-of-echoes)
        (connected temple-of-echoes whispering-forest)
    )

    (:goal
        (and
            (crystal-possessed hero)
            (alive hero)
            (defeated dark-warden)
            (at hero dawnmere)
        )
    )
)