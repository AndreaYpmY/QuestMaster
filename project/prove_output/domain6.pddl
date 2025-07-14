(define (domain martian-grand-slam)
    (:requirements :strips :typing :negative-preconditions)
    (:types
        player sponsor equipment location rumor ranking reputation - object ; Define object types used in the story
    )
    (:predicates
        (at ?p - player ?l - location) ; Player ?p is at location ?l
        (has-sponsor ?p - player ?s - sponsor) ; Player ?p has sponsor ?s
        (has-ranking ?p - player ?r - ranking) ; Player ?p has ranking ?r
        (equipment-state ?p - player ?e - equipment) ; Player ?p has equipment state ?e (outdated or upgraded)
        (rival-cliques-blocking) ; Rival player cliques block tournament entries
        (vega-champion) ; Vega Stratos is reigning Martian champion
        (rumor-exists ?rm - rumor) ; Rumor ?rm exists (e.g. illegal-tech)
        (sponsorship-interest ?p - player) ; Sponsorship interest is growing for player ?p
        (sponsor-offer-pending ?p - player ?s - sponsor) ; Sponsor ?s has offered contract to player ?p, pending acceptance
        (equipment-upgraded ?p - player) ; Player ?p has upgraded equipment
        (official-ranking-low ?p - player) ; Player ?p has low official ranking
        (official-ranking-improved ?p - player) ; Player ?p has improved official ranking
        (skill-recognized ?p - player) ; Player ?p skill recognized in exhibitions
        (sponsor-committed ?p - player ?s - sponsor) ; Sponsor ?s committed to player ?p
        (evidence-gathering ?p - player) ; Player ?p is gathering evidence on Vega cheating
        (evidence-concrete ?p - player) ; Player ?p has concrete proof of Vega cheating
        (evidence-partial ?p - player) ; Player ?p has partial evidence of Vega cheating
        (vega-penalized) ; Vega penalized for cheating
        (reputation-good ?p - player) ; Player ?p has good reputation
        (reputation-damaged ?p - player) ; Player ?p has damaged reputation
        (tournament-access-improved ?p - player) ; Player ?p has improved tournament access
        (qualified-preliminary ?p - player) ; Player ?p qualified for preliminary qualifiers
        (qualified-olympus-trials ?p - player) ; Player ?p qualified for Olympus Trials tournament
        (won-olympus-trials ?p - player) ; Player ?p won Olympus Trials tournament
        (final-champion ?p - player) ; Player ?p crowned Intergalactic Tennis Champion
        (two-sponsors ?p - player) ; Player ?p has two or more sponsors
        (match-failure ?p - player) ; Player ?p failed key qualifying match
        (retraining ?p - player) ; Player ?p is retraining
        (left-olympus-station ?p - player) ; Player ?p left Olympus Station
        (public-accusation-backfire ?p - player) ; Player ?p public accusation backfired
        (exhibition-matches ?p - player) ; Player ?p playing exhibition matches
        (media-pressure ?p - player) ; Player ?p under media and sponsor pressure
        (investigating-vega ?p - player) ; Player ?p investigating Vega cheating rumors
        (preparing-final-match ?p - player) ; Player ?p preparing for final championship match
    )

    ;; Section 1: Nova arrives at Olympus Station
    (:action attempt-join-preliminary-qualifiers
        :parameters (?p - player ?loc - location ?r - ranking ?e - equipment ?rm - rumor)
        :precondition (and
            (at ?p ?loc) ; Nova at location ?loc
            (not (has-ranking ?p ?r)) ; No ranking yet
            (equipment-state ?p ?e) ; Equipment state ?e
            (rival-cliques-blocking) ; Rival cliques block entry
            (vega-champion) ; Vega is champion
            (rumor-exists ?rm) ; Rumor exists
        )
        :effect (and
            (qualified-preliminary ?p) ; Nova qualified preliminarily
            (has-ranking ?p ?r) ; Nova gains ranking ?r
            (sponsorship-interest ?p) ; Sponsorship interest grows
            (not (rival-cliques-blocking)) ; Rival cliques remain skeptical but entry possible
        )
    )

    (:action seek-exhibition-matches
        :parameters (?p - player ?loc - location ?r - ranking ?e - equipment)
        :precondition (and
            (at ?p ?loc)
            (not (has-ranking ?p ?r))
            (equipment-state ?p ?e)
            (rival-cliques-blocking)
            (vega-champion)
        )
        :effect (and
            (skill-recognized ?p) ; Skill recognized in exhibitions
            (exhibition-matches ?p) ; Playing exhibition matches
            (sponsorship-interest ?p) ; Sponsors interested but not committed
        )
    )

    (:action investigate-vega-rumors
        :parameters (?p - player ?loc - location ?r - ranking ?e - equipment ?rm - rumor)
        :precondition (and
            (at ?p ?loc)
            (not (has-ranking ?p ?r))
            (equipment-state ?p ?e)
            (rival-cliques-blocking)
            (vega-champion)
            (rumor-exists ?rm)
        )
        :effect (and
            (evidence-gathering ?p) ; Nova gathering evidence
            (not (sponsorship-interest ?p)) ; No sponsors yet
        )
    )

    ;; Section 2: Attempting to join preliminary qualifiers
    (:action network-with-sponsors
        :parameters (?p - player ?s - sponsor ?r - ranking ?e - equipment)
        :precondition (and
            (qualified-preliminary ?p)
            (has-ranking ?p ?r)
            (equipment-state ?p ?e)
            (vega-champion)
            (sponsorship-interest ?p)
        )
        :effect (and
            (sponsor-offer-pending ?p ?s) ; Sponsor offers contract pending acceptance
        )
    )

    (:action acquire-better-equipment
        :parameters (?p - player ?r - ranking ?e1 - equipment ?e2 - equipment)
        :precondition (and
            (qualified-preliminary ?p)
            (has-ranking ?p ?r)
            (equipment-state ?p ?e1)
            (vega-champion)
        )
        :effect (and
            (equipment-state ?p ?e2) ; Equipment upgraded
            (not (equipment-state ?p ?e1))
        )
    )

    ;; Section 3: Seeking exhibition matches to attract sponsors
    (:action accept-first-sponsor-offer
        :parameters (?p - player ?s - sponsor ?e1 - equipment ?e2 - equipment)
        :precondition (and
            (exhibition-matches ?p)
            (sponsorship-interest ?p)
            (not (has-sponsor ?p ?s))
        )
        :effect (and
            (has-sponsor ?p ?s) ; Sponsor committed
            (equipment-state ?p ?e2) ; Equipment upgraded
            (not (equipment-state ?p ?e1))
        )
    )

    (:action continue-exhibition-matches
        :parameters (?p - player ?r - ranking ?e - equipment)
        :precondition (and
            (exhibition-matches ?p)
            (not (has-ranking ?p ?r))
            (equipment-state ?p ?e)
        )
        :effect (and
            (skill-recognized ?p)
            (sponsorship-interest ?p)
        )
    )

    ;; Section 4: Investigating Vega’s cheating rumors
    (:action infiltrate-vega-facility
        :parameters (?p - player ?e - equipment)
        :precondition (and
            (evidence-gathering ?p)
            (equipment-state ?p ?e)
            (vega-champion)
        )
        :effect (and
            (evidence-concrete ?p) ; Concrete proof obtained
            (not (evidence-gathering ?p))
        )
    )

    (:action analyze-match-footage
        :parameters (?p - player ?e - equipment)
        :precondition (and
            (evidence-gathering ?p)
            (equipment-state ?p ?e)
            (vega-champion)
        )
        :effect (and
            (evidence-partial ?p) ; Partial evidence obtained
            (not (evidence-gathering ?p))
        )
    )

    ;; Section 5: Networking with planetary sponsors
    (:action accept-sponsor-condition-enter-olympus-trials
        :parameters (?p - player ?s - sponsor ?r - ranking)
        :precondition (and
            (has-ranking ?p ?r)
            (sponsor-offer-pending ?p ?s)
            (not (qualified-olympus-trials ?p))
        )
        :effect (and
            (qualified-olympus-trials ?p) ; Qualified for Olympus Trials
            (has-sponsor ?p ?s)
            (not (sponsor-offer-pending ?p ?s))
        )
    )

    (:action improve-skill-before-commitment
        :parameters (?p - player ?s - sponsor ?r - ranking)
        :precondition (and
            (has-ranking ?p ?r)
            (sponsor-offer-pending ?p ?s)
        )
        :effect (and
            (skill-recognized ?p)
            (not (sponsor-offer-pending ?p ?s))
        )
    )

    ;; Section 6: Trying to acquire better equipment using prize credits
    (:action enter-olympus-trials-with-upgraded-equipment
        :parameters (?p - player ?e - equipment ?r - ranking)
        :precondition (and
            (equipment-state ?p ?e)
            (has-ranking ?p ?r)
            (not (qualified-olympus-trials ?p))
        )
        :effect (qualified-olympus-trials ?p)
    )

    (:action seek-sponsorship-to-stabilize-finances
        :parameters (?p - player ?s - sponsor ?e - equipment ?r - ranking)
        :precondition (and
            (equipment-state ?p ?e)
            (has-ranking ?p ?r)
            (not (has-sponsor ?p ?s))
        )
        :effect (sponsor-offer-pending ?p ?s)
    )

    ;; Section 7: Accepting first sponsor’s offer to upgrade equipment
    (:action enter-preliminary-qualifiers-with-sponsor
        :parameters (?p - player ?s - sponsor ?e - equipment)
        :precondition (and
            (has-sponsor ?p ?s)
            (equipment-state ?p ?e)
            (not (qualified-preliminary ?p))
        )
        :effect (qualified-preliminary ?p)
    )

    (:action play-exhibition-to-maintain-sponsor-favor
        :parameters (?p - player ?s - sponsor ?e - equipment)
        :precondition (and
            (has-sponsor ?p ?s)
            (equipment-state ?p ?e)
        )
        :effect (exhibition-matches ?p)
    )

    ;; Section 8: Continuing exhibition matches to earn sponsors’ trust
    (:action accept-second-sponsor-offer
        :parameters (?p - player ?s - sponsor)
        :precondition (and
            (exhibition-matches ?p)
            (not (has-sponsor ?p ?s))
            (exists (?s1 - sponsor) (has-sponsor ?p ?s1))
            (not (two-sponsors ?p))
        )
        :effect (and
            (has-sponsor ?p ?s)
            (two-sponsors ?p)
        )
    )

    (:action attempt-qualify-official-league
        :parameters (?p - player)
        :precondition (and
            (exhibition-matches ?p)
            (not (qualified-preliminary ?p))
        )
        :effect (qualified-preliminary ?p)
    )

    ;; Section 8b: Action to move player from one location to another
    (:action travel
        :parameters (?p - player ?from - location ?to - location)
        :precondition (at ?p ?from)
        :effect (and
            (at ?p ?to)
            (not (at ?p ?from))
        )
    )

    ;; Section 9: Infiltrating Vega’s training facility
    (:action present-evidence-to-league
        :parameters (?p - player)
        :precondition (and
            (evidence-concrete ?p)
            (not (vega-penalized))
        )
        :effect (and
            (vega-penalized)
            (reputation-good ?p)
            (tournament-access-improved ?p)
        )
    )

    (:action use-evidence-for-sponsorship
        :parameters (?p - player ?s - sponsor ?e - equipment)
        :precondition (and
            (evidence-concrete ?p)
            (not (has-sponsor ?p ?s))
        )
        :effect (and
            (has-sponsor ?p ?s)
            (equipment-state ?p ?e)
            (tournament-access-improved ?p)
        )
    )

    ;; Section 10: Analyzing match footage for irregularities
    (:action share-dossier-with-sponsors
        :parameters (?p - player ?s - sponsor)
        :precondition (and
            (evidence-partial ?p)
            (not (has-sponsor ?p ?s))
        )
        :effect (has-sponsor ?p ?s)
    )

    (:action focus-on-qualifying
        :parameters (?p - player)
        :precondition (and
            (evidence-partial ?p)
            (not (qualified-preliminary ?p))
        )
        :effect (qualified-preliminary ?p)
    )

    ;; Section 11: Entering Olympus Trials qualifiers
    (:action train-for-olympus-trials
        :parameters (?p - player)
        :precondition (qualified-olympus-trials ?p)
        :effect (won-olympus-trials ?p)
    )

    (:action investigate-vega-further
        :parameters (?p - player)
        :precondition (qualified-olympus-trials ?p)
        :effect (investigating-vega ?p)
    )

    ;; Section 12: Focusing on skill improvement before sponsor commitment
    (:action attempt-qualify-preliminary
        :parameters (?p - player ?s - sponsor)
        :precondition (and
            (not (has-sponsor ?p ?s))
            (skill-recognized ?p)
        )
        :effect (qualified-preliminary ?p)
    )

    (:action seek-sponsorship-with-skill
        :parameters (?p - player ?s - sponsor)
        :precondition (skill-recognized ?p)
        :effect (sponsor-offer-pending ?p ?s)
    )

    ;; Section 13: Presenting evidence to league officials
    (:action enter-olympus-trials-after-penalty
        :parameters (?p - player)
        :precondition (and
            (vega-penalized)
            (not (qualified-olympus-trials ?p))
        )
        :effect (qualified-olympus-trials ?p)
    )

    (:action secure-additional-sponsors
        :parameters (?p - player ?s - sponsor)
        :precondition (vega-penalized)
        :effect (has-sponsor ?p ?s)
    )

    ;; Section 14: Using evidence to gain sponsors
    (:action enter-olympus-trials-with-sponsors
        :parameters (?p - player ?s - sponsor ?e - equipment)
        :precondition (and
            (has-sponsor ?p ?s)
            (equipment-state ?p ?e)
            (not (qualified-olympus-trials ?p))
        )
        :effect (qualified-olympus-trials ?p)
    )

    (:action gather-more-evidence
        :parameters (?p - player ?s - sponsor)
        :precondition (has-sponsor ?p ?s)
        :effect (investigating-vega ?p)
    )

    ;; Section 15: Olympus Trials tournament
    (:action prepare-for-final-championship
        :parameters (?p - player)
        :precondition (won-olympus-trials ?p)
        :effect (preparing-final-match ?p)
    )

    (:action investigate-vega-before-final
        :parameters (?p - player)
        :precondition (won-olympus-trials ?p)
        :effect (investigating-vega ?p)
    )

    ;; Section 16: Final zero-gravity match on Europa (Success)
    (:action celebrate-victory
        :parameters (?p - player ?e - equipment ?loc - location)
        :precondition (and
            (preparing-final-match ?p)
            (equipment-state ?p ?e)
            (two-sponsors ?p)
            (at ?p ?loc)
        )
        :effect (and
            (final-champion ?p) ; Nova crowned champion
            (not (vega-champion)) ; Vega defeated
        )
    )

    ;; Section 17: Failure - Nova loses key qualifying match
    (:action attempt-retrain-and-requalify
        :parameters (?p - player)
        :precondition (match-failure ?p)
        :effect (and
            (retraining ?p)
            (not (match-failure ?p))
        )
    )

    (:action leave-olympus-station-failure
        :parameters (?p - player)
        :precondition (match-failure ?p)
        :effect (left-olympus-station ?p)
    )

    ;; Section 18: Failure - Public accusation backfires
    (:action rebuild-reputation-through-exhibitions
        :parameters (?p - player)
        :precondition (public-accusation-backfire ?p)
        :effect (exhibition-matches ?p)
    )

    (:action abandon-tennis-career
        :parameters (?p - player)
        :precondition (public-accusation-backfire ?p)
        :effect (left-olympus-station ?p)
    )
)