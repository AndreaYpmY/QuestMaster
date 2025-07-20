(define (problem shadow-of-the-dragon-problem)
    (:domain shadow-of-the-dragon)

    (:objects
        village-of-ardent whispering-forest temple-of-the-sun-entrance forest-edge deeper-whispering-forest base-of-dark-mountains hamlet old-sage-location - location
        common-sword pouch-of-coins healing-potion smoke-bomb protective-enchantment magical-talisman ancient-key spear-of-light - item
        mercenary forest-mage - ally
    )

    (:init
        ;; Player starts at Village of Ardent
        (player-at village-of-ardent)

        ;; Player inventory at start
        (has-item common-sword)
        (has-coins)

        ;; Dragon status
        (dragon-active)

        ;; Temple status
        (temple-sealed)

        ;; Negative literals for clarity
        (not (wolves-active))
        (not (wolves-defeated))
        (not (trap-active))
        (not (trap-triggered))
        (not (temple-unsealed))
        (not (temple-traps-active))
        (not (has-ancient-key))
        (not (has-spear-of-light))
        (not (wounded))
        (not (injured))
        (not (health-restored))
        (not (player-incapacitated))
        (not (merchant-trustworthy))
        (not (merchant-deceptive))
        (not (has-mercenary))
        (not (has-forest-mage))
        (not (has-healing-potion))
        (not (has-smoke-bomb))
        (not (has-magical-amulet))
        (not (has-protective-enchantment))
        (not (has-magical-talisman))
        (not (hamlet-helped))
        (not (dragon-defeated))
        (not (quest-complete))
        (not (knows-key-location))
        (not (knows-temple-traps))
        (not (knows-false-allies-warning))
    )

    (:goal
        (and
            (quest-complete)
            (dragon-defeated)
            (has-spear-of-light)
            (player-at village-of-ardent)
        )
    )
)