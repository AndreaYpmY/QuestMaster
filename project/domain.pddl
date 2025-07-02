(define (domain dungeon-quest)
    (:requirements :strips :typing)               ; PDDL requirements declaration

    (:types
        location character item - object           ; Basic object hierarchy
        village forest temple - location            ; Specific location types
        hero darkwarden - character                 ; Character types
        crystal key artifact - item                 ; Item types
    )

    (:predicates
        (at ?obj - object ?loc - location)        ; Object/character is at a location
        (connected ?loc1 - location ?loc2 - location) ; Locations are connected
        (has-item ?char - character ?item - item) ; Character possesses an item
        (darkwarden-guarding ?loc - location)      ; Dark Warden is guarding a location
        (key-held ?char - character)                ; Character holds the magical key
        (crystal-lost)                             ; Crystal of Light is lost
        (worthy ?char - character)                 ; Character is deemed worthy
        (defeated ?char - character)               ; Character has been defeated
    )

    (:action visit-whispering-forest
        :parameters (?h - hero ?v - village ?f - forest)
        :precondition (and 
            (at ?h ?v)                             ; Hero is in the village
            (not (crystal-lost))                   ; Crystal is lost
        )
        :effect (and 
            (at ?h ?f)                             ; Hero moves to the Whispering Forest
            (not (at ?h ?v))                       ; Hero is no longer in the village
        )
    )

    (:action gather-information
        :parameters (?h - hero ?v - village)
        :precondition (and 
            (at ?h ?v)                             ; Hero is in the village
            (not (crystal-lost))                   ; Crystal is lost
        )
        :effect (and 
            (worthy ?h)                            ; Hero is now deemed worthy
            (not (at ?h ?v))                       ; Hero is no longer in the village
        )
    )

    (:action seek-forest-spirit
        :parameters (?h - hero ?f - forest)
        :precondition (and 
            (at ?h ?f)                             ; Hero is in the Whispering Forest
            (worthy ?h)                            ; Hero is deemed worthy
        )
        :effect (and 
            (not (crystal-lost))                   ; Crystal is now available
        )
    )

    (:action explore-forest
        :parameters (?h - hero ?f - forest ?a - artifact)
        :precondition (and 
            (at ?h ?f)                             ; Hero is in the Whispering Forest
            (not (crystal-lost))                   ; Crystal is lost
        )
        :effect (and 
            (has-item ?h ?a)                       ; Hero finds an ancient artifact
        )
    )

    (:action prepare-test-of-courage
        :parameters (?h - hero ?v - village)
        :precondition (and 
            (at ?h ?v)                             ; Hero is in the village
            (worthy ?h)                            ; Hero is deemed worthy
        )
        :effect (and 
            (not (at ?h ?v))                       ; Hero is no longer in the village
        )
    )

    (:action prove-worthiness-courage
        :parameters (?h - hero ?m - darkwarden ?f - forest)
        :precondition (and 
            (at ?h ?f)                             ; Hero is in the forest
            (not (crystal-lost))                   ; Crystal is lost
            (darkwarden-guarding ?f)               ; Dark Warden is guarding the forest
        )
        :effect (and 
            (not (darkwarden-guarding ?f))         ; Dark Warden is defeated
            (not (crystal-lost))                   ; Crystal is now available
        )
    )

    (:action prove-worthiness-wisdom
        :parameters (?h - hero ?f - forest)
        :precondition (and 
            (at ?h ?f)                             ; Hero is in the forest
            (not (crystal-lost))                   ; Crystal is lost
        )
        :effect (and 
            (not (crystal-lost))                   ; Crystal is now available
        )
    )

    (:action use-ancient-artifact
        :parameters (?h - hero ?a - artifact ?f - forest)
        :precondition (and 
            (at ?h ?f)                             ; Hero is in the forest
            (has-item ?h ?a)                       ; Hero has the ancient artifact
        )
        :effect (and 
            (not (crystal-lost))                   ; Crystal is now available
        )
    )

    (:action accept-key
        :parameters (?h - hero ?k - key)
        :precondition (and 
            (not (crystal-lost))                   ; Crystal is lost
            (key-held ?h)                          ; Hero has the magical key
        )
        :effect (and 
            (not (crystal-lost))                   ; Crystal is now available
        )
    )

    (:action enter-temple
        :parameters (?h - hero ?t - temple)
        :precondition (and 
            (at ?h ?t)                             ; Hero is at the temple
            (not (crystal-lost))                   ; Crystal is lost
        )
        :effect (and 
            (not (crystal-lost))                   ; Crystal is now available
        )
    )

    (:action engage-battle
        :parameters (?h - hero ?m - darkwarden)
        :precondition (and 
            (not (crystal-lost))                   ; Crystal is lost
            (darkwarden-guarding ?m)               ; Dark Warden is present
        )
        :effect (and 
            (defeated ?m)                          ; Dark Warden is defeated
            (not (crystal-lost))                   ; Crystal is now available
        )
    )

    (:action attempt-diplomacy
        :parameters (?h - hero ?m - darkwarden)
        :precondition (and 
            (not (crystal-lost))                   ; Crystal is lost
            (darkwarden-guarding ?m)               ; Dark Warden is present
        )
        :effect (and 
            (not (crystal-lost))                   ; Crystal is now available
        )
    )
)