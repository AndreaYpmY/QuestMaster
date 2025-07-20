(define (domain shadow-of-the-dragon)
    (:requirements :strips :typing :negative-preconditions)
    (:types
        location character item ally obstacle status - object
    )
    (:constants
        faded-map - item
    )
    (:predicates
        ;; Player location predicate: player is at a location
        (player-at ?l - location) ; Player is at location ?l
        ;; Inventory predicates: player has an item
        (has-item ?i - item) ; Player has item ?i
        ;; Ally presence predicate: ally is present with player
        (ally-present ?a - ally) ; Ally ?a accompanies player
        ;; Knowledge predicates: player has knowledge about something
        (knows-key-location) ; Player knows key is in Whispering Forest
        (knows-temple-traps) ; Player knows about temple traps
        (knows-false-allies-warning) ; Player warned about false allies
        ;; Obstacle predicates: obstacles active or defeated
        (wolves-active) ; Magic wolves are active in Whispering Forest
        (wolves-defeated) ; Magic wolves defeated
        (trap-active) ; Trap in forest clearing is active
        (trap-triggered) ; Trap in forest clearing triggered
        (temple-sealed) ; Temple of the Sun is sealed
        (temple-unsealed) ; Temple of the Sun is unsealed
        (temple-traps-active) ; Temple traps are active
        ;; Key and Spear possession predicates
        (has-ancient-key) ; Player has ancient key
        (has-spear-of-light) ; Player has Spear of Light
        ;; Player status predicates
        (wounded) ; Player is wounded
        (injured) ; Player is injured (minor)
        (health-restored) ; Player health restored
        (player-incapacitated) ; Player incapacitated
        ;; Merchant trustworthiness
        (merchant-trustworthy) ; Merchant is trustworthy
        (merchant-deceptive) ; Merchant is deceptive
        ;; Allies
        (has-mercenary) ; Player has mercenary ally
        (has-forest-mage) ; Player has forest mage ally
        ;; Magical items
        (has-healing-potion) ; Player has healing potion
        (has-smoke-bomb) ; Player has smoke bomb
        (has-magical-amulet) ; Player has magical amulet
        (has-protective-enchantment) ; Player has protective enchantment
        (has-magical-talisman) ; Player has magical talisman
        ;; Side quest status
        (hamlet-helped) ; Hamlet under goblin attack helped
        ;; Dragon status
        (dragon-active) ; Dragon Vharax is active
        (dragon-defeated) ; Dragon Vharax defeated
        ;; Quest completion
        (quest-complete) ; Quest completed successfully
        ;; Player coins count (abstracted as predicate for having coins)
        (has-coins) ; Player has coins (simplified)
    )

    ;; Section 1: Talk to old sage for guidance → Section 2
    (:action talk-to-old-sage
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (has-item faded-map) ; Player receives faded map
            (knows-key-location) ; Player learns key is in Whispering Forest
        )
    )

    ;; Section 1: Visit village merchant → Section 3
    (:action visit-merchant
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            ;; No state change, action kept for narrative progression
        )
    )

    ;; Section 1: Explore village → Section 4
    (:action explore-village
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            ;; No state change, action kept for narrative progression
        )
    )

    ;; Section 2: Head to Whispering Forest → Section 5
    (:action go-to-whispering-forest-from-sage
        :parameters (?from - location ?to - location)
        :precondition (and (player-at ?from) (has-item faded-map))
        :effect (and
            (not (player-at ?from)) ; Leaving previous location
            (player-at ?to) ; Arriving at forest
            (wolves-active) ; Magic wolves present
        )
    )

    ;; Section 2: Visit merchant from sage → Section 3
    (:action visit-merchant-from-sage
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-item faded-map))
        :effect (and
            ;; No state change, action kept for narrative progression
        )
    )

    ;; Section 2: Explore village from sage → Section 4
    (:action explore-village-from-sage
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-item faded-map))
        :effect (and
            ;; No state change, action kept for narrative progression
        )
    )

    ;; Section 3: Buy healing potion → Section 6
    (:action buy-healing-potion
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-coins))
        :effect (and
            (has-healing-potion) ; Player gains healing potion
            (not (has-coins)) ; Coins spent
            (merchant-trustworthy) ; Merchant may be trustworthy after sale
        )
    )

    ;; Section 3: Buy smoke bomb → Section 6
    (:action buy-smoke-bomb
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-coins))
        :effect (and
            (has-smoke-bomb) ; Player gains smoke bomb
            (not (has-coins)) ; Coins spent
            (merchant-trustworthy)
        )
    )

    ;; Section 3: Gather info from merchant → Section 7
    (:action gather-info-merchant
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (knows-temple-traps) ; Player learns about temple traps
            (knows-false-allies-warning) ; Warning about false allies
            (merchant-deceptive) ; Merchant may be deceptive
        )
    )

    ;; Section 3: Decline and leave merchant → Section 2
    (:action decline-merchant
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (has-item faded-map) ; Return to sage knowledge state
        )
    )

    ;; Section 4: Hire mercenary → Section 8
    (:action hire-mercenary
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-coins))
        :effect (and
            (has-mercenary) ; Mercenary joins player
            (not (has-coins)) ; Coins spent
        )
    )

    ;; Section 4: Help hamlet → Section 9
    (:action help-hamlet
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (hamlet-helped) ; Hamlet helped
            (has-magical-amulet) ; Player gains magical amulet
            (not (player-at ?from))
            (player-at ?to) ; Player moves to hamlet location
        )
    )

    ;; Section 4: Ignore side quests → Section 5
    (:action ignore-side-quests
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (wolves-active)
        )
    )

    ;; Section 5: Talk to forest mage → Section 10
    (:action talk-to-forest-mage
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (wolves-active))
        :effect (and
            (has-forest-mage) ; Forest mage ally gained
            (not (wolves-active))
            (wolves-defeated)
        )
    )

    ;; Section 5: Fight magic wolves → Section 11
    (:action fight-magic-wolves
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (wolves-active))
        :effect (and
            (wolves-defeated) ; Wolves defeated
            (not (wolves-active))
        )
    )

    ;; Section 5: Sneak around wolves → Section 12
    (:action sneak-around-wolves
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (wolves-active))
        :effect (and
            (trap-active) ; Trap triggered possibility
            (not (wolves-active))
            (wolves-defeated)
        )
    )

    ;; Section 6: Head to Whispering Forest → Section 5
    (:action head-to-forest-from-merchant
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (wolves-active)
        )
    )

    ;; Section 6: Explore village → Section 4
    (:action explore-village-from-merchant
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            ;; No state change, action kept for narrative progression
        )
    )

    ;; Section 7: Head to Whispering Forest → Section 5
    (:action head-to-forest-from-info
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (wolves-active)
        )
    )

    ;; Section 7: Explore village → Section 4
    (:action explore-village-from-info
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            ;; No state change, action kept for narrative progression
        )
    )

    ;; Section 8: Head to Whispering Forest → Section 5
    (:action head-to-forest-from-mercenary
        :parameters (?from - location ?to - location)
        :precondition (and (player-at ?from) (has-mercenary))
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (wolves-active)
        )
    )

    ;; Section 8: Explore village for side quests → Section 9
    (:action explore-village-for-side-quests
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-mercenary))
        :effect (and
            ;; No state change, action kept for narrative progression
        )
    )

    ;; Section 9: Return to Ardent → Section 4
    (:action return-to-village-from-hamlet
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
        )
    )

    ;; Section 9: Head to Whispering Forest → Section 5
    (:action head-to-forest-from-hamlet
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (wolves-active)
        )
    )

    ;; Section 10: Agree to help forest mage → Section 13
    (:action agree-help-forest-mage
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-forest-mage))
        :effect (and
            (has-ancient-key) ; Key acquired
            (has-protective-enchantment) ; Protective enchantment gained
            (not (wolves-active))
        )
    )

    ;; Section 10: Decline help → Section 12
    (:action decline-help-forest-mage
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-forest-mage))
        :effect (and
            (not (has-forest-mage)) ; Mage not allied
            (trap-active) ; Trap may be active
        )
    )

    ;; Section 10: Fight wolves yourself → Section 11
    (:action fight-wolves-alone
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (wolves-active))
        :effect (and
            (wolves-defeated)
            (not (wolves-active))
        )
    )

    ;; Section 11: Search area for key → Section 14
    (:action search-area-after-wolves
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (wolves-defeated))
        :effect (and
            (has-ancient-key)
            (trap-active)
        )
    )

    ;; Section 11: Seek forest mage → Section 10
    (:action seek-forest-mage-after-wolves
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (wolves-defeated))
        :effect (and
            (has-forest-mage)
        )
    )

    ;; Section 11: Retreat wounded → Section 1R
    (:action retreat-wounded
        :parameters (?from - location ?to - location)
        :precondition (and (player-at ?from) (wounded))
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (wounded)
            (not (has-ancient-key))
        )
    )

    ;; Section 12: Escape after trap → Section 15
    (:action escape-after-trap
        :parameters (?from - location ?to - location)
        :precondition (and (player-at ?from) (trap-triggered))
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (injured)
            (has-ancient-key)
        )
    )

    ;; Section 12: Search for forest mage → Section 10
    (:action search-for-forest-mage-after-trap
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (trap-triggered))
        :effect (and
            (has-forest-mage)
        )
    )

    ;; Section 12: Fail trap and call for help → Section 1F
    (:action fail-trap-call-for-help
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (trap-triggered) (not (injured)))
        :effect (and
            (player-incapacitated)
        )
    )

    ;; Section 13: Exit forest to temple → Section 16
    (:action exit-forest-to-temple
        :parameters (?from - location ?to - location)
        :precondition (and (player-at ?from) (has-ancient-key) (has-forest-mage))
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (temple-unsealed)
            (temple-traps-active)
        )
    )

    ;; Section 13: Rest and prepare → Section 17
    (:action rest-and-prepare-forest
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (health-restored)
        )
    )

    ;; Section 14: Head to temple → Section 16
    (:action head-to-temple-from-forest-clearing
        :parameters (?from - location ?to - location)
        :precondition (and (player-at ?from) (has-ancient-key))
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (temple-unsealed)
            (temple-traps-active)
        )
    )

    ;; Section 14: Explore deeper forest → Section 18
    (:action explore-deeper-forest
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (has-magical-talisman)
            (not (player-at ?from))
            (player-at ?to)
        )
    )

    ;; Section 15: Return to village → Section 17
    (:action return-to-village-from-forest-edge
        :parameters (?from - location ?to - location)
        :precondition (and (player-at ?from) (injured))
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (health-restored)
        )
    )

    ;; Section 15: Proceed to temple → Section 16
    (:action proceed-to-temple-from-forest-edge
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (temple-unsealed)
            (temple-traps-active)
        )
    )

    ;; Section 16: Attempt puzzles → Section 19
    (:action attempt-puzzles
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (not (temple-traps-active))
            (has-spear-of-light)
        )
    )

    ;; Section 16: Explore cautiously → Section 20
    (:action explore-cautiously
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (temple-traps-active)
        )
    )

    ;; Section 16: Call allies for assistance → Section 21
    (:action call-allies-for-assistance
        :parameters (?loc - location)
        :precondition (and (player-at ?loc)
                           (or (has-mercenary) (has-forest-mage)))
        :effect (and
            (not (temple-traps-active))
        )
    )

    ;; Section 17: Proceed to temple → Section 16
    (:action proceed-to-temple-from-rest
        :parameters (?from1 - location ?from2 - location ?to - location)
        :precondition (and (or (player-at ?from1) (player-at ?from2)) (health-restored))
        :effect (and
            (not (player-at ?from1))
            (not (player-at ?from2))
            (player-at ?to)
            (temple-unsealed)
            (temple-traps-active)
        )
    )

    ;; Section 17: Explore village for preparations → Section 4
    (:action explore-village-for-preparations
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            ;; No state change, action kept for narrative progression
        )
    )

    ;; Section 18: Return to temple → Section 16
    (:action return-to-temple-from-deeper-forest
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (temple-unsealed)
            (temple-traps-active)
        )
    )

    ;; Section 18: Rest near forest edge → Section 17
    (:action rest-near-forest-edge
        :parameters (?from - location ?to - location)
        :precondition (player-at ?from)
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (health-restored)
        )
    )

    ;; Section 19: Take Spear and prepare → Section 22
    (:action take-spear-prepare
        :parameters (?from - location ?to - location)
        :precondition (and (player-at ?from) (has-spear-of-light))
        :effect (and
            (not (player-at ?from))
            (player-at ?to)
            (dragon-active)
        )
    )

    ;; Section 19: Search temple for clues → Section 20
    (:action search-temple-for-clues
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (knows-temple-traps)
        )
    )

    ;; Section 20: Attempt puzzles → Section 19
    (:action attempt-puzzles-from-explore
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (has-spear-of-light)
        )
    )

    ;; Section 20: Search for dragon weakness → Section 21
    (:action search-dragon-weakness
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (knows-false-allies-warning)
        )
    )

    ;; Section 21: Solve puzzles with allies → Section 19
    (:action solve-puzzles-with-allies
        :parameters (?loc - location)
        :precondition (and (player-at ?loc)
                           (or (has-mercenary) (has-forest-mage)))
        :effect (and
            (has-spear-of-light)
        )
    )

    ;; Section 21: Search for strategic info → Section 20
    (:action search-strategic-info
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (knows-temple-traps)
        )
    )

    ;; Section 22: Ascend mountains to confront dragon → Section 23
    (:action ascend-mountains
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (has-spear-of-light) (dragon-active))
        :effect (and
            (not (dragon-active))
            (dragon-defeated)
        )
    )

    ;; Section 22: Rest before battle → Section 17
    (:action rest-before-battle
        :parameters (?loc - location)
        :precondition (player-at ?loc)
        :effect (and
            (health-restored)
        )
    )

    ;; Section 23: Celebrate victory → Section 24
    (:action celebrate-victory
        :parameters ()
        :precondition (dragon-defeated)
        :effect (and
            (quest-complete)
        )
    )

    ;; Section 1F: Failure state - incapacitated
    (:action failure-incapacitated
        :parameters ()
        :precondition (player-incapacitated)
        :effect (and
            ;; No further actions possible
        )
    )

    ;; Section 1R: Failure state - retreat wounded without key
    (:action failure-retreat-wounded
        :parameters (?loc - location)
        :precondition (and (player-at ?loc) (wounded) (not (has-ancient-key)))
        :effect (and
            ;; No further actions possible
        )
    )
)