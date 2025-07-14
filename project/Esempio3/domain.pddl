(define (domain dusty-bill-quest)
    (:requirements :strips :typing)
    (:types
        location character faction - object
    )
    (:constants
        reformist-outlaws - faction
    )
    (:predicates
        (at ?c - character ?l - location)
        (sheriff ?c - character)
        (controls ?f - faction ?l - location)
        (trusts ?c - character ?f - faction)
        (documents-at ?loc - location)
        (documents-held ?c - character)
        (duel-initiated)
        (allied ?c - character ?f - faction)
        (partial-alliance ?c - character ?f - faction)
        (sheriff-aware)
        (sheriff-alerted)
        (wounded ?c - character)
        (town-defended)
        (truce-established)
        (reformer-leader ?c - character)
        (tyrant-avoided)
    )

    (:action visit-saloon
        :parameters (?p - character ?l - location ?loc - location ?f - faction)
        :precondition (and (at ?p ?l) (controls ?f ?loc) (not (trusts ?p ?f)))
        :effect (and
            (not (at ?p ?l))
            (at ?p ?loc)
            (not (trusts ?p ?f))
        )
    )

    (:action head-to-bank
        :parameters (?p - character ?l - location ?loc - location ?f - faction)
        :precondition (and (at ?p ?l) (controls ?f ?loc) (not (trusts ?p ?f)))
        :effect (and
            (not (at ?p ?l))
            (at ?p ?loc)
            (not (trusts ?p ?f))
        )
    )

    (:action meet-miners
        :parameters (?p - character ?l - location ?loc - location ?f - faction)
        :precondition (and (at ?p ?l) (controls ?f ?loc) (not (trusts ?p ?f)))
        :effect (and
            (not (at ?p ?l))
            (at ?p ?loc)
            (not (trusts ?p ?f))
        )
    )

    (:action challenge-gage-duel
        :parameters (?p - character ?f - faction ?loc - location)
        :precondition (and (at ?p ?loc) (not (allied ?p ?f)) (not (trusts ?p ?f)) (controls ?f ?loc))
        :effect (and
            (allied ?p ?f)
            (sheriff-aware)
        )
    )

    (:action negotiate-gang
        :parameters (?p - character ?f - faction ?loc - location)
        :precondition (and (at ?p ?loc) (not (partial-alliance ?p ?f)) (controls ?f ?loc))
        :effect (partial-alliance ?p ?f)
    )

    (:action sneak-town-hall-from-saloon
        :parameters (?p - character ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action rally-settlers
        :parameters (?p - character ?f - faction ?loc - location)
        :precondition (and (at ?p ?loc) (not (trusts ?p ?f)) (controls ?f ?loc))
        :effect (trusts ?p ?f)
    )

    (:action seek-reformist-outlaws-from-bank
        :parameters (?p - character ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action find-documents-town-hall-from-bank
        :parameters (?p - character ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action protect-mine
        :parameters (?p - character ?f - faction ?loc - location)
        :precondition (and (at ?p ?loc) (not (trusts ?p ?f)) (controls ?f ?loc))
        :effect (trusts ?p ?f)
    )

    (:action propose-expose-mallory
        :parameters (?p - character ?f - faction ?loc - location)
        :precondition (and (at ?p ?loc) (not (partial-alliance ?p ?f)) (controls ?f ?loc))
        :effect (partial-alliance ?p ?f)
    )

    (:action sneak-town-hall-from-mine
        :parameters (?p - character ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action storm-town-hall-with-gang
        :parameters (?p - character ?f - faction ?loc - location)
        :precondition (and (allied ?p ?f) (documents-at ?loc))
        :effect (and
            (documents-held ?p)
            (not (documents-at ?loc))
        )
    )

    (:action reach-out-miners
        :parameters (?p - character ?miners - faction)
        :precondition (allied ?p ?miners)
        :effect (trusts ?p ?miners)
    )

    (:action prepare-final-duel
        :parameters (?p - character ?f - faction)
        :precondition (allied ?p ?f)
        :effect (duel-initiated)
    )

    (:action sneak-town-hall-during-distraction
        :parameters (?p - character ?f - faction ?from - location ?to - location)
        :precondition (partial-alliance ?p ?f)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action rally-joint-assault
        :parameters (?p - character ?f1 - faction ?f2 - faction ?loc - location)
        :precondition (and (partial-alliance ?p ?f1) (partial-alliance ?p ?f2) (not (= ?f1 ?f2)) (documents-at ?loc))
        :effect (and
            (documents-held ?p)
            (not (documents-at ?loc))
        )
    )

    (:action seek-reformist-outlaws
        :parameters (?p - character ?f1 - faction ?f2 - faction ?from - location ?to - location)
        :precondition (and (or (partial-alliance ?p ?f1) (partial-alliance ?p ?f2)) (not (= ?f1 ?f2)))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action hide-from-patrol
        :parameters (?p - character ?loc - location)
        :precondition (and (at ?p ?loc) (documents-held ?p) (not (sheriff-alerted)))
        :effect (not (sheriff-alerted))
    )

    (:action confront-sheriffs-men
        :parameters (?p - character ?loc - location)
        :precondition (and (at ?p ?loc) (documents-held ?p))
        :effect (and
            (wounded ?p)
            (sheriff-alerted)
        )
    )

    (:action flee-town-hall
        :parameters (?p - character ?from - location ?to - location)
        :precondition (and (at ?p ?from) (documents-held ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action approach-reformist-outlaws
        :parameters (?p - character ?from - location ?to - location)
        :precondition (and (at ?p ?from) (not (trusts ?p reformist-outlaws)))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action prepare-final-duel-from-square
        :parameters (?p - character ?loc - location)
        :precondition (at ?p ?loc)
        :effect (duel-initiated)
    )

    (:action strengthen-alliances
        :parameters (?p - character ?loc - location)
        :precondition (at ?p ?loc)
        :effect (town-defended)
    )

    (:action defend-town-from-raid
        :parameters (?p - character ?f - faction ?loc - location)
        :precondition (and (at ?p ?loc) (trusts ?p ?f))
        :effect (town-defended)
    )

    (:action negotiate-peace-with-outlaws
        :parameters (?p - character ?loc - location)
        :precondition (at ?p ?loc)
        :effect (truce-established)
    )

    (:action prepare-final-duel-ignore-outlaws
        :parameters (?p - character ?loc - location)
        :precondition (at ?p ?loc)
        :effect (duel-initiated)
    )

    (:action demand-mallory-stand-down
        :parameters (?p - character ?f1 - faction ?f2 - faction)
        :precondition (and (documents-held ?p) (trusts ?p ?f1) (trusts ?p ?f2) (not (= ?f1 ?f2)))
        :effect (not (duel-initiated))
    )

    (:action challenge-mallory-duel
        :parameters (?p - character ?f1 - faction ?f2 - faction)
        :precondition (and (documents-held ?p) (trusts ?p ?f1) (trusts ?p ?f2) (not (= ?f1 ?f2)))
        :effect (duel-initiated)
    )

    (:action use-documents-rally-outlaws
        :parameters (?p - character ?f1 - faction ?f2 - faction ?from - location ?to - location)
        :precondition (and (documents-held ?p) (trusts ?p ?f1) (trusts ?p ?f2) (not (= ?f1 ?f2)) (at ?p ?from))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action engage-in-duel
        :parameters (?p - character ?f1 - faction ?f2 - faction)
        :precondition (and (duel-initiated) (documents-held ?p) (allied ?p ?f1) (allied ?p ?f2) (not (= ?f1 ?f2)))
        :effect (and
            (reformer-leader ?p)
            (tyrant-avoided)
            (not (sheriff ?p))
        )
    )

    (:action return-to-rally-factions
        :parameters (?p - character ?from - location ?to - location)
        :precondition (and (at ?p ?from) (documents-held ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action seek-reformist-outlaws-from-hall
        :parameters (?p - character ?from - location ?to - location)
        :precondition (and (at ?p ?from) (documents-held ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action rally-factions-despite-injury
        :parameters (?p - character ?from - location ?to - location)
        :precondition (and (wounded ?p) (documents-held ?p) (at ?p ?from))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action hide-and-recover
        :parameters (?p - character)
        :precondition (wounded ?p)
        :effect (town-defended)
    )

    (:action challenge-final-duel
        :parameters (?p - character ?f1 - faction ?f2 - faction)
        :precondition (and (town-defended) (trusts ?p ?f1) (trusts ?p ?f2) (not (= ?f1 ?f2)))
        :effect (duel-initiated)
    )

    (:action negotiate-peace-with-outlaws-from-defense
        :parameters (?p - character)
        :precondition (town-defended)
        :effect (truce-established)
    )

    (:action prepare-final-duel-after-truce
        :parameters (?p - character)
        :precondition (truce-established)
        :effect (duel-initiated)
    )

    (:action reform-town-governance
        :parameters (?p - character ?s - character)
        :precondition (truce-established)
        :effect (and
            (reformer-leader ?p)
            (tyrant-avoided)
            (not (sheriff ?s))
        )
    )

    (:action proceed-to-duel-after-demand
        :parameters (?p - character)
        :precondition (and (documents-held ?p) (not (duel-initiated)))
        :effect (duel-initiated)
    )

    (:action rally-last-minute-support
        :parameters (?p - character)
        :precondition (and (documents-held ?p) (not (duel-initiated)))
        :effect (trusts ?p reformist-outlaws)
    )
)