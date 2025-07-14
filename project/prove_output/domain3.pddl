(define (domain intergalactic-tennis)
    (:requirements :strips :typing)

    (:types
        character sponsor clique equipment location - object
        player npc rival - character
        racket suit - equipment
        station tournament match event - location
        ranking-level - object
    )

    (:predicates
        (at ?c - character ?l - location)
        (equipment-upgraded ?p - player)
        (has-sponsor ?p - player ?s - sponsor)
        (ranking ?p - player ?r - ranking-level)
        (registered ?p - player ?t - tournament)
        (hostile ?cl - clique)
        (friendly ?cl - clique)
        (sponsor-challenged ?p - player ?s - sponsor)
        (sponsor-favored ?p - player ?s - sponsor)
        (match-won ?p - player ?m - match)
        (match-lost ?p - player ?m - match)
        (evidence-uncovered ?p - player)
        (evidence-presented ?p - player)
        (tournament-entered ?p - player ?t - tournament)
        (tournament-won ?p - player ?t - tournament)
        (sponsor-secured ?p - player ?s - sponsor)
        (clique-ally ?p - player ?cl - clique)
        (goal-achieved)
    )

    (:action seek-entry-qualifier
        :parameters (?p - player ?t - tournament ?cl - clique ?l - location)
        :precondition (and
            (at ?p ?l)
            (hostile ?cl)
            (not (registered ?p ?t))
        )
        :effect (and
            (registered ?p ?t)
            (not (hostile ?cl))
        )
    )

    (:action search-tech-vendor
        :parameters (?p - player ?l - location)
        :precondition (at ?p ?l)
        :effect (equipment-upgraded ?p)
    )

    (:action befriend-sponsor
        :parameters (?p - player ?s - sponsor ?l - location)
        :precondition (and
            (at ?p ?l)
            (not (has-sponsor ?p ?s))
        )
        :effect (has-sponsor ?p ?s)
    )

    (:action train-intensively
        :parameters (?p - player ?old ?new - ranking-level)
        :precondition (and
            (equipment-upgraded ?p)
            (ranking ?p ?old)
        )
        :effect (and
            (not (ranking ?p ?old))
            (ranking ?p ?new)
        )
    )

    (:action negotiate-entry
        :parameters (?p - player ?cl - clique ?l - location)
        :precondition (and
            (at ?p ?l)
            (hostile ?cl)
        )
        :effect (and
            (friendly ?cl)
            (not (hostile ?cl))
        )
    )

    (:action play-challenge-match
        :parameters (?p - player ?m - match ?l - location)
        :precondition (at ?p ?l)
        :effect (match-won ?p ?m)
    )

    (:action lose-challenge-match
        :parameters (?p - player ?m - match ?l - location)
        :precondition (at ?p ?l)
        :effect (match-lost ?p ?m)
    )

    (:action attend-social-event
        :parameters (?p - player ?e - event ?s - sponsor ?l - location)
        :precondition (at ?p ?l)
        :effect (sponsor-favored ?p ?s)
    )

    (:action enter-tournament
        :parameters (?p - player ?t - tournament)
        :precondition (registered ?p ?t)
        :effect (tournament-entered ?p ?t)
    )

    (:action win-tournament
        :parameters (?p - player ?t - tournament)
        :precondition (tournament-entered ?p ?t)
        :effect (tournament-won ?p ?t)
    )

    (:action uncover-evidence
        :parameters (?p - player ?l - location)
        :precondition (at ?p ?l)
        :effect (evidence-uncovered ?p)
    )

    (:action present-evidence
        :parameters (?p - player)
        :precondition (evidence-uncovered ?p)
        :effect (evidence-presented ?p)
    )

    (:action ally-with-clique
        :parameters (?p - player ?cl - clique ?l - location)
        :precondition (and
            (hostile ?cl)
            (at ?p ?l)
        )
        :effect (and
            (clique-ally ?p ?cl)
            (not (hostile ?cl))
        )
    )

    (:action achieve-goal
        :parameters (?p - player ?t - tournament ?s1 - sponsor ?s2 - sponsor)
        :precondition (and
            (tournament-won ?p ?t)
            (has-sponsor ?p ?s1)
            (has-sponsor ?p ?s2)
            (equipment-upgraded ?p)
        )
        :effect (goal-achieved)
    )
) 
