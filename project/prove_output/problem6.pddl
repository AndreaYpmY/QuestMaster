(define (problem martian-grand-slam-problem)
    (:domain martian-grand-slam)

    (:objects
        nova - player                          ; The protagonist player Nova Racket
        sponsor1 sponsor2 - sponsor           ; Two potential sponsors
        olympus-station europa - location     ; Key locations: Olympus Station and Europa
        outdated low-ranking improved-high - ranking ; Rankings
        outdated-eq upgraded-eq - equipment   ; Equipment states for Nova
        illegal-tech - rumor                   ; Rumor about Vega's illegal tech
    )

    (:init
        (at nova olympus-station)                     ; Nova is at Olympus Station initially
        (equipment-state nova outdated-eq)             ; Nova's equipment is outdated
        (vega-champion)                                ; Vega Stratos is reigning champion
        (rival-cliques-blocking)                        ; Rival cliques block tournament entries
        (rumor-exists illegal-tech)                     ; Rumor of Vega's illegal tech exists
        ; Removed initial sponsors and two-sponsors predicate to allow progression
    )

    (:goal
        (and
            (final-champion nova)                           ; Nova crowned Intergalactic Tennis Champion
            (equipment-state nova upgraded-eq)             ; Equipment upgraded
            (two-sponsors nova)                             ; Nova has two or more sponsors
            (at nova europa)                                ; Goal adjusted: Nova at Europa to match final action precondition
            (not (vega-champion))                           ; Vega defeated, no longer champion
        )
    )
)