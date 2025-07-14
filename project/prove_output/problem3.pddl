
(define (problem nova-olympus-quest)
    (:domain intergalactic-tennis)

    (:objects
        nova - player
        vega-stratos - rival
        stellar-sports-corp red-dust-energy - sponsor
        alpha-clique beta-clique - clique
        qualifier-tournament olympus-trials europa-grand-slam - tournament
        olympus-station - location
        racket suit - equipment
        vendor-challenge exhibition-match side-match qualifier-match olympus-final europa-final - match
        social-event - event
        improved zero - ranking-level
    )

    (:init
        (at nova olympus-station)
        (hostile alpha-clique)
        (hostile beta-clique)
        (ranking nova zero)
        (at vega-stratos olympus-station)
        (has-sponsor nova stellar-sports-corp)
        (has-sponsor nova red-dust-energy)
        (registered nova europa-grand-slam)
        (tournament-entered nova europa-grand-slam)
        (tournament-won nova europa-grand-slam)
        (equipment-upgraded nova)
    )

    (:goal
        (goal-achieved)
    )
)