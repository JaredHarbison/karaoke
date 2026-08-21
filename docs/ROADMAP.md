# Product Roadmap

Karaoke Queue is a multi-venue Rails app for collaborative karaoke nights.
This roadmap is product-oriented; architectural rationale lives in
[`docs/architecture/`](architecture/).

## Current baseline

The current app has one `User` identity, venue-scoped routes and queue data,
Devise authentication, venue discovery/joining, contextual venue membership
authorization, membership-backed host management, song search/queue workflows,
and the Phase 0 engineering guardrails/help framework. Contextual
`VenueMembership` authorization and membership-backed host management complete
Phase 1.

## MVP sequence

1. Collapse global role ambiguity into contextual `VenueMembership` (complete).
2. Add events and recurring event series, including independently editable
   occurrences (in progress: venue-scoped management, daily/weekly
   materialization, and transitional event-scoped queueing are complete).
3. Add reusable event themes with deterministic checks and host-review
   fallback (theme definitions, event applications, host routes, bounded
   application windows, and a provider-independent evaluator are covered;
   admission integration remains; regression coverage includes incomplete
   and out-of-bounds windows).
4. Add Fair Queue so performers with fewer completed turns are favored, with
   sensible tie-breaking and host override.
5. Add time-limited, event-specific temporary host delegation.
6. Add venue presence, permanent venue QR navigation, and expiring event
   presence/session security.
7. Complete MVP accessibility, reliability, presentation, and mobile polish.

### Planned admission validation

Before a song becomes a performance, provider-backed validation must establish
that the selected YouTube video is genuinely karaoke and must reject explicit
lyrics when the venue policy disallows them. Missing or ambiguous metadata must
go to review rather than silently entering the queue.

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

The historical foundation remains as a record, but its global roles and
`VenueAdmin` model were replaced during Phase 1 and are not treated as the
current architecture.
