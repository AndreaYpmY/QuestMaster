(define (problem shadow-of-cronos-problem)
    (:domain shadow-of-cronos)

    (:objects
        theseus-leontos - character                      ; The main hero
        jason-argeiou cassandra - ally                   ; Allies accompanying Theseus
        periphetes sinis sciron cercyon phaea procrustes midnight-minotaur deimos hector medea phobos cronos - enemy  ; Enemies and bosses
        temple-of-athena forest-of-periphetes bandit-wood temple-of-twin-oracle cliffside-path beyond-cliffside-path cliffside-cave arena-of-trials mountain-pass chamber-of-procrustes labyrinth-exit realm-of-deimos battlefield-of-hector enchanted-grove threshold-of-rift rift-of-neradun - location  ; Locations in Valyria
        gift-of-strength gift-of-agility gift-of-endurance gift-of-fortitude gift-of-wisdom - gift  ; The Five Gifts of Helios except courage
    )

    (:init
        (at theseus-leontos temple-of-athena)                          ; Theseus starts at the Temple of Athena
        (ally-present jason-argeiou temple-of-athena)                  ; Jason is present with Theseus at the temple
        ; Cassandra not present at temple-of-athena to allow visit-cassandra action
        ; Cassandra initially not present anywhere (will be introduced by visit-cassandra)
        (enemy-present periphetes forest-of-periphetes)                ; Periphetes guards Forest of Periphetes
        (enemy-present sinis bandit-wood)                              ; Sinis guards Bandit Wood
        (enemy-present sciron cliffside-path)                          ; Sciron guards Cliffside Path
        (enemy-present cercyon arena-of-trials)                        ; Cercyon in Arena of Trials
        (enemy-present phaea mountain-pass)                            ; Phaea in Mountain Pass
        (enemy-present procrustes chamber-of-procrustes)               ; Procrustes in Chamber of Procrustes
        (enemy-present midnight-minotaur labyrinth-exit)               ; Midnight Minotaur at Labyrinth exit
        (enemy-present deimos realm-of-deimos)                         ; Deimos in Realm of Deimos
        (enemy-present hector battlefield-of-hector)                   ; Hector in Battlefield of Hector
        (enemy-present medea enchanted-grove)                          ; Medea in Enchanted Grove
        (enemy-present phobos threshold-of-rift)                       ; Phobos at Threshold of Rift
        (enemy-present cronos rift-of-neradun)                         ; Cronos in Rift of Neradun
        (gift-locked gift-of-strength)                                 ; All gifts initially locked except courage removed
        (gift-locked gift-of-agility)
        (gift-locked gift-of-endurance)
        (gift-locked gift-of-fortitude)
        (gift-locked gift-of-wisdom)
        (blessing-active theseus-leontos)                              ; Athena's blessing active on Theseus

        ; Location type predicates for all locations
        (location-is-temple-of-athena temple-of-athena)
        (location-is-forest-of-periphetes forest-of-periphetes)
        (location-is-bandit-wood bandit-wood)
        (location-is-temple-of-twin-oracle temple-of-twin-oracle)
        (location-is-cliffside-path cliffside-path)
        (location-is-beyond-cliffside-path beyond-cliffside-path)
        (location-is-cliffside-cave cliffside-cave)
        (location-is-arena-of-trials arena-of-trials)
        (location-is-mountain-pass mountain-pass)
        (location-is-chamber-of-procrustes chamber-of-procrustes)
        (location-is-labyrinth-exit labyrinth-exit)
        (location-is-realm-of-deimos realm-of-deimos)
        (location-is-battlefield-of-hector battlefield-of-hector)
        (location-is-enchanted-grove enchanted-grove)
        (location-is-threshold-of-rift threshold-of-rift)
        (location-is-rift-of-neradun rift-of-neradun)

        ; Ally type predicates
        (ally-is-jason-argeiou jason-argeiou)
        (ally-is-cassandra cassandra)

        ; Enemy type predicates
        (enemy-is-periphetes periphetes)
        (enemy-is-sinis sinis)
        (enemy-is-sciron sciron)
        (enemy-is-cercyon cercyon)
        (enemy-is-phaea phaea)
        (enemy-is-procrustes procrustes)
        (enemy-is-midnight-minotaur midnight-minotaur)
        (enemy-is-deimos deimos)
        (enemy-is-hector hector)
        (enemy-is-medea medea)
        (enemy-is-phobos phobos)
        (enemy-is-cronos cronos)

        ; Gift type predicates
        (gift-is-strength gift-of-strength)
        (gift-is-agility gift-of-agility)
        (gift-is-endurance gift-of-endurance)
        (gift-is-fortitude gift-of-fortitude)
        (gift-is-wisdom gift-of-wisdom)

        ; Ensure trial-failed and quest-complete are not true initially (not present)
    )

    (:goal
        (and
            (quest-complete)                                           ; Quest must be completed
            (rift-sealed)                                              ; Rift must be sealed
            (trial-overcome cronos)                                    ; Cronos defeated
            (gift-acquired gift-of-strength)                           ; All five gifts acquired except courage
            (gift-acquired gift-of-agility)
            (gift-acquired gift-of-endurance)
            (gift-acquired gift-of-fortitude)
            (gift-acquired gift-of-wisdom)
            (at theseus-leontos rift-of-neradun)                       ; Theseus at Rift location
            (ally-present jason-argeiou rift-of-neradun)               ; Jason present at Rift
        )
    )
)