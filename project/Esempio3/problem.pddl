(define (problem dusty-bill-quest-problem)
    (:domain dusty-bill-quest)

    (:objects
        dusty-bill sheriff-frank gage jed clara lila - character
        redstone-gulch saloon bank mine-entrance town-hall town-square alleyways - location
        gang miners settlers - faction
    )

    (:init
        (at dusty-bill saloon)
        (sheriff sheriff-frank)
        (controls gang saloon)
        (controls settlers bank)
        (controls miners mine-entrance)
        (documents-at town-hall)
    )

    (:goal
        (and
            (reformer-leader dusty-bill)
            (tyrant-avoided)
            (not (sheriff sheriff-frank))
        )
    )
)