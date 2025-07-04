(define (domain crystal-quest)
    (:requirements :strips :typing :negative-preconditions)

    (:types
        location character item - object
        hero - character
        crystal key - item
        warden - character
    )

    (:predicates
        (at ?char - character ?loc - location)
        (has ?char - character ?item - item)
        (defeated ?enemy - warden)
        (temple-accessible ?h - hero)
        (forest-spirit-helped)
        (connected ?from - location ?to - location)
        (forest-spirit-location ?loc - location)
        (dark-warden-location ?loc - location)
    )

    (:action travel
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

    (:action prove-worthiness-to-forest-spirit
        :parameters (?h - hero ?loc - location ?k - key)
        :precondition (and
            (at ?h ?loc)
            (forest-spirit-location ?loc)
            (not (has ?h ?k))
            (not (forest-spirit-helped))
        )
        :effect (and
            (has ?h ?k)
            (forest-spirit-helped)
        )
    )

    (:action travel-to-temple
        :parameters (?h - hero ?from - location ?to - location ?k - key)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
            (has ?h ?k)
            (forest-spirit-helped)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
            (temple-accessible ?h)
        )
    )

    (:action enter-temple
        :parameters (?h - hero ?from - location ?to - location ?k - key)
        :precondition (and
            (at ?h ?from)
            (connected ?from ?to)
            (has ?h ?k)
            (temple-accessible ?h)
        )
        :effect (and
            (at ?h ?to)
            (not (at ?h ?from))
        )
    )

    (:action defeat-dark-warden
        :parameters (?h - hero ?loc - location ?w - warden ?c - crystal)
        :precondition (and
            (at ?h ?loc)
            (dark-warden-location ?loc)
            (not (defeated ?w))
        )
        :effect (and
            (defeated ?w)
            (has ?h ?c)
        )
    )
) 
