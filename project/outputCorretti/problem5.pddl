(define (problem eldoria-quest-problem)
    (:domain eldoria-quest) ; Use the eldoria-quest domain

    (:objects
        ; Characters
        hero - hero

        ; Locations
        village1 - village
        market1 - market
        cottage1 - cottage
        whispering-forest1 - forest
        temple1 - temple
        clearing1 - clearing

        ; Items
        potion1 - potion
        dagger1 - dagger
        map1 - map
    )

    (:init
        ; Initial location of hero
        (at hero village1) ; Hero starts in the village to align with narrative

        ; Quest state initial conditions
        (crystal-lost) ; The Crystal of Light is lost
        (dark-warden-guarding) ; Dark Warden guards the temple
        (hero-health-full) ; Hero’s health fully restored

        ; Connections between locations (symmetric)
        (connected village1 whispering-forest1)
        (connected whispering-forest1 village1)
        (connected village1 cottage1)
        (connected cottage1 village1)
        (connected village1 market1)
        (connected market1 village1)
        (connected whispering-forest1 clearing1)
        (connected clearing1 whispering-forest1)
        (connected clearing1 temple1)
        (connected temple1 clearing1)

        ; Items initially at market
        (at potion1 market1)
        (at dagger1 market1)
        (at map1 market1)

        ; Forest spirit not yet encountered, hero must venture into forest to encounter
    )

    (:goal
        (and
            (at hero village1) ; Hero returns to village
            (crystal-possessed hero) ; Hero possesses the Crystal of Light
            (dark-warden-defeated) ; Dark Warden defeated
        )
    )
)