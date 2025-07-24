(define (problem shadow-of-the-dragon-problem)
    (:domain shadow-of-the-dragon)

    (:objects
        player1 - player
        roran elara - ally
    )

    (:init
        ;; Player starts at Village of Ardent
        (at player1 village-of-ardent)

        ;; Player inventory at start: common sword and pouch of coins (already constants in domain, no need to declare here)
        (has player1 common-sword)
        (has player1 pouch-coins)

        ;; Dragon is alive at start
        (dragon-alive)

        ;; Temple is sealed at start
        (temple-sealed)

        ;; No map-to-forest initially, so player must talk to old sage to get it
        ;; No ancient-key-found initially

        ;; Allies not present initially, but add ally-present predicates to allow recruiting and loyalty progression
        ;; Place allies initially at their locations to enable seeking them
        (ally-present roran tavern)
        (ally-present elara village-outskirts)

        ;; Allies not loyal initially
        ;; No ally-loyal predicates initially

        ;; No villager trust predicates initially
        ;; No mercenary-distrust initially

        ;; No threats present initially
        ;; No traps active initially

        ;; No player damaged initially
        ;; No rested initially

    )

    (:goal
        (and
            (spear-of-light)
            (dragon-defeated)
            (at player1 dark-mountains-dragon-lair)
        )
    )
)