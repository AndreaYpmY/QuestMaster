(define (problem redstone-gulch-problem)
  (:domain redstone-gulch)

  (:objects
    dusty-bill frank-mallory jake cole - character ; Main characters in the story
    redstone-gulch miners-camp settlers-council saloon bank townhall - location ; Key locations in town
    unknown increased - reputation-level
    cautious skeptical partial-trust hostile intimidated resigned defeated loyal unsteady full-trust weakened pending - state-level
  )

  (:init
    ; Initial location and reputation
    (at dusty-bill redstone-gulch) ; Dusty Bill arrives in Redstone Gulch
    (reputation-unknown dusty-bill) ; Dusty Bill's reputation is unknown

    ; Sheriff and control
    (sheriff frank-mallory) ; Frank Mallory is sheriff
    (controls-gang saloon) ; Gang controls the saloon
    (siege bank) ; Bank is under siege

    ; Factions' initial attitudes
    (miners-skeptical) ; Miners are skeptical
    (settlers-cautious) ; Settlers are cautiously optimistic
    (gang-suspicious) ; Gang is suspicious of Dusty Bill

    ; Required predicates for actions
    (documents-available)
    (deputy-patrol)

    ; Cole identified to enable recruiting or dueling him
    (cole-identified)

    ; Add player predicate for Dusty Bill
    (player dusty-bill)
  )

  (:goal
    (and
      (dusty-leader) ; Dusty Bill is leader of Redstone Gulch
      (dusty-leads-council) ; Dusty leads faction council
      (miners-agree-support) ; Miners agree to support Dusty Bill (achievable proxy for trusts miners dusty-bill)
      (settlers-agree-support) ; Settlers agree to support Dusty Bill (achievable proxy for trusts settlers dusty-bill)
      (ally-gang dusty-bill) ; Gang allied with Dusty Bill
      (or (mallory-resigned) (mallory-defeated)) ; Mallory resigned or defeated
      (bank-liberated) ; Bank siege lifted
      (townhall-controlled dusty-bill) ; Dusty Bill controls town hall
    )
  )
)