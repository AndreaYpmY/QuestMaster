(define (domain temple-quest)
    (:requirements :strips :typing :negative-preconditions)

    (:types
        location character item - object
        hero npc - character
        crystal key - item
        temple dark-warden forest-spirit - npc
        village forest temple-entrance temple-inner - location
    )

    (:constants
        magical-key - key
        crystal-of-light - crystal
    )

    (:predicates
        (at ?char - character ?loc - location)
        (connected ?from - location ?to - location)

        (has ?char - character ?item - item)

        (dark-warden-defeated)
        (temple-accessible)
        (clues-found)
        (negotiation-attempted)
    )

    (:action journey-to-whispering-forest
        :parameters (?h - hero ?from - village ?to - forest)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action search-village-for-clues
        :parameters (?h - hero ?loc - village)
        :precondition (and
            (at ?h ?loc)
            (not (clues-found))
        )
        :effect (clues-found)
    )

    (:action approach-forest-spirit
        :parameters (?h - hero ?spirit - forest-spirit ?loc - forest)
        :precondition (and
            (at ?h ?loc)
            (at ?spirit ?loc)
            (not (has ?h magical-key))
        )
        :effect (has ?h magical-key)
    )

    (:action fail-approach-forest-spirit
        :parameters (?h - hero ?loc - forest)
        :precondition (and
            (at ?h ?loc)
            (not (has ?h magical-key))
        )
        :effect (negotiation-attempted)
    )

    (:action explore-deeper-forest
        :parameters (?h - hero ?loc - forest)
        :precondition (at ?h ?loc)
        :effect (clues-found)
    )

    (:action return-to-dawnmere-from-forest
        :parameters (?h - hero ?from - forest ?to - village)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action use-clues-to-find-forest-spirit
        :parameters (?h - hero ?from - village ?to - forest)
        :precondition (and
            (at ?h ?from)
            (clues-found)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action attempt-temple-entry-without-key
        :parameters (?h - hero ?loc - temple-entrance)
        :precondition (and
            (at ?h ?loc)
            (not (has ?h magical-key))
        )
        :effect (negotiation-attempted)
    )

    (:action find-hidden-path-to-temple
        :parameters (?h - hero ?from - forest ?to - temple-entrance)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
            (not (temple-accessible))
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action return-to-forest-from-temple
        :parameters (?h - hero ?from - temple-entrance ?to - forest)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action enter-temple-with-key
        :parameters (?h - hero ?from - temple-entrance ?to - temple-inner)
        :precondition (and
            (at ?h ?from)
            (has ?h magical-key)
            (not (temple-accessible))
            (connected ?from ?to)
        )
        :effect (and
            (temple-accessible)
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action leave-temple-inner-to-entrance
        :parameters (?h - hero ?from - temple-inner ?to - temple-entrance)
        :precondition (and
            (at ?h ?from)
            (temple-accessible)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action confront-dark-warden
        :parameters (?h - hero ?warden - dark-warden ?loc - temple-inner)
        :precondition (and
            (at ?h ?loc)
            (at ?warden ?loc)
            (temple-accessible)
            (not (dark-warden-defeated))
        )
        :effect (negotiation-attempted)
    )

    (:action fight-dark-warden
        :parameters (?h - hero ?warden - dark-warden ?loc - temple-inner)
        :precondition (and
            (at ?h ?loc)
            (at ?warden ?loc)
            (temple-accessible)
            (not (dark-warden-defeated))
        )
        :effect (and
            (dark-warden-defeated)
            (has ?h crystal-of-light)
        )
    )

    (:action negotiate-dark-warden
        :parameters (?h - hero ?warden - dark-warden ?loc - temple-inner)
        :precondition (and
            (at ?h ?loc)
            (at ?warden ?loc)
            (temple-accessible)
            (not (dark-warden-defeated))
            (not (negotiation-attempted))
        )
        :effect (negotiation-attempted)
    )

    (:action negotiation-success
        :parameters (?h - hero ?warden - dark-warden ?loc - temple-inner)
        :precondition (and
            (at ?h ?loc)
            (at ?warden ?loc)
            (temple-accessible)
            (negotiation-attempted)
            (not (dark-warden-defeated))
        )
        :effect (and
            (dark-warden-defeated)
            (has ?h crystal-of-light)
        )
    )

    (:action negotiation-failure
        :parameters (?h - hero ?warden - dark-warden ?loc - temple-inner)
        :precondition (and
            (at ?h ?loc)
            (at ?warden ?loc)
            (temple-accessible)
            (negotiation-attempted)
            (not (dark-warden-defeated))
        )
        :effect (negotiation-attempted)
    )

    (:action take-crystal-and-return
        :parameters (?h - hero ?from - temple-inner ?to - village)
        :precondition (and
            (at ?h ?from)
            (has ?h crystal-of-light)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action celebrate-victory
        :parameters (?h - hero ?loc - village)
        :precondition (and
            (at ?h ?loc)
            (has ?h crystal-of-light)
            (dark-warden-defeated)
            (temple-accessible)
        )
        :effect (and)
    )
) 
