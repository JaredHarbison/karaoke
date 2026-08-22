# Product Roadmap

Karaoke Queue is a multi-venue Rails app for collaborative karaoke nights.
This roadmap is product-oriented; architectural rationale lives in
[`docs/architecture/`](architecture/).

## Current status

The engineering, identity, contextual venue authorization, event/series,
reusable theme, initial Fair Queue, temporary delegation, presence-token, and
initial event-lifecycle foundations are complete. The remaining MVP work is to
finish the display-code exchange, runtime-aware admission, and polished queue
workflow.

## MVP sequence

### 1. Event lifecycle and presence-gated admission

- [Initial slice complete] Add scheduled, live, and completed event states with
  host-controlled start and completion actions.
- Keep one permanent venue QR as the printed/displayed entry point.
- Resolve it to the active event, next upcoming event, or event discovery.
- Show a short-lived, readable event code only on host/presentation/display
  screens after the event starts.
- [Initial slice complete] Require authentication plus an active event presence
  session before queueing for live event queues.
- Rotate the display code during the event; do not expose it before start.
- [Initial slice complete] Expire presence at event close plus a small grace
  period.
- Harden code attempts, re-entry, and concurrent event admission.

Separate printed event QRs are not required for MVP. A dynamically displayed
event QR may remain an optional future convenience.

### 2. Canonical song and performance admission

- Preserve the current queue behavior while introducing the canonical `Song` /
  event-specific `Performance` boundary.
- Reuse a canonical YouTube selection when it is chosen again, but create a new
  Performance for every performer/event queue entry.
- Validate karaoke suitability and venue content policy before admission.
- Persist validated video duration when available.
- If duration is unavailable, estimate from the average of known-duration songs
  already queued for that event; estimated values do not feed that average.
- Snapshot effective duration and its source on the Performance.

### 3. Queue cutoff and event runtime protection

- Calculate projected queue time as each effective video duration plus 30
  seconds of transition time.
- Default to stopping new admissions when projected completion exceeds the
  event end.
- Allow an explicit host/owner “allow queue overrun” override with audit.
- Perform status, presence, cutoff, and insertion checks atomically so a rush
  of submissions cannot bypass the cutoff.
- Prevent duplicate submissions caused by retries or double taps.

### 4. Live theme admission and review

- Evaluate themes against Performances in the event/time-window context.
- Support eligible, pending/review, and rejected outcomes.
- Release pending or theme-ineligible performances into normal/Fair Queue
  eligibility when the theme ends unless explicitly removed or rejected.
- Add host review and clear explanations.

Theme rules remain event-specific. A curated `ThemeSong` join is not required
unless reusable theme playlists become an MVP need.

### 5. Fair Queue hardening

- Preserve event-level Fair Queue and host override audit.
- Add robust handling for skipped songs, duets, new performers, and
  concurrency.
- Add configurable fairness modes only where real usage requires them.

### 6. MVP UX, accessibility, reliability, and presentation polish

- Complete responsive event, access-code, queue, and host workflows.
- Run accessibility and mobile reviews.
- Improve presentation mode, retry states, and operational feedback.
- Complete the human QA pass across the MVP.

## Post-MVP

- RSVP or “interested” state, separate from queue authorization.
- Rich event-first public discovery and shareable event pages.
- Event images, social preview cards, and Partiful-like presentation.
- Downloadable calendar files, then calendar subscription URLs and provider
  integrations that can reflect event changes.
- Optional geolocation as a secondary presence signal.
- Dynamically displayed event QR codes as an optional shortcut.
- Curated reusable theme playlists backed by a `ThemeSong` join.
- Advanced Fair Queue modes and automatic event extension.
- The future user-to-user `Request` concept, distinct from Song and
  Performance.
- Stronger anti-sharing and physical-location enforcement.

## Dependencies and guardrails

Contextual venue membership is the authorization foundation for event and host
work. Event lifecycle is the prerequisite for presence-gated queue admission;
the initial lifecycle and gate are now implemented. Canonical
Song/Performance separation and duration metadata must precede reliable runtime
cutoff decisions. Live theme admission depends on the Performance boundary.
Each phase needs architecture rationale, acceptance criteria, automated
business-rule and authorization coverage, and relevant roadmap/QA updates in
the same change.

## Finished

- [Phase 0: roadmap, architecture records, engineering guardrails, and
  application help](PHASE_0_COMPLETION.md)
- [Historical venue foundation](PHASE_1_COMPLETION.md), including venue-scoped
  routes, queue authorization, and the initial UI organization
- Phase 1 contextual membership and platform-membership foundation.
- Phase 2 event/theme foundation: venue-scoped events, recurring occurrence
  materialization, event-scoped queue association, reusable themes, bounded
  applications, and deterministic evaluator outcomes.
- Initial Fair Queue ordering, event controls, queue explanation, and override
  audit.
- Initial temporary event host delegation with expiry, revocation, and scoped
  queue authority.
- Initial venue presence token, dynamic venue QR, expiring event presence
  session foundation, and live-event queue gate.

The finished items are foundations. Rotating display-code exchange,
duration-aware cutoff, live theme admission, and full concurrency hardening
remain planned MVP work.
