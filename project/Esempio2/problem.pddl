(define (problem martian-grand-slam-problem)
    (:domain martian-grand-slam)

    (:objects
        nova - player                                  ; The protagonist player
        vega-stratos - rival-clique                    ; The reigning Martian champion's clique
        olympus-entrance sports-gear-market training-facility corporate-lounge underground-hub exhibition-arena practice-arena qualifiers-arena olympus-trials-arena europa-grand-arena - location
                                                      ; Various locations in Olympus Station and arenas
        rix - coach                                    ; Vendor/coach offering prototype racket
        juno - coach                                   ; Training coach at training facility
        novacorp - sponsor                             ; Sponsor representative at corporate lounge
        exhibition-match qualifiers-match trials-match final-match - match
                                                      ; Matches in the story
        prototype-racket nextgen-racket modest-suit - equipment
                                                      ; Equipment types relevant to the story
    )

    (:init
        ;; Initial location of Nova at Olympus Station entrance
        (at nova olympus-entrance)                      ; Nova starts at Olympus Station entrance

        ;; Rival cliques block tournament entries at Olympus Station entrance
        (rival-cliques-blocking olympus-entrance)      ; Rival cliques block entries here

        ;; Sponsor representative is uncommitted initially
        (sponsor-uncommitted novacorp)                   ; Sponsor representative uncommitted

        ;; Nova has no sponsor, no ranking, no special equipment or training accepted initially
        ;; No negative literals included as per fix

        ;; Locations accessible initially
        (at nova olympus-entrance)                       ; Nova is at Olympus Station entrance
    )

    (:goal
        ;; Goal: Nova crowned Intergalactic Tennis Champion
        (and
            (champion nova)                              ; Nova is champion
            (at nova europa-grand-arena)                  ; Nova is at the final arena on Europa
        )
    )
)