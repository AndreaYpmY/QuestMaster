(define (domain eldoria-quest)
    (:requirements :strips :typing :negative-preconditions :equality)

    (:types
        object
        location
        character - object
        hero npc - character
        village forest temple clearing market cottage - location
        item - object
        key potion dagger map crystal - item
    )

    (:predicates
        (at ?obj - object ?loc - location)
        (connected ?loc1 - location ?loc2 - location)

        (has ?char - character ?item - item)

        (crystal-lost)
        (crystal-possessed ?char - character)
        (magical-key-possessed ?char - character)
        (dark-warden-guarding)
        (dark-warden-defeated)
        (temple-accessible)
        (hero-blessed)
        (trial-courage-completed)
        (trial-wisdom-completed)
        (hero-health-full)
        (hero-health-partial)
        (forest-spirit-encountered)
        (healing-herbs-collected)
        (dark-warden-hostile)
    )

    (:action move
        :parameters (?h - hero ?from - location ?to - location)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action venture-into-forest
        :parameters (?h - hero ?from - location ?to - clearing)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
            (forest-spirit-encountered)
        )
    )

    (:action seek-advice-elder
        :parameters (?h - hero ?from - location ?to - cottage)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
            (hero-blessed)
        )
    )

    (:action prepare-supplies
        :parameters (?h - hero ?from - location ?to - market ?p - potion ?d - dagger ?m - map)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
            (at ?p ?to)
            (at ?d ?to)
            (at ?m ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
            (has ?h ?p)
            (has ?h ?d)
            (has ?h ?m)
            (not (at ?p ?to))
            (not (at ?d ?to))
            (not (at ?m ?to))
        )
    )

    (:action accept-trial-courage
        :parameters (?h - hero ?loc - clearing)
        :precondition (and
            (at ?h ?loc)
            (forest-spirit-encountered)
            (not (magical-key-possessed ?h))
            (not (trial-courage-completed))
            (not (trial-wisdom-completed))
        )
        :effect (and
            (trial-courage-completed)
            (magical-key-possessed ?h)
        )
    )

    (:action accept-trial-wisdom
        :parameters (?h - hero ?loc - clearing)
        :precondition (and
            (at ?h ?loc)
            (forest-spirit-encountered)
            (not (magical-key-possessed ?h))
            (not (trial-wisdom-completed))
            (not (trial-courage-completed))
        )
        :effect (and
            (trial-wisdom-completed)
            (magical-key-possessed ?h)
        )
    )

    (:action attempt-persuade-spirit
        :parameters (?h - hero ?loc - clearing)
        :precondition (and
            (at ?h ?loc)
            (forest-spirit-encountered)
            (not (magical-key-possessed ?h))
        )
        :effect (and
            (dark-warden-hostile)
        )
    )

    (:action enter-temple
        :parameters (?h - hero ?from - location ?to - temple)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
            (magical-key-possessed ?h)
        )
        :effect (and
            (at ?h ?to)
            (temple-accessible)
            (not (at ?h ?from))
        )
    )

    (:action rest-briefly
        :parameters (?h - hero ?loc - location)
        :precondition (and
            (at ?h ?loc)
        )
        :effect (and
            (hero-health-partial)
            (not (hero-health-full))
        )
    )

    (:action explore-forest-herbs
        :parameters (?h - hero ?loc - location)
        :precondition (and
            (at ?h ?loc)
            (trial-wisdom-completed)
        )
        :effect (and
            (healing-herbs-collected)
        )
    )

    (:action use-healing-potion
        :parameters (?h - hero ?loc - location ?p - potion)
        :precondition (and
            (at ?h ?loc)
            (has ?h ?p)
        )
        :effect (and
            (hero-health-full)
            (not (hero-health-partial))
            (not (has ?h ?p))
        )
    )

    (:action engage-dark-warden
        :parameters (?h - hero ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (temple-accessible)
            (dark-warden-guarding)
            (magical-key-possessed ?h)
        )
        :effect (and
            (dark-warden-defeated)
            (not (dark-warden-guarding))
            (not (dark-warden-hostile))
            (not (crystal-lost))
            (crystal-possessed ?h)
        )
    )

    (:action negotiate-dark-warden
        :parameters (?h - hero ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (temple-accessible)
            (dark-warden-guarding)
            (magical-key-possessed ?h)
        )
        :effect (and
            (dark-warden-hostile)
            (not (dark-warden-defeated))
            ; dark-warden-guarding remains true to reflect ongoing guarding
        )
    )

    (:action calm-dark-warden
        :parameters (?h - hero ?loc - temple)
        :precondition (and
            (at ?h ?loc)
            (dark-warden-hostile)
        )
        :effect (and
            (not (dark-warden-hostile))
            (dark-warden-guarding)
        )
    )

    (:action flee-and-regroup
        :parameters (?h - hero ?from - temple ?to - clearing)
        :precondition (and
            (at ?h ?from)
            (dark-warden-hostile)
            (connected ?from ?to)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
            (hero-health-partial)
            (not (dark-warden-hostile))
        )
    )

    (:action take-crystal-return
        :parameters (?h - hero ?from - temple ?to - village)
        :precondition (and
            (at ?h ?from)
            (crystal-possessed ?h)
            (connected ?from ?to)
            (dark-warden-defeated)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )
)