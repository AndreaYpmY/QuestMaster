
(define (problem redstone-gulch-problem)
    (:domain redstone-gulch-quest)

    (:objects
        dusty-bill - player
        sheriff-mallory - sheriff
        lieutenant - lieutenant
        saloon-gang - gang-member
        outlaw1 - outlaw
        miner-faction - miner
        settler-faction - settler
        reformist-outlaw-faction - reformist-outlaw
    )

    (:init
        (at dusty-bill redstone-gulch)
        (controls sheriff-mallory townhall)
        (controls-faction miner-faction redstone-gulch)
        (controls-faction settler-faction redstone-gulch)
        (controls-faction reformist-outlaw-faction redstone-gulch)
        (controls saloon-gang saloon)
        (siege bank)
        (not-trusted dusty-bill)

        ;; Define adjacency for movement
        (adjacent redstone-gulch saloon)
        (adjacent saloon redstone-gulch)
        (adjacent redstone-gulch bank)
        (adjacent bank redstone-gulch)
        (adjacent redstone-gulch townhall)
        (adjacent townhall redstone-gulch)
        (adjacent saloon bank)
        (adjacent bank saloon)
        (adjacent saloon townhall)
        (adjacent townhall saloon)
        (adjacent bank townhall)
        (adjacent townhall bank)
    )

    (:goal
        (and
            (leader-recognized dusty-bill)
            (quest-completed)
        )
    )
)