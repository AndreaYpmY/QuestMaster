(define (domain shadow-of-cronos)
    (:requirements :strips :typing :negative-preconditions)
    (:types
        location character ally enemy gift - object ; Define main object types
    )
    (:predicates
        (at ?c - character ?l - location) ; Character is at location
        (ally-present ?a - ally ?l - location) ; Ally present at location
        (enemy-present ?e - enemy ?l - location) ; Enemy present at location
        (gift-acquired ?g - gift) ; Gift has been acquired
        (gift-locked ?g - gift) ; Gift is locked/unacquired
        (blessing-active ?c - character) ; Athena's blessing active on character
        (knowledge-prophecy) ; Knowledge of Cassandra's prophecy gained
        (trial-overcome ?t - enemy) ; Enemy defeated
        (trial-failed) ; Quest failed state
        (quest-complete) ; Quest success state
        (rift-sealed) ; Rift is sealed
        (rift-open) ; Rift is open
        (gifts-combined) ; Gifts combined for hidden abilities
        (time-progressed) ; Time has progressed (e.g. after prophecy delay)
        (location-is-temple-of-athena ?l - location)
        (location-is-forest-of-periphetes ?l - location)
        (location-is-bandit-wood ?l - location)
        (location-is-temple-of-twin-oracle ?l - location)
        (location-is-cliffside-path ?l - location)
        (location-is-beyond-cliffside-path ?l - location)
        (location-is-cliffside-cave ?l - location)
        (location-is-arena-of-trials ?l - location)
        (location-is-mountain-pass ?l - location)
        (location-is-chamber-of-procrustes ?l - location)
        (location-is-labyrinth-exit ?l - location)
        (location-is-realm-of-deimos ?l - location)
        (location-is-battlefield-of-hector ?l - location)
        (location-is-enchanted-grove ?l - location)
        (location-is-threshold-of-rift ?l - location)
        (location-is-rift-of-neradun ?l - location)
        (ally-is-jason-argeiou ?a - ally)
        (ally-is-cassandra ?a - ally)
        (enemy-is-periphetes ?e - enemy)
        (enemy-is-sinis ?e - enemy)
        (enemy-is-sciron ?e - enemy)
        (enemy-is-cercyon ?e - enemy)
        (enemy-is-phaea ?e - enemy)
        (enemy-is-procrustes ?e - enemy)
        (enemy-is-midnight-minotaur ?e - enemy)
        (enemy-is-deimos ?e - enemy)
        (enemy-is-hector ?e - enemy)
        (enemy-is-medea ?e - enemy)
        (enemy-is-phobos ?e - enemy)
        (enemy-is-cronos ?e - enemy)
        (gift-is-strength ?g - gift)
        (gift-is-agility ?g - gift)
        (gift-is-fortitude ?g - gift)
        (gift-is-endurance ?g - gift)
        (gift-is-wisdom ?g - gift)
        (gift-is-courage ?g - gift)
        (trial-overcome-spiritual-trial)
    )

    ;; Section 1 actions: Starting at Temple of Athena
    (:action journey-to-forest-of-periphetes
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from) ; Theseus at Temple of Athena
            (ally-present ?a ?from) ; Jason present
            (gift-locked ?g) ; Gift of Strength locked
            (blessing-active ?p) ; Athena's blessing active
            (not (trial-overcome ?e)) ; Periphetes not defeated
            (not (trial-failed))
            (not (quest-complete))
            (location-is-temple-of-athena ?from)
            (location-is-forest-of-periphetes ?to)
            (gift-is-strength ?g)
            (enemy-is-periphetes ?e)
        )
        :effect (and
            (not (at ?p ?from)) ; Theseus leaves Temple of Athena
            (at ?p ?to) ; Theseus arrives at Forest of Periphetes
            (not (ally-present ?a ?from))
            (ally-present ?a ?to) ; Jason moves with Theseus
        )
    )

    (:action journey-to-bandit-wood
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (gift-locked ?g) ; Gift of Agility locked
            (blessing-active ?p)
            (not (trial-overcome ?e))
            (not (trial-failed))
            (not (quest-complete))
            (location-is-temple-of-athena ?from)
            (location-is-bandit-wood ?to)
            (gift-is-agility ?g)
            (enemy-is-sinis ?e)
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action visit-cassandra
        :parameters (?p - character ?a1 - ally ?a2 - ally ?from ?to - location)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a1 ?from) ; Jason present
            (not (ally-present ?a2 ?to)) ; Cassandra not yet present
            (location-is-temple-of-athena ?from)
            (location-is-temple-of-twin-oracle ?to)
            (ally-is-jason-argeiou ?a1)
            (ally-is-cassandra ?a2)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a1 ?from))
            (ally-present ?a1 ?to)
            (ally-present ?a2 ?to)
            (time-progressed) ; Time passes due to prophecy visit
        )
    )

    ;; Section 2 actions: Forest of Periphetes - confront Periphetes
    (:action engage-periphetes-combat
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-forest-of-periphetes ?l)
            (enemy-is-periphetes ?e)
            (gift-is-strength ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e) ; Periphetes defeated
            (not (enemy-present ?e ?l))
            (gift-acquired ?g) ; Gift of Strength acquired
            (not (gift-locked ?g))
        )
    )

    (:action lure-periphetes-into-trap
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-forest-of-periphetes ?l)
            (enemy-is-periphetes ?e)
            (gift-is-strength ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g)
            (not (gift-locked ?g))
        )
    )

    ;; Section 3 actions: Bandit Wood - confront Sinis
    (:action dodge-and-weave-sinis
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g1 ?g2 - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g2)
            (blessing-active ?p)
            (location-is-bandit-wood ?l)
            (enemy-is-sinis ?e)
            (gift-is-agility ?g2)
            (not (trial-failed))
            (not (trial-overcome ?e))
            (or (gift-acquired ?g1) (gift-is-strength ?g1)) ; Gift of Strength may or may not be acquired
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g2)
            (not (gift-locked ?g2))
        )
    )

    (:action use-fire-against-sinis
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-bandit-wood ?l)
            (enemy-is-sinis ?e)
            (gift-is-agility ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g)
            (not (gift-locked ?g))
        )
    )

    ;; Section 4 actions: Temple of Twin Oracle - Cassandra's prophecy
    (:action accept-cassandra-prophecy
        :parameters (?p - character ?a1 - ally ?a2 - ally ?l - location)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a1 ?l)
            (ally-present ?a2 ?l)
            (location-is-temple-of-twin-oracle ?l)
            (ally-is-jason-argeiou ?a1)
            (ally-is-cassandra ?a2)
            (not (knowledge-prophecy))
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (knowledge-prophecy)
            (time-progressed)
        )
    )

    (:action decline-cassandra-prophecy-to-periphetes
        :parameters (?p - character ?a1 - ally ?a2 - ally ?from ?to - location ?g - gift)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a1 ?from)
            (ally-present ?a2 ?from)
            (location-is-temple-of-twin-oracle ?from)
            (location-is-forest-of-periphetes ?to)
            (ally-is-jason-argeiou ?a1)
            (ally-is-cassandra ?a2)
            (gift-locked ?g)
            (gift-is-strength ?g)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a1 ?from))
            (ally-present ?a1 ?to)
            (not (ally-present ?a2 ?from))
        )
    )

    (:action decline-cassandra-prophecy-to-sinis
        :parameters (?p - character ?a1 - ally ?a2 - ally ?from ?to - location ?g - gift)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a1 ?from)
            (ally-present ?a2 ?from)
            (location-is-temple-of-twin-oracle ?from)
            (location-is-bandit-wood ?to)
            (ally-is-jason-argeiou ?a1)
            (ally-is-cassandra ?a2)
            (gift-locked ?g)
            (gift-is-agility ?g)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a1 ?from))
            (ally-present ?a1 ?to)
            (not (ally-present ?a2 ?from))
        )
    )

    ;; Section 5 actions: After defeating Periphetes by combat
    (:action proceed-to-bandit-wood-after-periphetes
        :parameters (?p - character ?a - ally ?from ?to - location ?g1 ?g2 - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (gift-acquired ?g1)
            (gift-locked ?g2)
            (location-is-forest-of-periphetes ?from)
            (location-is-bandit-wood ?to)
            (gift-is-strength ?g1)
            (gift-is-agility ?g2)
            (enemy-is-periphetes ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-cliffs-after-periphetes
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (gift-acquired ?g)
            (location-is-forest-of-periphetes ?from)
            (location-is-cliffside-path ?to)
            (gift-is-strength ?g)
            (enemy-is-periphetes ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    ;; Section 6 actions: After defeating Periphetes by trap
    (:action proceed-to-bandit-wood-after-trap
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (gift-acquired ?g)
            (location-is-forest-of-periphetes ?from)
            (location-is-bandit-wood ?to)
            (gift-is-strength ?g)
            (enemy-is-periphetes ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-arena-after-trap
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (gift-acquired ?g)
            (location-is-forest-of-periphetes ?from)
            (location-is-arena-of-trials ?to)
            (gift-is-strength ?g)
            (enemy-is-periphetes ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    ;; Section 7 actions: After defeating Sinis by dodge
    (:action proceed-to-mountain-pass-after-sinis
        :parameters (?p - character ?a - ally ?from ?to - location ?g1 ?g2 - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (gift-acquired ?g2)
            (location-is-bandit-wood ?from)
            (location-is-mountain-pass ?to)
            (gift-is-agility ?g2)
            (enemy-is-sinis ?e)
            (not (trial-failed))
            (not (quest-complete))
            (or (gift-acquired ?g1) (gift-is-strength ?g1))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-cliffs-after-sinis
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (gift-acquired ?g)
            (location-is-bandit-wood ?from)
            (location-is-cliffside-path ?to)
            (gift-is-agility ?g)
            (enemy-is-sinis ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    ;; Section 8 actions: After defeating Sinis by fire
    (:action proceed-to-mountain-pass-after-fire
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (gift-acquired ?g)
            (location-is-bandit-wood ?from)
            (location-is-mountain-pass ?to)
            (gift-is-agility ?g)
            (enemy-is-sinis ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-arena-after-fire
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (gift-acquired ?g)
            (location-is-bandit-wood ?from)
            (location-is-arena-of-trials ?to)
            (gift-is-agility ?g)
            (enemy-is-sinis ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    ;; Section 9 actions: After accepting Cassandra's prophecy
    (:action proceed-to-periphetes-after-prophecy
        :parameters (?p - character ?a1 - ally ?a2 - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a1 ?from)
            (ally-present ?a2 ?from)
            (knowledge-prophecy)
            (location-is-temple-of-twin-oracle ?from)
            (location-is-forest-of-periphetes ?to)
            (ally-is-jason-argeiou ?a1)
            (ally-is-cassandra ?a2)
            (gift-locked ?g)
            (gift-is-strength ?g)
            (enemy-is-periphetes ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a2 ?from))
            (ally-present ?a1 ?to)
        )
    )

    (:action proceed-to-sinis-after-prophecy
        :parameters (?p - character ?a1 - ally ?a2 - ally ?from ?to - location ?g - gift ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a1 ?from)
            (ally-present ?a2 ?from)
            (knowledge-prophecy)
            (location-is-temple-of-twin-oracle ?from)
            (location-is-bandit-wood ?to)
            (ally-is-jason-argeiou ?a1)
            (ally-is-cassandra ?a2)
            (gift-locked ?g)
            (gift-is-agility ?g)
            (enemy-is-sinis ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a2 ?from))
            (ally-present ?a1 ?to)
        )
    )

    (:action proceed-to-arena-after-prophecy
        :parameters (?p - character ?a1 - ally ?a2 - ally ?from ?to - location)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a1 ?from)
            (ally-present ?a2 ?from)
            (knowledge-prophecy)
            (location-is-temple-of-twin-oracle ?from)
            (location-is-arena-of-trials ?to)
            (ally-is-jason-argeiou ?a1)
            (ally-is-cassandra ?a2)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a2 ?from))
            (ally-present ?a1 ?to)
        )
    )

    ;; Section 10 actions: Cliffside path - confront Sciron
    (:action outmaneuver-sciron
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-cliffside-path ?l)
            (enemy-is-sciron ?e)
            (gift-is-endurance ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g)
            (not (gift-locked ?g))
        )
    )

    (:action parley-sciron
        :parameters (?p - character ?a - ally ?e - enemy ?from ?to - location)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (enemy-present ?e ?from)
            (location-is-cliffside-path ?from)
            (location-is-beyond-cliffside-path ?to)
            (ally-is-jason-argeiou ?a)
            (enemy-is-sciron ?e)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
            (enemy-present ?e ?from) ; Sciron still alive and hostile
        )
    )

    ;; Section 11 actions: Arena of Trials - confront Cercyon
    (:action engage-cercyon-wrestling
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-arena-of-trials ?l)
            (enemy-is-cercyon ?e)
            (gift-is-fortitude ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g)
            (not (gift-locked ?g))
        )
    )

    (:action evade-cercyon-agility
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-arena-of-trials ?l)
            (enemy-is-cercyon ?e)
            (gift-is-fortitude ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g)
            (not (gift-locked ?g))
        )
    )

    ;; Section 12 actions: Mountain Pass - confront Phaea
    (:action dodge-boar-charge
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-mountain-pass ?l)
            (enemy-is-phaea ?e)
            (gift-is-courage ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g)
            (not (gift-locked ?g))
        )
    )

    (:action trap-phaea
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-mountain-pass ?l)
            (enemy-is-phaea ?e)
            (gift-is-courage ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g)
            (not (gift-locked ?g))
        )
    )

    ;; Section 13 actions: After outmaneuvering Sciron
    (:action proceed-to-arena-after-sciron
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-cliffside-path ?from)
            (location-is-arena-of-trials ?to)
            (enemy-is-sciron ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-mountain-pass-after-sciron
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-cliffside-path ?from)
            (location-is-mountain-pass ?to)
            (enemy-is-sciron ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    ;; Section 14 actions: After parley with Sciron
    (:action proceed-to-arena-after-parley
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (enemy-present ?e ?from)
            (location-is-beyond-cliffside-path ?from)
            (location-is-arena-of-trials ?to)
            (enemy-is-sciron ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
        )
    )

    (:action find-hidden-trial-endurance
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (location-is-beyond-cliffside-path ?from)
            (location-is-cliffside-cave ?to)
            (gift-locked ?g)
            (gift-is-endurance ?g)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (trial-overcome-spiritual-trial)
            (gift-acquired ?g)
            (not (gift-locked ?g))
            (ally-present ?a ?to)
        )
    )

    ;; Section 15 actions: After wrestling Cercyon
    (:action proceed-to-procrustes-after-cercyon
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-arena-of-trials ?from)
            (location-is-chamber-of-procrustes ?to)
            (enemy-is-cercyon ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-mountain-pass-after-cercyon
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-arena-of-trials ?from)
            (location-is-mountain-pass ?to)
            (enemy-is-cercyon ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    ;; Section 16 actions: After evading Cercyon
    (:action proceed-to-procrustes-after-evade
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-arena-of-trials ?from)
            (location-is-chamber-of-procrustes ?to)
            (enemy-is-cercyon ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-mountain-pass-after-evade
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-arena-of-trials ?from)
            (location-is-mountain-pass ?to)
            (enemy-is-cercyon ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    ;; Section 17 actions: After defeating Phaea by dodge
    (:action proceed-to-procrustes-after-phaea
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-mountain-pass ?from)
            (location-is-chamber-of-procrustes ?to)
            (enemy-is-phaea ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-sciron-after-phaea
        :parameters (?p - character ?a - ally ?from ?to - location ?e1 - enemy ?e2 - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e1)
            (location-is-mountain-pass ?from)
            (location-is-cliffside-path ?to)
            (enemy-is-phaea ?e1)
            (enemy-is-sciron ?e2)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
            (enemy-present ?e2 ?to)
        )
    )

    ;; Section 18 actions: After trapping Phaea
    (:action proceed-to-procrustes-after-trap-phaea
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-mountain-pass ?from)
            (location-is-chamber-of-procrustes ?to)
            (enemy-is-phaea ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (not (ally-present ?a ?from))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-cliffs-after-trap-phaea
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-mountain-pass ?from)
            (location-is-cliffside-path ?to)
            (enemy-is-phaea ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
        )
    )

    ;; Section 19 actions: After seeking another way for Endurance gift
    (:action overcome-spiritual-trial
        :parameters (?p - character ?a - ally ?from ?to - location ?g - gift)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (location-is-cliffside-cave ?from)
            (location-is-arena-of-trials ?to)
            (gift-locked ?g)
            (gift-is-endurance ?g)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (trial-overcome-spiritual-trial)
            (gift-acquired ?g)
            (not (gift-locked ?g))
            (ally-present ?a ?to)
        )
    )

    (:action proceed-to-mountain-pass-after-spiritual-trial
        :parameters (?p - character ?a - ally ?from ?to - location)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome-spiritual-trial)
            (location-is-cliffside-cave ?from)
            (location-is-mountain-pass ?to)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
        )
    )

    ;; Section 20 actions: After facing Procrustes
    (:action overcome-procrustes
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (gift-locked ?g)
            (blessing-active ?p)
            (location-is-chamber-of-procrustes ?l)
            (enemy-is-procrustes ?e)
            (gift-is-wisdom ?g)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (gift-acquired ?g)
            (not (gift-locked ?g))
        )
    )

    (:action proceed-to-labyrinth
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-chamber-of-procrustes ?from)
            (location-is-labyrinth-exit ?to)
            (enemy-is-procrustes ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
        )
    )

    ;; Section 21 actions: After defeating Midnight Minotaur
    (:action defeat-midnight-minotaur
        :parameters (?p - character ?a - ally ?e - enemy ?l - location)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (location-is-labyrinth-exit ?l)
            (enemy-is-midnight-minotaur ?e)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
        )
    )

    (:action proceed-to-deimos
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-labyrinth-exit ?from)
            (location-is-realm-of-deimos ?to)
            (enemy-is-midnight-minotaur ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
        )
    )

    ;; Section 22 actions: Confront Deimos
    (:action defeat-deimos
        :parameters (?p - character ?a - ally ?e - enemy ?l - location)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (location-is-realm-of-deimos ?l)
            (enemy-is-deimos ?e)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
        )
    )

    (:action fail-against-deimos
        :parameters (?e - enemy)
        :precondition (not (trial-overcome ?e))
        :effect (and
            (trial-failed)
        )
    )

    (:action proceed-to-hector
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-realm-of-deimos ?from)
            (location-is-battlefield-of-hector ?to)
            (enemy-is-deimos ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
        )
    )

    ;; Section 23 actions: Confront Hector
    (:action defeat-hector
        :parameters (?p - character ?a - ally ?e - enemy ?l - location)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (location-is-battlefield-of-hector ?l)
            (enemy-is-hector ?e)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
        )
    )

    (:action fail-against-hector
        :parameters (?e - enemy)
        :precondition (not (trial-overcome ?e))
        :effect (and
            (trial-failed)
        )
    )

    (:action proceed-to-medea
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-battlefield-of-hector ?from)
            (location-is-enchanted-grove ?to)
            (enemy-is-hector ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
        )
    )

    ;; Section 24 actions: Confront Medea
    (:action defeat-medea
        :parameters (?p - character ?a - ally ?e - enemy ?l - location)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (location-is-enchanted-grove ?l)
            (enemy-is-medea ?e)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
        )
    )

    (:action fail-against-medea
        :parameters (?e - enemy)
        :precondition (not (trial-overcome ?e))
        :effect (and
            (trial-failed)
        )
    )

    (:action proceed-to-phobos
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-enchanted-grove ?from)
            (location-is-threshold-of-rift ?to)
            (enemy-is-medea ?e)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
        )
    )

    ;; Section 26 actions: Confront Phobos
    (:action defeat-phobos
        :parameters (?p - character ?a - ally ?e - enemy ?l - location)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (location-is-threshold-of-rift ?l)
            (enemy-is-phobos ?e)
            (not (trial-failed))
            (not (trial-overcome ?e))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
        )
    )

    (:action proceed-to-rift
        :parameters (?p - character ?a - ally ?from ?to - location ?e - enemy)
        :precondition (and
            (at ?p ?from)
            (ally-present ?a ?from)
            (trial-overcome ?e)
            (location-is-threshold-of-rift ?from)
            (location-is-rift-of-neradun ?to)
            (enemy-is-phobos ?e)
            (not (trial-failed))
            (not (quest-complete))
            (not (rift-sealed))
        )
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
            (ally-present ?a ?to)
            (rift-open)
            (not (rift-sealed))
        )
    )

    ;; Section 27 actions: Final confrontation with Cronos
    (:action defeat-cronos
        :parameters (?p - character ?a - ally ?e - enemy ?l - location ?g1 ?g2 ?g3 ?g4 ?g5 - gift)
        :precondition (and
            (at ?p ?l)
            (ally-present ?a ?l)
            (enemy-present ?e ?l)
            (location-is-rift-of-neradun ?l)
            (enemy-is-cronos ?e)
            (gift-acquired ?g1)
            (gift-acquired ?g2)
            (gift-acquired ?g3)
            (gift-acquired ?g4)
            (gift-acquired ?g5)
            (gift-is-strength ?g1)
            (gift-is-agility ?g2)
            (gift-is-fortitude ?g3)
            (gift-is-endurance ?g4)
            (gift-is-wisdom ?g5)
            (not (trial-failed))
            (not (quest-complete))
        )
        :effect (and
            (trial-overcome ?e)
            (not (enemy-present ?e ?l))
            (rift-sealed)
            (not (rift-open))
            (quest-complete)
        )
    )

    (:action fail-against-cronos
        :parameters (?e - enemy)
        :precondition (not (trial-overcome ?e))
        :effect (and
            (trial-failed)
        )
    )
)