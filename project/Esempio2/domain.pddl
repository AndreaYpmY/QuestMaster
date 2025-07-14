(define (domain martian-grand-slam)
    (:requirements :strips :typing :negative-preconditions)
    (:types
        player sponsor rival-clique location equipment match coach - object
    )
    (:predicates
        ;; Player location in the station or arena
        (at ?p - player ?l - location) ; player ?p is at location ?l
        ;; Player has specific equipment
        (has-equipment ?p - player ?e - equipment) ; player ?p has equipment ?e
        ;; Player has sponsorship
        (has-sponsor ?p - player ?s - sponsor) ; player ?p has sponsor ?s
        ;; Player has ranking status
        (has-ranking ?p - player) ; player ?p has ranking
        ;; Rival cliques present at location blocking tournament entries
        (rival-cliques-blocking ?l - location) ; rival cliques block entries at location
        ;; Player accepted training offer from coach
        (training-accepted ?p - player ?c - coach) ; player ?p accepted training from coach ?c
        ;; Player accepted racket offer from vendor
        (racket-offer-accepted ?p - player) ; player ?p accepted racket offer
        ;; Player has prototype racket
        (has-prototype-racket ?p - player) ; player ?p has prototype racket
        ;; Player has next-gen racket and suit
        (has-nextgen-gear ?p - player) ; player ?p has next-gen racket and suit
        ;; Player has modest suit upgrade
        (has-modest-suit ?p - player) ; player ?p has modest suit upgrade
        ;; Player has improved ranking
        (improved-ranking ?p - player) ; player ?p has improved ranking
        ;; Player has gained reputation
        (has-reputation ?p - player) ; player ?p has reputation
        ;; Player qualified for Olympus Trials
        (qualified-trials ?p - player) ; player ?p qualified for Olympus Trials
        ;; Player in match arena
        (in-match ?p - player ?m - match) ; player ?p is in match ?m
        ;; Player won last match
        (won-last-match ?p - player) ; player ?p won last match
        ;; Player lost or drew last match
        (lost-drew-last-match ?p - player) ; player ?p lost or drew last match
        ;; Player in final match arena
        (in-final ?p - player) ; player ?p is in final match arena
        ;; Player crowned champion
        (champion ?p - player) ; player ?p is champion
        ;; Player defeated in final
        (defeated ?p - player) ; player ?p defeated in final
        ;; Sponsor representative uncommitted
        (sponsor-uncommitted ?s - sponsor) ; sponsor ?s is uncommitted
        ;; Player has challenged rival clique member
        (challenged-rival ?p - player) ; player ?p challenged rival clique member
        ;; Player has underground tournament access
        (underground-access ?p - player) ; player ?p has access to underground tournaments
        ;; Player has played exhibition match
        (played-exhibition ?p - player) ; player ?p played exhibition match
        ;; Player has played underground match
        (played-underground ?p - player) ; player ?p played underground match
        ;; Player has played qualifiers
        (played-qualifiers ?p - player) ; player ?p played qualifiers
        ;; Player has played trials matches
        (played-trials ?p - player) ; player ?p played trials matches
        ;; Player has played final match
        (played-final ?p - player) ; player ?p played final match
        ;; Player has increased confidence
        (increased-confidence ?p - player) ; player ?p has increased confidence
        ;; Player has tactical knowledge
        (tactical-knowledge ?p - player) ; player ?p has tactical knowledge
        ;; Player has sponsor interest
        (sponsor-interest ?p - player) ; player ?p has sponsor interest
    )

    ;; Section 1 actions: Initial choices at Olympus Station entrance
    (:action visit-sports-gear-market
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (rival-cliques-blocking ?from))
        :effect (and
            (not (at ?p ?from)) ; player leaves current location
            (at ?p ?to) ; player arrives at sports gear market
            (not (rival-cliques-blocking ?to)) ; market not blocked by rival cliques
        )
    )

    (:action approach-training-facility
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from)) ; player leaves current location
            (at ?p ?to) ; player arrives at training facility
        )
    )

    (:action talk-to-sponsor-rep
        :parameters (?p - player ?from - location ?to - location ?s - sponsor)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from)) ; player leaves current location
            (at ?p ?to) ; player arrives at corporate lounge
            (sponsor-uncommitted ?s) ; sponsor representative is uncommitted
        )
    )

    ;; Section 2 actions: At sports gear market
    (:action accept-prototype-racket-offer
        :parameters (?p - player ?l - location ?s - sponsor)
        :precondition (and (at ?p ?l) (not (has-sponsor ?p ?s)) (not (has-prototype-racket ?p)))
        :effect (and
            (racket-offer-accepted ?p) ; player accepted racket offer
            (has-prototype-racket ?p) ; player now has prototype racket
        )
    )

    (:action decline-prototype-racket-offer
        :parameters (?p - player ?l - location ?to - location)
        :precondition (at ?p ?l)
        :effect (and
            (not (racket-offer-accepted ?p)) ; player declined racket offer
            (not (has-prototype-racket ?p))
            (not (at ?p ?l))
            (at ?p ?to) ; player moves to corporate lounge to seek sponsorship
        )
    )

    (:action leave-market-to-training
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player moves to training facility
        )
    )

    ;; Section 3 actions: At training facility
    (:action accept-training-offer
        :parameters (?p - player ?c - coach ?l - location)
        :precondition (and (at ?p ?l) (not (training-accepted ?p ?c)))
        :effect (training-accepted ?p ?c) ; player accepted training offer
    )

    (:action decline-training-offer
        :parameters (?p - player ?from - location ?to - location ?c - coach)
        :precondition (at ?p ?from)
        :effect (and
            (not (training-accepted ?p ?c))
            (not (at ?p ?from))
            (at ?p ?to) ; player moves to corporate lounge to seek sponsorship
        )
    )

    (:action challenge-local-player
        :parameters (?p - player ?l - location)
        :precondition (at ?p ?l)
        :effect (challenged-rival ?p) ; player challenged rival clique member
    )

    ;; Section 4 actions: At corporate lounge
    (:action return-to-market-for-racket
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player returns to sports gear market
        )
    )

    (:action go-to-training-from-lounge
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to training facility
        )
    )

    (:action find-underground-tournaments
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player moves to underground tournament hub
            (underground-access ?p) ; player gains access to underground tournaments
        )
    )

    ;; Section 5 actions: At exhibition arena with prototype racket
    (:action play-aggressively-exhibition
        :parameters (?p - player ?m - match ?l - location)
        :precondition (and (at ?p ?l) (has-prototype-racket ?p))
        :effect (and
            (in-match ?p ?m)
            (won-last-match ?p)
            (played-exhibition ?p)
            (has-reputation ?p)
            (improved-ranking ?p)
        )
    )

    (:action play-defensively-exhibition
        :parameters (?p - player ?m - match ?l - location)
        :precondition (and (at ?p ?l) (has-prototype-racket ?p))
        :effect (and
            (in-match ?p ?m)
            (lost-drew-last-match ?p)
            (played-exhibition ?p)
            (tactical-knowledge ?p)
        )
    )

    ;; Section 6 actions: Training facility with training accepted
    (:action enter-league-qualifiers
        :parameters (?p - player ?l - location ?c - coach)
        :precondition (and (at ?p ?l) (training-accepted ?p ?c))
        :effect (played-qualifiers ?p)
    )

    (:action seek-sponsorship-during-training
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to corporate lounge
        )
    )

    (:action challenge-rival-practice
        :parameters (?p - player ?l - location)
        :precondition (at ?p ?l)
        :effect (challenged-rival ?p)
    )

    ;; Section 7 actions: Practice arena friendly match
    (:action play-aggressively-practice
        :parameters (?p - player ?m - match ?l - location)
        :precondition (and (at ?p ?l))
        :effect (and
            (in-match ?p ?m)
            (won-last-match ?p)
            (played-exhibition ?p)
            (has-reputation ?p)
            (improved-ranking ?p)
        )
    )

    (:action play-cautiously-practice
        :parameters (?p - player ?m - match ?l - location)
        :precondition (and (at ?p ?l))
        :effect (and
            (in-match ?p ?m)
            (lost-drew-last-match ?p)
            (played-exhibition ?p)
            (tactical-knowledge ?p)
        )
    )

    ;; Section 8 actions: Underground tournament hub
    (:action attempt-sponsor-for-fee
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to corporate lounge
        )
    )

    (:action enter-underground-tournament
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (underground-access ?p))
        :effect (played-underground ?p)
    )

    (:action return-to-training-from-underground
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to training facility
        )
    )

    ;; Section 9 actions: After winning exhibition or practice match aggressively
    (:action accept-gear-upgrade
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (won-last-match ?p))
        :effect (has-nextgen-gear ?p)
    )

    (:action enter-official-qualifiers
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (won-last-match ?p))
        :effect (played-qualifiers ?p)
    )

    (:action seek-sponsorship-improved
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (won-last-match ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to corporate lounge
        )
    )

    ;; Section 10 actions: After playing defensively and losing or drawing
    (:action return-to-training
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (lost-drew-last-match ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to training facility
        )
    )

    (:action seek-sponsorship-despite-loss
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (lost-drew-last-match ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to corporate lounge
        )
    )

    (:action try-underground-for-experience
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (lost-drew-last-match ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to underground tournament hub
            (underground-access ?p)
        )
    )

    ;; Section 11 actions: Martian league qualifiers
    (:action prepare-for-olympus-trials
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-qualifiers ?p))
        :effect (qualified-trials ?p)
    )

    (:action seek-sponsorship-before-trials
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (played-qualifiers ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to) ; player goes to corporate lounge
        )
    )

    (:action negotiate-friendly-matches
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-qualifiers ?p))
        :effect (challenged-rival ?p)
    )

    ;; Section 12 actions: Underground tournament arena
    (:action play-aggressively-underground
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-underground ?p))
        :effect (and
            (won-last-match ?p)
            (sponsor-interest ?p)
        )
    )

    (:action play-defensively-underground
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-underground ?p))
        :effect (lost-drew-last-match ?p)
    )

    ;; Section 13 actions: After accepting gear upgrade
    (:action enter-qualifiers-after-upgrade
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (has-nextgen-gear ?p))
        :effect (played-qualifiers ?p)
    )

    (:action seek-sponsorship-after-upgrade
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (has-nextgen-gear ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action challenge-rivals-after-upgrade
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (has-nextgen-gear ?p))
        :effect (challenged-rival ?p)
    )

    ;; Section 14 actions: Olympus Trials arena
    (:action play-aggressively-trials
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (qualified-trials ?p))
        :effect (played-trials ?p)
    )

    (:action play-cautiously-trials
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (qualified-trials ?p))
        :effect (played-trials ?p)
    )

    ;; Section 15 actions: After winning underground tournament
    (:action seek-official-ranking-after-underground
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (won-last-match ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action seek-sponsorship-after-underground
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and (at ?p ?from) (won-last-match ?p))
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )

    (:action begin-intensive-training
        :parameters (?p - player ?l - location ?c - coach)
        :precondition (at ?p ?l)
        :effect (training-accepted ?p ?c)
    )

    ;; Section 16 actions: Olympus Trials later rounds aggressive play
    (:action continue-aggressive-play
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-trials ?p))
        :effect (played-final ?p)
    )

    (:action shift-to-defensive-play
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-trials ?p))
        :effect (played-final ?p)
    )

    ;; Section 17 actions: Olympus Trials later rounds defensive play
    (:action increase-aggression-final
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-trials ?p))
        :effect (played-final ?p)
    )

    (:action maintain-defensive-play-final
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-trials ?p))
        :effect (played-final ?p)
    )

    ;; Section 18 actions: Final match aggressive
    (:action attempt-decisive-smash
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-final ?p))
        :effect (champion ?p) ; player wins championship
    )

    (:action play-safe-final
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-final ?p))
        :effect (defeated ?p) ; player loses final match
    )

    ;; Section 19 actions: Final match defensive
    (:action increase-aggression-final-defensive
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-final ?p))
        :effect (champion ?p) ; player wins championship
    )

    (:action continue-defensive-final
        :parameters (?p - player ?l - location)
        :precondition (and (at ?p ?l) (played-final ?p))
        :effect (defeated ?p) ; player loses final match
    )

    ;; Section 20 actions: Success ending
    (:action celebrate-victory
        :parameters (?p - player)
        :precondition (champion ?p)
        :effect (and
            ;; End of story, no further actions
        )
    )

    ;; Section 21 actions: Failure ending
    (:action reflect-on-defeat
        :parameters (?p - player)
        :precondition (defeated ?p)
        :effect (and
            ;; End of story, no further actions
        )
    )

    ;; Additional movement actions to reach europa-grand-arena
    (:action move-between-locations
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (not (at ?p ?from))
            (at ?p ?to)
        )
    )
)