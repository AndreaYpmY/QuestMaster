(define (domain redstone-gulch)
    (:requirements :strips :typing :negative-preconditions)
    
    (:types
        location character faction item state-level reputation-level - object
    )
    
    (:constants
        miners settlers gang - faction
    )
    
    (:predicates
        ; Location predicates
        (at ?char - character ?loc - location) ; Character is at a location
        
        ; Trust predicates
        (trusts ?f - faction ?char - character) ; Faction trusts character
        
        ; Control predicates
        (controls ?char - character ?loc - location) ; Character controls location
        (controls-gang ?loc - location) ; Gang controls location (saloon)
        (siege ?loc - location) ; Location is under siege (bank)
        
        ; Reputation predicates
        (reputation-unknown ?char - character) ; Character's reputation is unknown
        (reputation ?char - character ?level - reputation-level) ; Character's reputation level (e.g. increased)
        
        ; State predicates
        (sheriff ?char - character) ; Character is sheriff
        (gang-suspicious) ; Gang is suspicious of Dusty Bill
        (gang-hostile) ; Gang is hostile to Dusty Bill
        (gang-partial-trust) ; Gang partially trusts Dusty Bill
        
        (deputy-patrol) ; Deputies patrol town hall
        (documents-available) ; Compromising documents are available
        (documents-possession ?char - character) ; Character possesses compromising documents
        
        (ally ?char - character ?f - faction) ; Character allied with faction
        (ally-gang ?char - character) ; Character allied with gang
        
        (mallory-corrupt) ; Mallory is corrupt
        (mallory-power-weakened) ; Mallory's power weakened
        (mallory-defeated) ; Mallory defeated
        (mallory-resigned) ; Mallory resigned
        
        (cole-identified) ; Cole identified as lieutenant
        (cole-ally ?char - character) ; Cole allied with character
        (cole-loyal) ; Cole loyal to Dusty Bill
        (cole-unsteady) ; Cole unsteady in loyalty
        
        (final-duel-pending) ; Final duel pending
        
        (townhall-controlled ?char - character) ; Character controls town hall
        
        (miners-skeptical) ; Miners skeptical
        (miners-trust-increased) ; Miners trust increased
        (miners-agree-support) ; Miners agree to support Dusty Bill
        
        (settlers-cautious) ; Settlers cautiously optimistic
        (settlers-trust-increased) ; Settlers trust increased
        (settlers-agree-support) ; Settlers agree to support Dusty Bill
        (settlers-full-trust) ; Settlers fully trust Dusty Bill
        
        (outlaws-allied) ; Reformist outlaws allied with Dusty Bill
        
        (bank-liberated) ; Bank siege lifted
        
        (dusty-leader) ; Dusty Bill is leader of Redstone Gulch
        (player ?char - character) ; Main player character
        (dusty-leads-council) ; Dusty leads faction council
        
        (risk-violent-retaliation) ; Risk of violent retaliation increased
        (risk-tyranny) ; Risk of Dusty becoming tyrant increased
        
        (challenge-duel ?opponent - character) ; Duel challenge pending with opponent
        
        (gang-intimidated) ; Gang intimidated by Dusty Bill
    )
    
    (:action arrive-in-town
        :parameters (?d - character ?loc - location)
        :precondition (not (at ?d ?loc))
        :effect (and
            (at ?d ?loc) ; Character arrives at town
            (reputation-unknown ?d) ; Reputation unknown
            (gang-suspicious) ; Gang suspicious
            (miners-skeptical) ; Miners skeptical
            (settlers-cautious)
            (player ?d)
        )
    )
    
    (:action visit-miners-camp
        :parameters (?d - character ?from ?to - location)
        :precondition (and (at ?d ?from))
        :effect (and
            (not (at ?d ?from))
            (at ?d ?to)
            (miners-skeptical) ; Miners remain skeptical initially
            (gang-suspicious)
            (settlers-cautious)
        )
    )
    
    (:action approach-settlers-council
        :parameters (?d - character ?from ?to - location)
        :precondition (and (at ?d ?from))
        :effect (and
            (not (at ?d ?from))
            (at ?d ?to)
            (settlers-cautious) ; Settlers cautiously optimistic
            (miners-skeptical)
            (gang-suspicious)
        )
    )
    
    (:action infiltrate-saloon
        :parameters (?d - character ?from ?to - location)
        :precondition (and (at ?d ?from))
        :effect (and
            (not (at ?d ?from))
            (at ?d ?to)
            (gang-suspicious) ; Gang suspicious but open to negotiation
            (miners-skeptical)
            (settlers-cautious)
        )
    )
    
    (:action promise-protection-miners
        :parameters (?d - character ?loc - location)
        :precondition (and (at ?d ?loc) (miners-skeptical))
        :effect (and
            (not (miners-skeptical))
            (miners-trust-increased)
            (miners-agree-support)
        )
    )
    
    (:action reveal-mallory-corruption-to-miners
        :parameters (?d - character ?loc - location)
        :precondition (and (at ?d ?loc) (miners-skeptical) (not (mallory-corrupt)))
        :effect (and
            (mallory-corrupt)
            (not (miners-skeptical))
            (miners-trust-increased)
        )
    )
    
    (:action volunteer-retrieve-documents-settlers
        :parameters (?d - character ?loc - location)
        :precondition (and (at ?d ?loc) (settlers-cautious))
        :effect (and
            (not (settlers-cautious))
            (documents-available)
            (settlers-trust-increased)
        )
    )
    
    (:action offer-protection-land-settlers
        :parameters (?d - character ?loc - location)
        :precondition (and (at ?d ?loc) (settlers-cautious))
        :effect (and
            (not (settlers-cautious))
            (settlers-trust-increased)
            (settlers-agree-support)
        )
    )
    
    (:action challenge-poker-jake
        :parameters (?d - character ?loc - location)
        :precondition (and (at ?d ?loc) (gang-suspicious))
        :effect (and
            (not (gang-suspicious))
            (gang-partial-trust)
        )
    )
    
    (:action threaten-gang
        :parameters (?d - character ?loc - location)
        :precondition (and (at ?d ?loc) (gang-suspicious))
        :effect (and
            (not (gang-suspicious))
            (gang-hostile)
        )
    )
    
    (:action promise-raid-bank
        :parameters (?d - character)
        :precondition (and (miners-agree-support))
        :effect (and
            (bank-liberated)
            (miners-trust-increased)
            (settlers-trust-increased)
        )
    )
    
    (:action plan-strike-supply-lines
        :parameters (?d - character)
        :precondition (and (miners-trust-increased))
        :effect (and
            (mallory-power-weakened)
            (risk-violent-retaliation)
        )
    )
    
    (:action sneak-steal-documents
        :parameters (?d - character ?loc - location)
        :precondition (and (at ?d ?loc) (documents-available) (not (documents-possession ?d)) (not (deputy-patrol)))
        :effect (and
            (documents-possession ?d)
            (not (documents-available))
        )
    )
    
    (:action confront-deputy
        :parameters (?d - character ?loc - location)
        :precondition (and (at ?d ?loc) (deputy-patrol))
        :effect (and
            (not (deputy-patrol))
        )
    )
    
    (:action rally-settlers-defend-bank
        :parameters (?d - character)
        :precondition (and (settlers-agree-support) (bank-liberated))
        :effect (and
            (miners-trust-increased)
            (settlers-trust-increased)
        )
    )
    
    (:action organize-settlers-challenge-mallory
        :parameters (?d - character)
        :precondition (and (settlers-agree-support))
        :effect (and
            (settlers-full-trust)
            (risk-violent-retaliation)
        )
    )
    
    (:action negotiate-gang-betrayal
        :parameters (?d - character)
        :precondition (and (gang-partial-trust))
        :effect (and
            (ally-gang ?d)
            (mallory-power-weakened)
        )
    )
    
    (:action duel-lieutenant-cole
        :parameters (?d - character ?cole - character)
        :precondition (and (cole-identified) (not (cole-ally ?d)))
        :effect (and
            (not (cole-identified))
            (mallory-power-weakened)
            (cole-ally ?d)
        )
    )
    
    (:action recruit-cole
        :parameters (?d - character ?cole - character)
        :precondition (and (cole-identified) (not (cole-ally ?d)))
        :effect (and
            (cole-ally ?d)
            (mallory-power-weakened)
        )
    )
    
    (:action draw-pistol-gang
        :parameters (?d - character)
        :precondition (and (gang-hostile))
        :effect (and
            (not (gang-hostile))
            (gang-intimidated)
            (ally-gang ?d)
            (risk-tyranny)
        )
    )
    
    (:action confront-deputy-publicly
        :parameters (?d - character)
        :precondition (and (bank-liberated))
        :effect (and
            (mallory-power-weakened)
        )
    )
    
    (:action fortify-alliance-outlaws
        :parameters (?d - character)
        :effect (and
            (outlaws-allied)
            (mallory-power-weakened)
        )
    )
    
    (:action present-documents-to-factions
        :parameters (?d - character)
        :precondition (and (documents-possession ?d))
        :effect (and
            (trusts miners ?d)
            (trusts settlers ?d)
            (mallory-corrupt)
            (mallory-power-weakened)
        )
    )
    
    (:action demand-mallory-resignation
        :parameters (?d - character ?mallory - character)
        :precondition (and (mallory-power-weakened))
        :effect (and
            (mallory-resigned)
        )
    )
    
    (:action prepare-final-duel
        :parameters (?d - character)
        :precondition (and (mallory-power-weakened))
        :effect (and
            (final-duel-pending)
        )
    )
    
    (:action storm-townhall
        :parameters (?d - character)
        :precondition (and (ally-gang ?d))
        :effect (and
            (townhall-controlled ?d)
            (mallory-power-weakened)
        )
    )
    
    (:action duel-mallory
        :parameters (?d - character ?mallory - character)
        :precondition (and (final-duel-pending))
        :effect (and
            (mallory-defeated)
            (not (final-duel-pending))
            (dusty-leader)
        )
    )
    
    (:action negotiate-mallory-resignation
        :parameters (?d - character ?mallory - character)
        :precondition (and (mallory-power-weakened))
        :effect (and
            (mallory-resigned)
            (dusty-leader)
        )
    )
    
    (:action establish-leadership
        :parameters (?d - character)
        :precondition (and (dusty-leader))
        :effect (and
            (dusty-leads-council)
        )
    )
    
    (:action consult-factions-council
        :parameters (?d - character)
        :precondition (and (dusty-leader))
        :effect (and
            (dusty-leads-council)
            (not (risk-tyranny))
        )
    )
    
    (:action confront-cole-loyalty
        :parameters (?d - character ?cole - character)
        :precondition (and (cole-ally ?d) (cole-unsteady))
        :effect (and
            (cole-loyal)
            (not (cole-unsteady))
        )
    )
    
    (:action give-cole-chance
        :parameters (?d - character ?cole - character)
        :precondition (and (cole-ally ?d) (cole-unsteady))
        :effect (and
            (cole-loyal)
            (not (cole-unsteady))
        )
    )
)