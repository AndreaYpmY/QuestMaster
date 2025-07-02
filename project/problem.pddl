Here is a complete example of how to generate a PDDL problem from the given narrative:
```pddl
; Crystal Domain Problem

; Define the domain and its requirements
(define (problem crystal-domain)
  (:requirements :strips :typing :negative-preconditions)

  ; Define the types in the domain
  (:types
    location - object
    person - entity
    entity - object
    object - object
    key - object
    temple - location
    clearing - location
    puzzle-room - location
    hero - person
    forest-spirit - entity
    dark-warden - entity
    crystal-of-light - object)

  ; Define the predicates in the domain
  (:predicates
    (in ?loc - location) ; Object is at location
    (has-key ?h - person ?k - key) ; Person has key
    (in-village ?h - person) ; Person in village
    (lost ?o - object) ; Object lost
    (guards-temple ?d - entity) ; Entity guards temple
    (solved-puzzle ?p - puzzle-room) ; Puzzle solved
    (possessed-crystal ?h - person ?c - crystal-of-light) ; Person possesses crystal
    (in-clearing ?h - person ?c - clearing) ; Person in clearing
    (in-temple ?h - person ?t - temple) ; Person in temple
    (approached ?h - person ?f - forest-spirit ?c - clearing) ; Person approached forest spirit
    (solved-puzzle ?p - puzzle-room) ; Puzzle solved
    (possessed-crystal ?h - person ?c - crystal-of-light)
    (guarded-by-dark-warden ?t - temple ?d - dark-warden) ; Temple guarded by dark warden
    (present-in-clearing ?f - forest-spirit ?c - clearing) ; Forest spirit present in clearing
  )

  ; Define the actions in the domain
  (:action take-key
    :parameters (?h - person ?k - key)
    :precondition (and 
      (in ?h - person village)
      (has-key ?h - person ?k - key)
      (not (in-temple ?h - person temple))
    )
    :effect (and 
      (in-temple ?h - person temple)
      (lost ?k - key)
    )
  )

  (:action approach-forest-spirit
    :parameters (?h - person ?f - forest-spirit ?c - clearing)
    :precondition (and 
      (in-clearing ?h - person ?c - clearing)
      (present-in-clearing ?f - forest-spirit ?c - clearing)
      (not (approached ?h - person ?f - forest-spirit ?c - clearing))
    )
    :effect (and 
      (approached ?h - person ?f - forest-spirit ?c - clearing)
      (in-clearing ?h - person ?c - clearing)
    )
  )

  (:action solve-puzzle
    :parameters (?p - puzzle-room)
    :precondition (and 
      (in-temple ?hero temple)
      (solved-puzzle ?p - puzzle-room)
      (not (possessed-crystal ?hero temple))
    )
    :effect (and 
      (in-clearing ?hero clearing)
      (solved-puzzle ?p - puzzle-room)
      (possessed-crystal ?hero temple)
    )
  )

  (:action leave-clearing
    :parameters (?h - person)
    :precondition (and 
      (in-clearing ?h - person ?c - clearing)
      (not (approached ?h - person ?f - forest-spirit ?c - clearing))
    )
    :effect (and 
      (in-village ?h - person)
      (lost ?k - key)
    )
  )

  (:action leave-temple
    :parameters (?h - person)
    :precondition (and 
      (in-temple ?h - person temple)
      (not (possessed-crystal ?hero temple))
    )
    :effect (and 
      (in-village ?h - person)
      (lost ?k - key)
    )
  )

  (:action possessed-crystal
    :parameters (?h - person ?c - crystal-of-light)
    :precondition (and 
      (in-temple ?h - person temple)
      (possessed-crystal ?h - person ?c - crystal-of-light)
    )
    :effect (and 
      (in-village ?h - person)
      (lost ?k - key)
    )
  )

  (:action guarded-by-dark-warden
    :parameters (?t - temple ?d - dark-warden)
    :precondition (and 
      (in-temple ?hero temple)
      (guarded-by-dark-warden ?t - temple ?d - dark-warden)
    )
    :effect (and 
      (in-village ?h - person)
      (lost ?k - key)
    )
  )

  (:action approached
    :parameters (?h - person ?f - forest-spirit ?c - clearing)
    :precondition (and 
      (in-clearing ?h - person ?c - clearing)
      (present-in-clearing ?f - forest-spirit ?c - clearing)
      (not (approached ?h - person ?f - forest-spirit ?c - clearing))
    )
    :effect (and 
      (approached ?h - person ?f - forest-spirit ?c - clearing)
      (in-clearing ?h - person ?c - clearing)
    )
  )

)

; Define the initial state of the problem
(define (problem crystal-of-light-init)

  ; Define the domain and its requirements
  (:requirements :strips :typing :negative-preconditions)

  ; Define the types in the domain
  (:types
    location - object
    person - entity
    entity - object
    object - object
    key - object
    temple - location
    clearing - location
    puzzle-room - location
    hero - person
    forest-spirit - entity
    dark-warden - entity
    crystal-of-light - object)

  ; Define the predicates in the domain
  (:predicates
    (in-village ?h - person) ; Person in village
    (lost key)
    (in-clearing ?h - person ?c - clearing) ; Person in clearing
    (solved-puzzle ?p - puzzle-room) ; Puzzle solved
    (possessed-crystal ?h - person ?c - crystal-of-light) ; Person possesses crystal
    (guarded-by-dark-warden ?t - temple ?d - dark-warden) ; Temple guarded by dark warden
    (present-in-clearing ?f - forest-spirit ?c - clearing) ; Forest spirit present in clearing
  )

  ; Define the actions in the domain
  (:action take-key
    :parameters (?h - person ?k - key)
    :precondition (and 
      (in ?h - person village)
      (has-key ?h - person ?k - key)
      (not (in-temple ?h - person temple))
    )
    :effect (and 
      (in-temple ?h - person temple)
      (lost ?k - key)
    )
  )

  (:action approach-forest-spirit
    :parameters (?h - person ?f - forest-spirit ?c - clearing)
    :precondition (and 
      (in-clearing ?h - person ?c - clearing)
      (present-in-clearing ?f - forest-spirit ?c - clearing)
      (not (approached ?h - person ?f - forest-spirit ?c - clearing))
    )
    :effect (and 
      (approached ?h - person ?f - forest-spirit ?c - clearing)
      (in-clearing ?h - person ?c - clearing)
    )
  )

  (:action solve-puzzle
    :parameters (?p - puzzle-room)
    :precondition (and 
      (in-temple ?hero temple)
      (solved-puzzle ?p - puzzle-room)
      (not (possessed-crystal ?hero temple))
    )
    :effect (and 
      (in-clearing ?hero clearing)
      (solved-puzzle ?p - puzzle-room)
      (possessed-crystal ?hero temple)
    )
  )

  (:action leave-clearing
    :parameters (?h - person)
    :precondition (and 
      (in-clearing ?h - person ?c - clearing)
      (not (approached ?h - person ?f - forest-spirit ?c - clearing))
    )
    :effect (and 
      (in-village ?h - person)
      (lost ?k - key)
    )
  )

  (:action leave-temple
    :parameters (?h - person)
    :precondition (and 
      (in-temple ?h - person temple)
      (not (possessed-crystal ?hero temple))
    )
    :effect (and 
      (in-village ?h - person)
      (lost ?k - key)
    )
  )

  (:action possessed-crystal
    :parameters (?h - person ?c - crystal-of-light)
    :precondition (and 
      (in-temple ?h - person temple)
      (possessed-crystal ?h - person ?c - crystal-of-light)
    )
    :effect (and 
      (in-village ?h - person)
      (lost ?k - key)
    )
  )

  (:action guarded-by-dark-warden
    :parameters (?t - temple ?d - dark-warden)
    :precondition (and 
      (in-temple ?hero temple)
      (guarded-by-dark-warden ?t - temple ?d - dark-warden)
    )
    :effect (and 
      (in-village ?h - person)
      (lost ?k - key)
    )
  )

  (:action approached
    :parameters (?h - person ?f - forest-spirit ?c - clearing)
    :precondition (and 
      (in-clearing ?h - person ?c - clearing)
      (present-in-clearing ?f - forest-spirit ?c - clearing)
      (not (approached ?h - person ?f - forest-spirit ?c - clearing))
    )
    :effect (and 
      (approached ?h - person ?f - forest-spirit ?c - clearing)
      (in-clearing ?h - person ?c - clearing)
    )
  )

)

; Define the initial state of the problem
(define (initial-state)
  (list
   (make-fact :in-village ?hero temple)
   (make-fact :lost key)
   (make-fact :solved-puzzle puzzle-room1)
   (make-fact :possessed-crystal ?hero crystal-of-light)
   (make-fact :guarded-by-dark-warden temple dark-warden)
  )
)

; Print the problem
(print-problem crystal-domain initial-state)
```
This code defines a PDDL problem with the following elements:

*   The `crystal-domain` domain, which includes the types and predicates of the problem.
*   The `crystal-of-light-init` initial state, which represents the initial conditions of the problem.

The `print-problem` function is used to print the problem in a human-readable format.