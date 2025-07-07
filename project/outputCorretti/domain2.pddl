(define (domain redstone-gulch-quest)
    (:requirements :strips :typing :negative-preconditions)

    (:types
        object
        location
        character - object
        faction - object
        item - object
        player - character
        npc - character
        miner settler reformist-outlaw - faction
        sheriff lieutenant gang-member outlaw - npc
        document - item
    )

    (:constants
        saloon bank townhall redstone-gulch - location
        compromising-document - document
    )

    (:predicates
        (at ?obj - object ?loc - location)
        (controls ?char - character ?loc - location)
        (controls-faction ?f - faction ?loc - location)
        (trusts ?f - faction ?p - player)
        (not-trusted ?p - player)
        (has-info ?p - player ?info - item)
        (has ?p - player ?item - item)
        (siege ?loc - location)
        (weakened ?npc - npc)
        (defeated ?npc - npc)
        (documents-retrieved ?p - player)
        (publicly-confronted ?p - player ?npc - npc)
        (duel-won ?p - player ?npc - npc)
        (alliance ?p - player ?f - faction)
        (final-duel-ready ?p - player)
        (leader-recognized ?p - player)
        (quest-completed)
        (adjacent ?loc1 - location ?loc2 - location)
    )

    (:action investigate-saloon-gang
        :parameters (?p - player ?gang - gang-member ?sheriff - sheriff)
        :precondition (and
            (at ?p saloon)
            (controls ?gang saloon)
            (controls ?sheriff townhall)
            (not-trusted ?p)
        )
        :effect (and
            (has-info ?p compromising-document)
            (not (not-trusted ?p))
        )
    )

    (:action negotiate-miners
        :parameters (?p - player ?f - miner)
        :precondition (and
            (not (trusts ?f ?p))
            (not-trusted ?p)
        )
        :effect (and
            (trusts ?f ?p)
            (not (not-trusted ?p))
        )
    )

    (:action intervene-bank-siege
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (siege ?loc)
        )
        :effect (and
            (not (siege ?loc))
            (not (not-trusted ?p))
        )
    )

    (:action confront-sheriff-publicly
        :parameters (?p - player ?sheriff - sheriff)
        :precondition (and
            (has-info ?p compromising-document)
            (not (publicly-confronted ?p ?sheriff))
        )
        :effect (and
            (publicly-confronted ?p ?sheriff)
            (weakened ?sheriff)
        )
    )

    (:action gain-trust-settlers
        :parameters (?p - player ?f - settler)
        :precondition (not (trusts ?f ?p))
        :effect (and
            (trusts ?f ?p)
            (not (not-trusted ?p))
        )
    )

    (:action sabotage-saloon-gang
        :parameters (?p - player ?gang - gang-member)
        :precondition (controls ?gang saloon)
        :effect (weakened ?gang)
    )

    (:action help-miners-secure-mines
        :parameters (?p - player ?f - miner)
        :precondition (trusts ?f ?p)
        :effect (alliance ?p ?f)
    )

    (:action retrieve-documents
        :parameters (?p - player ?loc - location)
        :precondition (and
            (at ?p ?loc)
            (not (documents-retrieved ?p))
        )
        :effect (documents-retrieved ?p)
    )

    (:action negotiate-reformist-outlaws
        :parameters (?p - player ?f - reformist-outlaw)
        :precondition (not (trusts ?f ?p))
        :effect (and
            (trusts ?f ?p)
            (not (not-trusted ?p))
        )
    )

    (:action use-bank-influence
        :parameters (?p - player ?f - settler)
        :precondition (trusts ?f ?p)
        :effect (alliance ?p ?f)
    )

    (:action challenge-lieutenant-duel
        :parameters (?p - player ?lieutenant - lieutenant)
        :precondition (not (duel-won ?p ?lieutenant))
        :effect (and
            (duel-won ?p ?lieutenant)
            (weakened ?lieutenant)
        )
    )

    (:action confront-sheriff-with-documents
        :parameters (?p - player ?sheriff - sheriff ?f - faction)
        :precondition (and
            (documents-retrieved ?p)
            (trusts ?f ?p)
        )
        :effect (quest-completed)
    )

    (:action share-documents-with-factions
        :parameters (?p - player ?f - faction)
        :precondition (documents-retrieved ?p)
        :effect (trusts ?f ?p)
    )

    (:action prepare-final-duel
        :parameters (?p - player ?miner-faction - miner ?settler-faction - settler ?reformist-faction - reformist-outlaw)
        :precondition (and
            (trusts ?miner-faction ?p)
            (trusts ?settler-faction ?p)
            (trusts ?reformist-faction ?p)
        )
        :effect (final-duel-ready ?p)
    )

    (:action organize-public-assembly
        :parameters (?p - player)
        :precondition (final-duel-ready ?p)
        :effect (leader-recognized ?p)
    )

    (:action move
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and
            (at ?p ?from)
            (adjacent ?from ?to)
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )
) 
