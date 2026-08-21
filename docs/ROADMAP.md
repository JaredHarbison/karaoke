# Product Roadmap

Karaoke Queue is a multi-venue Rails app for collaborative karaoke nights.
This roadmap is product-oriented; architectural rationale lives in
[`docs/architecture/`](architecture/).

## Current baseline

The current app has one `User` identity, venue-scoped routes and queue data,
Devise authentication, venue discovery/joining, owner/legacy host queue
authorization, song search/queue workflows, and the Phase 0 engineering
guardrails/help framework. The current `VenueAdmin` and global user-role model
remain compatibility-era code until the next phase.

## MVP sequence

1. Collapse `VenueAdmin` and global role ambiguity into contextual
   `VenueMembership`.
2. Add events and recurring event series, including independently editable
   occurrences.
3. Add reusable event themes with deterministic checks and host-review
   fallback.
4. Add Fair Queue so performers with fewer completed turns are favored, with
   sensible tie-breaking and host override.
5. Add time-limited, event-specific temporary host delegation.
6. Add venue presence, permanent venue QR navigation, and expiring event
   presence/session security.
7. Complete MVP accessibility, reliability, presentation, and mobile polish.

## Post-MVP

- Voting and other independently configurable event queue modes.
- Rich presentation mode and real-time updates where they support the MVP.
- A future user-to-user `Request` concept, kept distinct from the current queue
  song object.
- Additional event, theme, and venue operations informed by real usage.

## Dependencies and guardrails

Contextual venue membership is the authorization foundation for event and host
work. Events must exist before event-scoped themes, Fair Queue settings,
temporary delegation, or event presence can be authoritative. Presence/session
security depends on event lifecycle and venue-scoped authorization. Each phase
needs an architecture decision, acceptance criteria, automated business-rule
and authorization coverage, and updates to relevant docs in the same change.

The roadmap does not claim that planned event, theme, Fair Queue, delegation,
presence, or QR behavior exists today.

## Finished

- [Phase 0: roadmap, architecture records, engineering guardrails, and
  application help](PHASE_0_COMPLETION.md)
- [Historical venue foundation](PHASE_1_COMPLETION.md), including venue-scoped
  routes, queue authorization, and the initial UI organization

The historical foundation remains in the codebase, but its global roles and
`VenueAdmin` model are intentionally not treated as the final architecture.
