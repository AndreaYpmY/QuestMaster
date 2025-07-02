(define (domain crystal-domain)
  (:requirements :strips :typing :negative-preconditions)

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

(define (problem crystal-of-light-init)

  (defparam :domain crystal-domain
    ((hero -person)
     (forest-spirit -entity)
     (temple -location)
     (crystal-of-light -object)))

  (defparam :objects crystal-of-light
    (key -object))

  (defparam :locations temple
    (clearing -location)
    (statue -location))

  (defparam :actions
    (take-key (hero key) temple)
    (approach-forest-spirit (hero forest-spirit clearing) temple)
    (solve-puzzle (hero temple puzzle-room))
    (leave-clearing (hero clearing))
    (leave-temple (hero temple))
    (possessed-crystal (hero temple crystal-of-light))
    (guarded-by-dark-warden (temple dark-warden))
    (approached (hero forest-spirit clearing))
  )

  (defparam :predicates
    (in-village (hero village))
    (lost key)
    (in-clearing (hero clearing))
    (solved-puzzle (hero temple))
    (possessed-crystal (hero temple crystal-of-light))
    (guarded-by-dark-warden (temple dark-warden))
    (present-in-clearing (forest-spirit clearing))
  )

  (defparam :init
    ((hero in-village)
     (crystal-of-light lost)
     (dark-warden guards-temple)
     (forest-spirit present-in-clearing)))
)