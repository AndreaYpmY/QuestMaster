(define (domain intergalactic-tennis)
    (:requirements :strips :typing :negative-preconditions :disjunctive-preconditions)

    (:types
        object
        character location item sponsor clique - object
        player coach rival - character
        station arena market - location
        equipment racket suit - item
    )

    (:predicates
        (at ?char - character ?loc - location)
        (equipment-upgraded ?char - character)
        (trained-in-physics ?char - character)
        (has-sponsor ?char - character ?sponsor - sponsor)
        (has-ranking ?char - character)
        (reputation-level-1 ?char - character)
        (reputation-level-2 ?char - character)
        (reputation-level-3 ?char - character)
        (entry-blocked ?char - character)
        (rivalry-suspicious ?char - character)
        (rivalry-hostile ?char - character)
        (clique-support ?char - character)
        (evidence-collected ?char - character)
        (investigation-open)
        (vega-champion)
        (tournament-entry-pending ?char - character)
        (tournament-qualified ?char - character)
        (tournament-competing ?char - character)
        (tournament-advanced ?char - character)
        (final-match-ready ?char - character)
        (champion ?char - character)
        (cheating-scandal-resolved)
        (sponsor-interested ?sponsor - sponsor)
        (sponsor-requires-proof ?sponsor - sponsor)
        (sponsor-secured ?char - character ?sponsor - sponsor)
        (equipment-basic ?char - character)
        (equipment-hightech ?char - character)
        (match-won ?char - character)
        (match-lost ?char - character)
        (alliance-formed ?char - character)
        (risk-of-sabotage ?char - character)
        (morale-boosted ?char - character)
        (market ?loc - location)
    )

    (:action seek-coach
        :parameters (?p - player ?loc - location)
        :precondition (at ?p ?loc)
        :effect (and
            (trained-in-physics ?p)
            (not (equipment-upgraded ?p))
            (rivalry-suspicious ?p)
            (not (rivalry-hostile ?p))
        )
    )

    (:action visit-market-upgrade
        :parameters (?p - player ?loc - location)
        :precondition (and (at ?p ?loc) (market ?loc))
        :effect (and
            (equipment-hightech ?p)
            (not (equipment-basic ?p))
            (rivalry-hostile ?p)
        )
    )

    (:action enter-street-matches
        :parameters (?p - player ?loc - location)
        :precondition (at ?p ?loc)
        :effect (and
            (reputation-level-1 ?p)
            (not (equipment-upgraded ?p))
            (rivalry-hostile ?p)
        )
    )

    (:action challenge-minor-rival
        :parameters (?p - player ?r - rival ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (at ?r ?loc)
            (trained-in-physics ?p)
        )
        :effect (and
            (tournament-qualified ?p)
            (reputation-level-2 ?p)
            (not (equipment-upgraded ?p))
        )
    )

    (:action talk-to-sponsor
        :parameters (?p - player ?s - sponsor ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (sponsor-interested ?s)
            (sponsor-requires-proof ?s)
        )
        :effect (and
            (not (sponsor-requires-proof ?s))
            (sponsor-secured ?p ?s)
            (has-sponsor ?p ?s)
        )
    )

    (:action attempt-olympus-trials-entry-equipment
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (equipment-hightech ?p)
            (not (tournament-entry-pending ?p))
        )
        :effect (tournament-entry-pending ?p)
    )

    (:action attempt-olympus-trials-entry-reputation1
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (reputation-level-1 ?p)
            (not (tournament-entry-pending ?p))
        )
        :effect (tournament-entry-pending ?p)
    )

    (:action attempt-olympus-trials-entry-qualified
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (tournament-qualified ?p)
            (not (tournament-entry-pending ?p))
        )
        :effect (tournament-entry-pending ?p)
    )

    (:action win-qualification-match
        :parameters (?p - player ?r - rival ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (at ?r ?loc)
            (tournament-entry-pending ?p)
        )
        :effect (and
            (tournament-qualified ?p)
            (not (tournament-entry-pending ?p))
            (tournament-competing ?p)
        )
    )

    (:action negotiate-with-cliques
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (or (tournament-entry-pending ?p) (tournament-competing ?p))
        )
        :effect (and
            (clique-support ?p)
            (not (tournament-entry-pending ?p))
        )
    )

    (:action train-intensively
        :parameters (?p - player ?coach - coach ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (at ?coach ?loc)
        )
        :effect (and
            (trained-in-physics ?p)
            (reputation-level-3 ?p)
        )
    )

    (:action investigate-vega-cheating
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (tournament-competing ?p)
        )
        :effect (and
            (evidence-collected ?p)
            (risk-of-sabotage ?p)
        )
    )

    (:action confront-vega
        :parameters (?p - player ?v - rival ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (at ?v ?loc)
            (evidence-collected ?p)
        )
        :effect (and
            (not (risk-of-sabotage ?p))
        )
    )

    (:action present-evidence-to-officials
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (evidence-collected ?p)
        )
        :effect (and
            (investigation-open)
            (not (evidence-collected ?p))
        )
    )

    (:action form-alliance
        :parameters (?p - player ?clique - clique ?loc - location)
        :precondition (at ?p ?loc)
        :effect (and
            (alliance-formed ?p)
            (clique-support ?p)
        )
    )

    (:action advance-tournament
        :parameters (?p - player)
        :precondition (tournament-qualified ?p)
        :effect (and
            (tournament-advanced ?p)
            (not (tournament-qualified ?p))
            (tournament-competing ?p)
        )
    )

    (:action prepare-final-match
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (tournament-advanced ?p)
        )
        :effect (final-match-ready ?p)
    )

    (:action win-final-match
        :parameters (?p - player ?v - rival ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (at ?v ?loc)
            (final-match-ready ?p)
        )
        :effect (and
            (champion ?p)
            (cheating-scandal-resolved)
            (not (tournament-competing ?p))
        )
    )

    (:action secure-final-sponsor
        :parameters (?p - player ?s - sponsor ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (sponsor-interested ?s)
        )
        :effect (and
            (sponsor-secured ?p ?s)
            (has-sponsor ?p ?s)
            (morale-boosted ?p)
        )
    )

    (:action move
        :parameters (?c - character ?from - location ?to - location)
        :precondition (at ?c ?from)
        :effect (and
            (at ?c ?to)
            (not (at ?c ?from))
        )
    )

    (:action unblock-entry
        :parameters (?c - character ?loc - location)
        :precondition (and (at ?c ?loc) (entry-blocked ?c))
        :effect (not (entry-blocked ?c))
    )

    (:action remove-rivalry-hostile
        :parameters (?c - character)
        :precondition (rivalry-hostile ?c)
        :effect (and
            (not (rivalry-hostile ?c))
            (rivalry-suspicious ?c)
        )
    )
) 
