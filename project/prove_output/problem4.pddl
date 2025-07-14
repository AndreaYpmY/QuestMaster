
(define (problem nova-olympus-quest)
    (:domain intergalactic-tennis)

    (:objects
        nova - player
        vega - rival
        local-coach - coach
        sponsor1 sponsor2 - sponsor
        rival-clique1 rival-clique2 - clique
        olympus-station europa-station - station
        market-loc - location
        arena-loc - arena
    )

    (:init
        (at nova olympus-station)
        (at vega arena-loc)
        (at local-coach olympus-station)
        (equipment-basic nova)
        (entry-blocked nova)
        (rivalry-hostile nova)
        (vega-champion)
        (sponsor-interested sponsor1)
        (sponsor-requires-proof sponsor1)
        (market market-loc)
    )

    (:goal
        (and
            (champion nova)
            (cheating-scandal-resolved)
            (has-sponsor nova sponsor1)
        )
    )
)