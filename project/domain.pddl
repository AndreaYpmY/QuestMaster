(define (domain dungeon-exploration)
    (:requirements :strips :typing :negative-preconditions)

    (:types
        location character item - object
        village forest temple - location
        hero npc - character
        dark-warden forest-spirit - npc
        crystal magical-key supplies gift - item
    )

    (:predicates
        (at ?obj - object ?loc - location)
        (connected ?loc1 - location ?loc2 - location)
        (path-blocked ?loc1 - location ?loc2 - location)

        (alive ?h - hero)
        (armed ?h - hero)
        (has-key ?h - hero)
        (knows-oath ?h - hero)
        (rested ?h - hero)

        (crystal-lost)
        (crystal-possessed ?h - hero)
        (key-held-by-spirit)
        (key-received ?h - hero)

        (guards ?npc - npc ?loc - location)
        (friendly ?npc - npc)
        (nearby ?npc - npc ?loc - location)
        (willing-to-help ?npc - npc)
        (considering-aid ?npc - npc)
        (alerted ?npc - npc)
        (defeated ?npc - npc)

        (proved-worthiness ?h - hero)
        (gift-offered ?h - hero)
        (trial-underway ?h - hero)
        (has-guidance ?h - hero)
        (entered-temple ?h - hero)
        (scouted-temple ?h - hero)
        (found-weakness ?h - hero)
        (sneaking ?h - hero)
        (negotiating ?h - hero)
        (engaged-in-combat ?h - hero)
        (escaped-with-crystal ?h - hero)

        (has-item ?h - hero ?i - item)
    )

    (:action travel
        :parameters (?h - hero ?from - location ?to - location)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
            (alive ?h)
            (not (path-blocked ?from ?to))
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action gather-supplies
        :parameters (?h - hero ?loc - village)
        :precondition (and
            (at ?h ?loc)
            (alive ?h)
            (not (armed ?h))
        )
        :effect (and
            (armed ?h)
            (has-item ?h supplies)
        )
    )

    (:action train-with-elder
        :parameters (?h - hero ?loc - village)
        :precondition (and
            (at ?h ?loc)
            (armed ?h)
            (alive ?h)
            (not (knows-oath ?h))
        )
        :effect (knows-oath ?h)
    )

    (:action rest-in-village
        :parameters (?h - hero ?loc - village)
        :precondition (and
            (at ?h ?loc)
            (alive ?h)
            (not (rested ?h))
        )
        :effect (rested ?h)
    )

    (:action approach-forest-spirit
        :parameters (?h - hero ?loc - forest ?spirit - forest-spirit)
        :precondition (and
            (at ?h ?loc)
            (nearby ?spirit ?loc)
            (alive ?h)
            (not (proved-worthiness ?h))
        )
        :effect (proved-worthiness ?h)
    )

    (:action explore-forest
        :parameters (?h - hero ?loc - forest)
        :precondition (and
            (at ?h ?loc)
            (alive ?h)
            (not (trial-underway ?h))
        )
        :effect (trial-underway ?h)
    )

    (:action return-to-dawnmere
        :parameters (?h - hero ?from - forest ?to - village)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
            (alive ?h)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action recite-oath
        :parameters (?h - hero ?spirit - forest-spirit ?loc - forest)
        :precondition (and
            (at ?h ?loc)
            (proved-worthiness ?h)
            (knows-oath ?h)
            (alive ?h)
            (not (considering-aid ?spirit))
        )
        :effect (considering-aid ?spirit)
    )

    (:action offer-gift
        :parameters (?h - hero ?spirit - forest-spirit ?loc - forest ?gift - gift)
        :precondition (and
            (at ?h ?loc)
            (alive ?h)
            (has-item ?h ?gift)
            (not (gift-offered ?h))
        )
        :effect (gift-offered ?h)
    )

    (:action request-trial
        :parameters (?h - hero ?spirit - forest-spirit)
        :precondition (and
            (gift-offered ?h)
            (alive ?h)
            (not (trial-underway ?h))
        )
        :effect (trial-underway ?h)
    )

    (:action solve-riddle
        :parameters (?h - hero)
        :precondition (and
            (trial-underway ?h)
            (alive ?h)
        )
        :effect (and
            (proved-worthiness ?h)
            (not (trial-underway ?h))
        )
    )

    (:action show-courage
        :parameters (?h - hero)
        :precondition (and
            (trial-underway ?h)
            (alive ?h)
        )
        :effect (and
            (proved-worthiness ?h)
            (not (trial-underway ?h))
        )
    )

    (:action accept-magical-key
        :parameters (?h - hero ?spirit - forest-spirit ?loc - forest)
        :precondition (and
            (at ?h ?loc)
            (considering-aid ?spirit)
            (proved-worthiness ?h)
            (alive ?h)
            (key-held-by-spirit)
            (not (key-received ?h))
        )
        :effect (and
            (has-key ?h)
            (key-received ?h)
            (not (key-held-by-spirit))
        )
    )

    (:action request-guidance
        :parameters (?h - hero ?spirit - forest-spirit ?loc - forest)
        :precondition (and
            (at ?h ?loc)
            (considering-aid ?spirit)
            (alive ?h)
            (not (has-key ?h))
        )
        :effect (has-guidance ?h)
    )

    (:action search-alternate-entrance
        :parameters (?h - hero ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (alive ?h)
            (not (has-key ?h))
        )
        :effect (entered-temple ?h)
    )

    (:action enter-temple-with-key
        :parameters (?h - hero ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (has-key ?h)
            (alive ?h)
            (not (entered-temple ?h))
        )
        :effect (entered-temple ?h)
    )

    (:action scout-temple
        :parameters (?h - hero ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (has-key ?h)
            (alive ?h)
            (not (scouted-temple ?h))
        )
        :effect (scouted-temple ?h)
    )

    (:action discover-weakness
        :parameters (?h - hero)
        :precondition (and
            (scouted-temple ?h)
            (alive ?h)
            (not (found-weakness ?h))
        )
        :effect (found-weakness ?h)
    )

    (:action enter-temple-no-advantage
        :parameters (?h - hero)
        :precondition (and
            (scouted-temple ?h)
            (alive ?h)
            (not (found-weakness ?h))
        )
        :effect (entered-temple ?h)
    )

    (:action find-hidden-passage
        :parameters (?h - hero ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (alive ?h)
            (not (has-key ?h))
            (not (entered-temple ?h))
        )
        :effect (and
            (entered-temple ?h)
            (sneaking ?h)
        )
    )

    (:action abandon-and-return-for-key
        :parameters (?h - hero ?from - temple ?to - forest)
        :precondition (and
            (at ?h ?from)
            (alive ?h)
            (not (has-key ?h))
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action engage-combat
        :parameters (?h - hero ?warden - dark-warden ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (at ?warden ?loc)
            (alive ?h)
            (alive ?warden)
            (entered-temple ?h)
            (not (engaged-in-combat ?h))
        )
        :effect (engaged-in-combat ?h)
    )

    (:action negotiate
        :parameters (?h - hero ?warden - dark-warden ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (at ?warden ?loc)
            (alive ?h)
            (alive ?warden)
            (entered-temple ?h)
            (not (negotiating ?h))
        )
        :effect (negotiating ?h)
    )

    (:action convince-surrender
        :parameters (?h - hero ?warden - dark-warden)
        :precondition (and
            (negotiating ?h)
            (alive ?h)
            (alive ?warden)
            (or (has-key ?h) (knows-oath ?h))
        )
        :effect (and
            (defeated ?warden)
            (not (alive ?warden))
        )
    )

    (:action warden-attacks
        :parameters (?h - hero ?warden - dark-warden)
        :precondition (and
            (negotiating ?h)
            (alive ?h)
            (alive ?warden)
            (not (or (has-key ?h) (knows-oath ?h)))
        )
        :effect (engaged-in-combat ?h)
    )

    (:action use-key-in-combat
        :parameters (?h - hero ?warden - dark-warden)
        :precondition (and
            (engaged-in-combat ?h)
            (has-key ?h)
            (alive ?h)
            (alive ?warden)
        )
        :effect (and
            (defeated ?warden)
            (not (alive ?warden))
        )
    )

    (:action fight-without-key
        :parameters (?h - hero ?warden - dark-warden)
        :precondition (and
            (engaged-in-combat ?h)
            (not (has-key ?h))
            (alive ?h)
            (alive ?warden)
        )
        :effect (and
            (not (defeated ?warden))
            (not (defeated ?h))
        )
    )

    (:action sneak-past-warden
        :parameters (?h - hero ?warden - dark-warden ?loc - temple)
        :precondition (and
            (entered-temple ?h)
            (sneaking ?h)
            (at ?warden ?loc)
            (alive ?h)
            (alive ?warden)
        )
        :effect (and
            (crystal-possessed ?h)
            (escaped-with-crystal ?h)
            (not (crystal-lost))
        )
    )

    (:action confront-after-steal
        :parameters (?h - hero ?warden - dark-warden)
        :precondition (and
            (crystal-possessed ?h)
            (alive ?h)
            (alive ?warden)
        )
        :effect (engaged-in-combat ?h)
    )

    (:action flee-to-dawnmere
        :parameters (?h - hero ?from - temple ?to - village)
        :precondition (and
            (escaped-with-crystal ?h)
            (at ?h ?from)
            (alive ?h)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
            (not (crystal-lost))
        )
    )

    (:action prepare-for-final-battle
        :parameters (?h - hero)
        :precondition (and
            (escaped-with-crystal ?h)
            (alive ?h)
        )
        :effect (engaged-in-combat ?h)
    )
)

