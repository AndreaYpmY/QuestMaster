(define (domain shadow-of-the-dragon)
    (:requirements :strips :typing :negative-preconditions)
    (:types
        player npc item location ally obstacle - object
    )
    (:constants
        magic-wolves - obstacle
        village-of-ardent whispering-forest tavern village-outskirts temple-of-the-sun-entrance temple-of-the-sun-inner-sanctum temple-of-the-sun-altar-chamber temple-of-the-sun-near-exit temple-of-the-sun dark-mountains-dragon-lair - location
        healing-potion smoke-bomb enchanted-arrow common-sword pouch-coins - item
        herb crystal scrolls artifacts - item
    )
    (:predicates
        ;; Player location
        (at ?p - player ?l - location) ; player ?p is at location ?l
        ;; Player inventory
        (has ?p - player ?i - item) ; player ?p has item ?i
        ;; Ally presence and loyalty
        (ally-present ?a - ally ?l - location) ; ally ?a is present at location ?l
        (ally-loyal ?a - ally) ; ally ?a is loyal to player
        ;; Obstacles and threats
        (trap-active ?o - obstacle ?l - location) ; obstacle ?o is active at location ?l
        (trap-disarmed ?o - obstacle ?l - location) ; obstacle ?o is disarmed at location ?l
        (threat-present ?o - obstacle ?l - location) ; threat ?o (e.g. magic wolves) present at location ?l
        (threat-defeated ?o - obstacle ?l - location) ; threat ?o defeated at location ?l
        ;; Quest progress predicates
        (map-to-forest) ; player has map to Whispering Forest
        (ancient-key-found) ; player has found ancient key
        (temple-sealed) ; temple is sealed
        (temple-open) ; temple is open
        (spear-of-light) ; player has Spear of Light
        (elara-favor) ; player accepted Elara's favor
        (elara-ally) ; Elara is ally and loyal
        (roran-ally) ; Roran is ally and loyal
        (villager-trust-high) ; villagers trust player
        (villager-trust-low) ; villagers distrust player
        (player-damaged) ; player is wounded/damaged
        (dragon-alive) ; dragon Vharax is alive
        (dragon-defeated) ; dragon Vharax defeated
        (mercenary-distrust) ; mercenary distrusts player
        (forest-mage-ally) ; forest mage ally present (alias for elara-ally)
        (in-combat) ; player currently in combat
        (rested) ; player rested and healed
        (quest-completed) ; quest completion marker
    )

    ;; Section 1 actions: initial choices in Village of Ardent
    (:action talk-to-old-sage
        :parameters (?p - player)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive) (not (map-to-forest)) (not (ancient-key-found)))
        :effect (and
            (map-to-forest) ; player receives map to Whispering Forest
        )
    )

    (:action visit-merchant
        :parameters (?p - player)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            ;; No state change; action kept for narrative progression
        )
    )

    (:action explore-village
        :parameters (?p - player)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            ;; No state change; action kept for narrative progression
        )
    )

    ;; Section 2 actions: after talking to old sage
    (:action seek-mercenary
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p village-of-ardent) (map-to-forest) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?r tavern) ; mercenary present in tavern
            (not (at ?p village-of-ardent))
            (at ?p tavern)
        )
    )

    (:action seek-forest-mage
        :parameters (?p - player ?e - ally)
        :precondition (and (at ?p village-of-ardent) (map-to-forest) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?e village-outskirts) ; forest mage present at outskirts
            (not (at ?p village-of-ardent))
            (at ?p village-outskirts)
        )
    )

    (:action head-to-whispering-forest
        :parameters (?p - player)
        :precondition (and (at ?p village-of-ardent) (map-to-forest) (temple-sealed) (dragon-alive))
        :effect (and
            (not (at ?p village-of-ardent))
            (at ?p whispering-forest)
            (threat-present magic-wolves whispering-forest)
        )
    )

    ;; Section 3 actions: after visiting merchant
    (:action buy-healing-potion
        :parameters (?p - player)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            (has ?p healing-potion)
        )
    )

    (:action buy-smoke-bomb
        :parameters (?p - player)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            (has ?p smoke-bomb)
        )
    )

    (:action buy-enchanted-arrow
        :parameters (?p - player)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            (has ?p enchanted-arrow)
        )
    )

    (:action decline-purchases-ask-rumors
        :parameters (?p - player)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            ;; No state change; action kept for narrative progression
        )
    )

    ;; Section 4 actions: after exploring village
    (:action help-villagers
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive) (not (villager-trust-high)))
        :effect (and
            (villager-trust-high)
            (ally-present ?r village-of-ardent) ; mercenary joins after trust gained
            (not (villager-trust-low))
        )
    )

    (:action ignore-villagers
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive) (not (villager-trust-low)))
        :effect (and
            (villager-trust-low)
            (not (villager-trust-high))
            (not (ally-present ?r village-of-ardent))
        )
    )

    ;; Section 5 actions: after seeking mercenary
    (:action offer-help-to-mercenary
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p tavern) (ally-present ?r tavern) (villager-trust-high) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-loyal ?r)
            (roran-ally)
            (not (at ?p tavern))
            (at ?p village-of-ardent)
        )
    )

    (:action recruit-mercenary-without-help
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p tavern) (ally-present ?r tavern) (villager-trust-low) (temple-sealed) (dragon-alive))
        :effect (and
            (mercenary-distrust)
            (not (ally-loyal ?r))
            (not (roran-ally))
            (not (at ?p tavern))
            (at ?p village-of-ardent)
        )
    )

    ;; Section 6 actions: after seeking forest mage
    (:action agree-to-retrieve-elara-relic
        :parameters (?p - player ?e - ally)
        :precondition (and (at ?p village-outskirts) (ally-present ?e village-outskirts) (temple-sealed) (dragon-alive))
        :effect (and
            (elara-favor)
            (ally-loyal ?e)
            (elara-ally)
        )
    )

    (:action decline-elara-favor
        :parameters (?p - player ?e - ally)
        :precondition (and (at ?p village-outskirts) (ally-present ?e village-outskirts) (temple-sealed) (dragon-alive))
        :effect (and
            (not (elara-favor))
            (not (ally-loyal ?e))
            (not (elara-ally))
            (not (at ?p village-outskirts))
            (at ?p whispering-forest)
            (threat-present magic-wolves whispering-forest)
        )
    )

    ;; Section 7 actions: heading directly to Whispering Forest
    (:action fight-magic-wolves
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (threat-present magic-wolves ?l) (has ?p common-sword) (temple-sealed) (dragon-alive))
        :effect (and
            (threat-defeated magic-wolves ?l)
            (not (threat-present magic-wolves ?l))
            (ancient-key-found)
            (player-damaged)
        )
    )

    (:action sneak-past-wolves
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (threat-present magic-wolves ?l) (has ?p common-sword) (temple-sealed) (dragon-alive))
        :effect (and
            (ancient-key-found)
            (not (threat-present magic-wolves ?l))
            (not (player-damaged))
        )
    )

    (:action call-elara-for-aid
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (threat-present magic-wolves ?l) (elara-ally) (temple-sealed) (dragon-alive))
        :effect (and
            (threat-defeated magic-wolves ?l)
            (not (threat-present magic-wolves ?l))
            (ancient-key-found)
        )
    )

    ;; Section 8 actions: after buying items from merchant
    (:action proceed-to-forest-after-purchase
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (temple-sealed) (dragon-alive) (or (has ?p healing-potion) (has ?p smoke-bomb) (has ?p enchanted-arrow)))
        :effect (and
            (not (at ?p ?l))
            (at ?p whispering-forest)
            (threat-present magic-wolves whispering-forest)
        )
    )

    (:action seek-mercenary-after-purchase
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?r tavern)
            (not (at ?p village-of-ardent))
            (at ?p tavern)
        )
    )

    (:action seek-forest-mage-after-purchase
        :parameters (?p - player ?e - ally)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?e village-outskirts)
            (not (at ?p village-of-ardent))
            (at ?p village-outskirts)
        )
    )

    ;; Section 9 actions: after asking merchant for rumors
    (:action visit-mercenary-after-rumors
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?r tavern)
            (not (at ?p village-of-ardent))
            (at ?p tavern)
        )
    )

    (:action visit-forest-mage-after-rumors
        :parameters (?p - player ?e - ally)
        :precondition (and (at ?p village-of-ardent) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?e village-outskirts)
            (not (at ?p village-of-ardent))
            (at ?p village-outskirts)
        )
    )

    (:action proceed-to-forest-after-rumors
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (temple-sealed) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p whispering-forest)
            (threat-present magic-wolves whispering-forest)
        )
    )

    ;; Section 10 actions: after helping villagers fend off bandits
    (:action seek-forest-mage-after-help
        :parameters (?p - player ?e - ally ?r - ally)
        :precondition (and (at ?p village-of-ardent) (villager-trust-high) (ally-loyal ?r) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?e village-outskirts)
            (not (at ?p village-of-ardent))
            (at ?p village-outskirts)
        )
    )

    (:action proceed-to-forest-after-help
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p village-of-ardent) (villager-trust-high) (ally-loyal ?r) (temple-sealed) (dragon-alive))
        :effect (and
            (not (at ?p village-of-ardent))
            (at ?p whispering-forest)
            (threat-present magic-wolves whispering-forest)
        )
    )

    (:action visit-merchant-after-help
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p village-of-ardent) (villager-trust-high) (ally-loyal ?r) (temple-sealed) (dragon-alive))
        :effect (and
            ;; No state change; action kept for narrative progression
        )
    )

    ;; Section 11 actions: after ignoring villagers under attack
    (:action seek-mercenary-after-ignore
        :parameters (?p - player ?r - ally)
        :precondition (and (at ?p village-of-ardent) (villager-trust-low) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?r tavern)
            (not (at ?p village-of-ardent))
            (at ?p tavern)
        )
    )

    (:action visit-forest-mage-after-ignore
        :parameters (?p - player ?e - ally)
        :precondition (and (at ?p village-of-ardent) (villager-trust-low) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?e village-outskirts)
            (not (at ?p village-of-ardent))
            (at ?p village-outskirts)
        )
    )

    (:action proceed-to-forest-after-ignore
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (villager-trust-low) (temple-sealed) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p whispering-forest)
            (threat-present magic-wolves whispering-forest)
        )
    )

    ;; Section 12 actions: after attempting to recruit mercenary without helping villagers
    (:action seek-forest-mage-after-mercenary-reject
        :parameters (?p - player ?e - ally)
        :precondition (and (at ?p village-of-ardent) (mercenary-distrust) (temple-sealed) (dragon-alive))
        :effect (and
            (ally-present ?e village-outskirts)
            (not (at ?p village-of-ardent))
            (at ?p village-outskirts)
        )
    )

    (:action proceed-to-forest-alone-after-mercenary-reject
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (mercenary-distrust) (temple-sealed) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p whispering-forest)
            (threat-present magic-wolves whispering-forest)
        )
    )

    ;; Section 13 actions: after agreeing to retrieve Elara’s relic
    (:action enter-forest-with-elara
        :parameters (?p - player ?l - location ?e - ally)
        :precondition (and (at ?p ?l) (elara-favor) (ally-loyal ?e) (temple-sealed) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p whispering-forest)
            (ancient-key-found)
            (not (threat-present magic-wolves whispering-forest))
        )
    )

    (:action delay-and-prepare-in-village
        :parameters (?p - player ?l - location ?e - ally)
        :precondition (and (at ?p ?l) (elara-favor) (ally-loyal ?e) (temple-sealed) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p village-of-ardent)
        )
    )

    ;; Section 14 actions: after fighting magic wolves
    (:action take-key-and-proceed-temple
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (ancient-key-found) (threat-defeated magic-wolves ?l) (temple-sealed) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p temple-of-the-sun-entrance)
            (not (temple-sealed))
            (temple-open)
        )
    )

    (:action search-forest-for-magical-items
        :parameters (?p - player ?l - location ?herb - item ?crystal - item)
        :precondition (and (at ?p ?l) (ancient-key-found) (threat-defeated magic-wolves ?l) (temple-open) (dragon-alive))
        :effect (and
            (has ?p ?herb)
            (has ?p ?crystal)
            (not (at ?p ?l))
            (at ?p whispering-forest)
        )
    )

    ;; Section 15 actions: after sneaking past wolves
    (:action proceed-temple-with-key
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (ancient-key-found) (not (player-damaged)) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p temple-of-the-sun-entrance)
        )
    )

    (:action search-glade-for-magical-items
        :parameters (?p - player ?l - location ?herb - item ?crystal - item)
        :precondition (and (at ?p ?l) (ancient-key-found) (not (player-damaged)) (temple-open) (dragon-alive))
        :effect (and
            (has ?p ?herb)
            (has ?p ?crystal)
            (not (at ?p ?l))
            (at ?p whispering-forest)
        )
    )

    ;; Section 16 actions: calling Elara’s aid in forest
    (:action head-to-temple-with-elara
        :parameters (?p - player ?l - location ?e - ally)
        :precondition (and (at ?p ?l) (elara-ally) (ancient-key-found) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p temple-of-the-sun-inner-sanctum)
        )
    )

    (:action explore-forest-further-with-elara
        :parameters (?p - player ?l - location ?e - ally ?herb - item ?crystal - item)
        :precondition (and (at ?p ?l) (elara-ally) (ancient-key-found) (temple-open) (dragon-alive))
        :effect (and
            (has ?p ?herb)
            (has ?p ?crystal)
            (not (at ?p ?l))
            (at ?p whispering-forest)
        )
    )

    ;; Section 17 actions: entering forest with Elara’s guidance
    (:action travel-to-temple-use-key
        :parameters (?p - player ?l - location ?e - ally)
        :precondition (and (at ?p ?l) (elara-ally) (ancient-key-found) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p temple-of-the-sun-entrance)
        )
    )

    (:action return-to-village-to-prepare
        :parameters (?p - player ?l - location ?e - ally)
        :precondition (and (at ?p ?l) (elara-ally) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p village-of-ardent)
        )
    )

    ;; Section 18 actions: arriving at temple with key
    (:action explore-temple-carefully
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (ancient-key-found) (temple-open) (dragon-alive))
        :effect (and
            (spear-of-light)
            (not (at ?p ?l))
            (at ?p temple-of-the-sun-altar-chamber)
        )
    )

    (:action rush-through-temple
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (ancient-key-found) (temple-open) (dragon-alive))
        :effect (and
            (spear-of-light)
            (player-damaged)
            (not (at ?p ?l))
            (at ?p temple-of-the-sun-near-exit)
        )
    )

    ;; Section 19 actions: searching forest for minor magical items
    (:action proceed-to-temple-after-forest-search
        :parameters (?p - player ?l - location ?herb - item ?crystal - item)
        :precondition (and (at ?p ?l) (has ?p ?herb) (has ?p ?crystal) (ancient-key-found) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p temple-of-the-sun-entrance)
        )
    )

    (:action rest-briefly-in-forest
        :parameters (?p - player ?l - location ?herb - item ?crystal - item)
        :precondition (and (at ?p ?l) (has ?p ?herb) (has ?p ?crystal) (ancient-key-found) (temple-open) (dragon-alive))
        :effect (and
            (rested)
            (not (at ?p ?l))
            (at ?p whispering-forest)
        )
    )

    ;; Section 20 actions: entering temple with Elara
    (:action journey-to-dark-mountains
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (spear-of-light) (elara-ally) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p dark-mountains-dragon-lair)
        )
    )

    (:action rest-and-prepare-in-village-with-elara
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (spear-of-light) (elara-ally) (temple-open) (dragon-alive))
        :effect (and
            (rested)
            (not (at ?p ?l))
            (at ?p village-of-ardent)
        )
    )

    ;; Section 21 actions: carefully exploring temple
    (:action take-spear-and-exit
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (spear-of-light) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p dark-mountains-dragon-lair)
        )
    )

    (:action search-for-additional-relics
        :parameters (?p - player ?l - location ?scrolls - item ?artifacts - item)
        :precondition (and (at ?p ?l) (spear-of-light) (temple-open) (dragon-alive))
        :effect (and
            (has ?p ?scrolls)
            (has ?p ?artifacts)
            (not (at ?p ?l))
            (at ?p temple-of-the-sun)
        )
    )

    ;; Section 22 actions: rushing through temple
    (:action exit-temple-immediately
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (spear-of-light) (player-damaged) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p dark-mountains-dragon-lair)
        )
    )

    (:action rest-and-heal-before-journey
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (spear-of-light) (player-damaged) (temple-open) (dragon-alive))
        :effect (and
            (rested)
            (not (at ?p ?l))
            (at ?p temple-of-the-sun)
        )
    )

    ;; Section 23 actions: resting and healing
    (:action proceed-to-dark-mountains-after-rest
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (rested) (or (spear-of-light) (ancient-key-found)) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p dark-mountains-dragon-lair)
        )
    )

    (:action return-to-village-for-supplies
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (rested) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p village-of-ardent)
        )
    )

    ;; Section 24 actions: confronting dragon in Dark Mountains
    (:action fight-dragon-with-spear
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (spear-of-light) (dragon-alive))
        :effect (and
            (dragon-defeated)
            (not (dragon-alive))
        )
    )

    (:action attempt-negotiate-distract-dragon
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (dragon-alive) (not (spear-of-light)))
        :effect (and
            (in-combat)
        )
    )

    ;; Section 25 actions: searching for additional relics in temple
    (:action exit-temple-head-to-mountains
        :parameters (?p - player ?l - location ?scrolls - item ?artifacts - item)
        :precondition (and (at ?p ?l) (has ?p ?scrolls) (has ?p ?artifacts) (spear-of-light) (temple-open) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p dark-mountains-dragon-lair)
        )
    )

    (:action rest-before-journey-after-relics
        :parameters (?p - player ?l - location ?scrolls - item ?artifacts - item)
        :precondition (and (at ?p ?l) (has ?p ?scrolls) (has ?p ?artifacts) (spear-of-light) (temple-open) (dragon-alive))
        :effect (and
            (rested)
            (not (at ?p ?l))
            (at ?p temple-of-the-sun)
        )
    )

    ;; Section 26 actions: fighting dragon with Spear of Light (success)
    (:action end-quest-victory
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (dragon-defeated))
        :effect (and
            (quest-completed)
        )
    )

    ;; Section 27 actions: attempt to negotiate or distract dragon (risky)
    (:action fight-in-desperation
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (in-combat) (not (spear-of-light)))
        :effect (and
            ;; Failure leads to quest failure state
            (not (dragon-defeated))
            (not (dragon-alive))
        )
    )

    (:action attempt-escape
        :parameters (?p - player ?l - location ?r - ally ?e - ally)
        :precondition (and (at ?p ?l) (in-combat) (or (has ?p smoke-bomb) (ally-loyal ?r) (ally-loyal ?e)))
        :effect (and
            (not (in-combat))
            ;; Do not remove dragon-defeated as it may never be true here
            (not (at ?p ?l))
            (at ?p village-of-ardent)
        )
    )

    ;; Section 28 actions: defeat by dragon (failure)
    (:action end-quest-failure
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (not (dragon-defeated)) (dragon-alive))
        :effect (and
            (quest-completed)
        )
    )

    ;; Section 29 actions: escape attempt
    (:action rest-and-prepare-after-escape
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (not (dragon-defeated)) (dragon-alive))
        :effect (and
            (rested)
        )
    )

    (:action return-to-village-after-escape
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (not (dragon-defeated)) (dragon-alive))
        :effect (and
            (not (at ?p ?l))
            (at ?p village-of-ardent)
        )
    )
)