(define (domain olympus-tennis-quest)
    (:requirements :strips :typing :negative-preconditions) ; Use STRIPS, typing, and negation

    (:types
        location character item sponsor rival - object ; Basic object types
        player - character                             ; Main character type
        vendor coach sponsor-agent rival-player - character ; NPC types
        racket suit equipment - item                   ; Equipment items
        market training-center social-lounge arena - location ; Locations
        evidence - item                                ; Evidence item type
    )

    (:predicates
        ; Location predicates
        (at ?obj - object ?loc - location)            ; Object or character is at location
        (connected ?loc1 - location ?loc2 - location) ; Locations connected (optional)

        ; Player status predicates
        (has-sponsor ?p - player ?s - sponsor)        ; Player has a sponsor
        (has-ranking ?p - player)                      ; Player has official ranking
        (has-equipment ?p - player ?e - equipment)    ; Player has equipment
        (equipment-upgraded ?p - player)               ; Player has upgraded equipment
        (skill-improved ?p - player)                    ; Player skill improved
        (respect-earned ?p - player)                    ; Player earned respect from rivals
        (sponsor-interested ?s - sponsor)               ; Sponsor interested in player
        (sponsor-committed ?s - sponsor)                ; Sponsor committed to player
        (evidence-collected ?p - player)                 ; Player collected evidence
        (vega-cheating-known)                            ; Cheating rumors confirmed
        (vega-suspended)                                ; Vega is suspended
        (tournament-qualified ?p - player)              ; Player qualified for tournament
        (tournament-won ?p - player)                     ; Player won tournament
        (finalist ?p - player)                            ; Player is finalist
        (champion ?p - player)                            ; Player is champion

        ; Rival and social predicates
        (rival-clique-blocking)                          ; Rival cliques blocking entry
        (rival-respect-changed ?p - player)             ; Rival clique attitude changed
        (rival-hostile ?r - rival-player)                ; Rival is hostile
        (rival-present ?r - rival-player)                ; Rival present

        ; Equipment predicates
        (has-racket ?p - player)                          ; Player has racket
        (has-suit ?p - player)                            ; Player has suit
        (high-tech-racket ?e - racket)                    ; Racket is high-tech
        (high-tech-suit ?e - suit)                        ; Suit is high-tech

        ; Location specific predicates
        (in-market ?p - player)                           ; Player in market
        (in-training-center ?p - player)                  ; Player in training center
        (in-social-lounge ?p - player)                    ; Player in social lounge
        (in-arena ?p - player)                            ; Player in arena
        (in-europa ?p - player)                           ; Player at Europa location

        ; Action related predicates
        (proof-of-skill ?p - player)                      ; Player has proof of skill
        (proof-of-integrity ?p - player)                  ; Player has proof of integrity
        (sponsor-requested-proof ?s - sponsor)            ; Sponsor requested proof
    )

    (:action explore-market
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and
            (at ?p ?from)
            (connected ?from ?to)
            (not (in-market ?p))
        )
        :effect (and
            (at ?p ?to)
            (in-market ?p)
            (not (at ?p ?from))
            (not (in-training-center ?p))
            (not (in-social-lounge ?p))
            (not (in-arena ?p))
            (not (in-europa ?p))
        )
    )

    (:action visit-training-center
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and
            (at ?p ?from)
            (connected ?from ?to)
            (not (in-training-center ?p))
        )
        :effect (and
            (at ?p ?to)
            (in-training-center ?p)
            (not (at ?p ?from))
            (not (in-market ?p))
            (not (in-social-lounge ?p))
            (not (in-arena ?p))
            (not (in-europa ?p))
        )
    )

    (:action attend-social-gathering
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and
            (at ?p ?from)
            (connected ?from ?to)
            (not (in-social-lounge ?p))
        )
        :effect (and
            (at ?p ?to)
            (in-social-lounge ?p)
            (not (at ?p ?from))
            (not (in-market ?p))
            (not (in-training-center ?p))
            (not (in-arena ?p))
            (not (in-europa ?p))
        )
    )

    (:action negotiate-racket
        :parameters (?p - player ?r - racket)
        :precondition (and
            (in-market ?p)
            (not (has-racket ?p))
        )
        :effect (and
            (has-racket ?p)
            (equipment-upgraded ?p)
            (high-tech-racket ?r)
        )
    )

    (:action seek-sponsor
        :parameters (?p - player ?s - sponsor)
        :precondition (and
            (or (in-market ?p) (in-social-lounge ?p))
            (not (has-sponsor ?p ?s))
            (sponsor-interested ?s)
        )
        :effect (and
            (has-sponsor ?p ?s)
            (sponsor-committed ?s)
        )
    )

    (:action practice-skill
        :parameters (?p - player)
        :precondition (in-training-center ?p)
        :effect (skill-improved ?p)
    )

    (:action challenge-rival
        :parameters (?p - player ?r - rival-player)
        :precondition (and
            (in-training-center ?p)
            (rival-present ?r)
        )
        :effect (respect-earned ?p)
    )

    (:action approach-coach
        :parameters (?p - player ?c - coach)
        :precondition (in-training-center ?p)
        :effect (skill-improved ?p)
    )

    (:action enter-qualifiers
        :parameters (?p - player)
        :precondition (and
            (skill-improved ?p)
            (or (has-racket ?p) (equipment-upgraded ?p))
        )
        :effect (tournament-qualified ?p)
    )

    (:action investigate-vega
        :parameters (?p - player ?e - evidence)
        :precondition (or (in-market ?p) (in-social-lounge ?p) (in-training-center ?p))
        :effect (and
            (evidence-collected ?p)
            (vega-cheating-known)
        )
    )

    (:action present-evidence
        :parameters (?p - player)
        :precondition (and
            (evidence-collected ?p)
            (vega-cheating-known)
        )
        :effect (vega-suspended)
    )

    (:action confront-vega
        :parameters (?p - player)
        :precondition (vega-cheating-known)
        :effect (vega-suspended)
    )

    (:action compete-trials
        :parameters (?p - player)
        :precondition (tournament-qualified ?p)
        :effect (tournament-won ?p)
    )

    (:action travel-europa
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and
            (tournament-won ?p)
            (at ?p ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?p ?to)
            (in-europa ?p)
            (not (at ?p ?from))
        )
    )

    (:action final-match
        :parameters (?p - player)
        :precondition (and
            (in-europa ?p)
            (tournament-won ?p)
        )
        :effect (champion ?p)
    )
)

