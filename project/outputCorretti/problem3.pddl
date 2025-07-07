

(define (problem olympus-tennis-quest-problem)
    (:domain olympus-tennis-quest)

    (:objects
        nova - player                              ; Main character
        vega - rival-player                        ; Martian champion rival
        olympus-arrival-bay olympus-market olympus-training-center olympus-social-lounge olympus-arena europa-grand-arena - location
        tech-vendor gear-vendor sponsor-techcorp sponsor-gearco sponsor-rival - sponsor
        coach1 - coach
        racket1 racket2 - racket
        suit1 suit2 - suit
        evidence1 - evidence
    )

    (:init
        ; Initial location and status
        (at nova olympus-arrival-bay)              ; Nova starts at arrival bay
        (not (has-sponsor nova sponsor-techcorp))
        (not (has-sponsor nova sponsor-gearco))
        (not (has-sponsor nova sponsor-rival))
        (not (has-ranking nova))
        (not (has-racket nova))
        (not (has-suit nova))
        (not (equipment-upgraded nova))
        (not (skill-improved nova))
        (not (respect-earned nova))
        (not (evidence-collected nova))
        (not (vega-cheating-known))
        (not (vega-suspended))
        (not (tournament-qualified nova))
        (not (tournament-won nova))
        (not (champion nova))

        ; Location connections (simplified)
        (connected olympus-arrival-bay olympus-market)
        (connected olympus-arrival-bay olympus-training-center)
        (connected olympus-arrival-bay olympus-social-lounge)
        (connected olympus-market olympus-training-center)
        (connected olympus-market olympus-social-lounge)
        (connected olympus-training-center olympus-arena)
        (connected olympus-social-lounge olympus-arena)
        (connected olympus-arena europa-grand-arena)

        ; Sponsors interested
        (sponsor-interested sponsor-techcorp)
        (sponsor-interested sponsor-gearco)
        (sponsor-interested sponsor-rival)

        ; Rival presence
        (rival-present vega)
        (rival-clique-blocking)

        ; Player location flags
        (not (in-market nova))
        (not (in-training-center nova))
        (not (in-social-lounge nova))
        (not (in-arena nova))
        (not (in-europa nova))
    )

    (:goal
        (and
            (champion nova)                       ; Nova crowned Intergalactic Tennis Champion
            (has-sponsor nova sponsor-techcorp)  ; Has at least one sponsor
            (equipment-upgraded nova)             ; Has upgraded equipment
            (skill-improved nova)                 ; Skills improved
            (vega-suspended)                     ; Vega suspended for cheating
        )
    )
)