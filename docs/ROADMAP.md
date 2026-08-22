# Product Roadmap

Karaoke Queue is a multi-venue Rails app for collaborative karaoke nights.
This roadmap is product-oriented; architectural rationale lives in
[`docs/architecture/`](architecture/).

## Current status

The engineering, identity, contextual venue authorization, event/series,
reusable theme, initial Fair Queue, temporary delegation, presence-token,
short-code exchange, and initial event-lifecycle foundations are complete. The
remaining MVP work is abuse telemetry and retention cleanup, finalizing the
canonical Performance ownership of admission state, deeper load hardening, and
polished queue workflow.

## MVP sequence

### 1. Event lifecycle and presence-gated admission

- [Initial slice complete] Add scheduled, live, and completed event states with
  host-controlled start and completion actions.
- Keep one permanent venue QR as the printed/displayed entry point.
- Resolve it to the active event, next upcoming event, or event discovery.
- [Initial slice complete] Generate a readable event code with each event
  presence session and resolve performer code entry to that event.
- [Initial slice complete] Show the active event code only on host/event
  management and presentation contexts after the event starts.
- [Initial slice complete] Require authentication plus an active event presence
  session before queueing for live event queues.
- [Initial slice complete] Rotate the display code during the event under an
  event lock; revoke the prior active session and do not expose revoked codes.
- [Initial slice complete] Normalize typed access codes for case, spaces, and
  hyphens, and generate easier-to-read codes without ambiguous characters.
- [Initial slice complete] Expire presence at event close plus a small grace
  period.
- [Initial slice complete] Limit repeated event-code attempts with a
  database-backed window shared across application processes.
- [Initial slice complete] Preserve re-entry while a presence session remains
  active and reject re-entry after rotation, revocation, or expiry.
- [Initial slice complete] Record blocked-attempt telemetry and last-attempt
  timestamps without storing raw client addresses.
- [Initial slice complete] Provide a retention task that removes attempt
  telemetry after its short privacy window.

Separate printed event QRs are not required for MVP. A dynamically displayed
event QR may remain an optional future convenience.

### 2. Canonical song and performance admission

- [Initial slice complete] Preserve the current queue behavior while adding a
  transitional provider-metadata boundary; canonical provider identities now
  persist independently from queue entries.
- [Initial slice complete] Route application queue reads and writes through an
  event-specific `Performance` model backed by the existing queue table, with
  the old `Song` name retained only for compatibility.
- [Initial slice complete] Expose the canonical association as
  `Performance#song`; `song_identity` remains a compatibility alias during the
  naming migration.
- [Initial slice complete] Reuse validated YouTube provider metadata from a
  prior eligible selection while creating a new queue `Performance` for each
  performer/event entry.
- [Initial slice complete] Promote the provider identity into the canonical
  `Song` domain model while keeping the physical identity table stable.
- [Initial slice complete] Use `Performance` directly for queue entries in
  application code and tests; external song routes and parameter names remain
  compatibility-facing.
- [Initial slice complete] Validate available provider metadata and venue content
  policy before event admission; unknown metadata is held for review.
- [Initial slice complete] Persist validated video duration when available.
- [Initial slice complete] If duration is unavailable, estimate from the average
  of known-duration songs already queued for that event; estimated values do not
  feed that average.
- [Initial slice complete] Snapshot effective duration and its source on the
  transitional queue record; the eventual Performance owns this field.

### 3. Queue cutoff and event runtime protection

- [Initial slice complete] Calculate projected queue time as each effective video duration plus 30
  seconds of transition time.
- [Initial slice complete] Default to stopping new admissions when projected completion exceeds the
  event end.
- [Initial slice complete] Allow an explicit host/owner “allow queue overrun” override with audit.
- [Initial slice complete] Perform status, presence, cutoff, and insertion checks atomically so a rush
  of submissions cannot bypass the cutoff.
- [Initial slice complete] Prevent duplicate submissions caused by retries or double taps with a submission idempotency token.

### 4. Live theme admission and review

- [Initial slice complete] Evaluate the active reusable theme against event
  queue metadata and its bounded time window.
- [Initial slice complete] Persist eligible, review, and explicit rejected
  outcomes on the transitional queue record with a reason.
- [Initial slice complete] Release unresolved review entries into normal/Fair
  Queue eligibility when the theme ends; explicit rejections remain out.
- [Initial slice complete] Give authorized event hosts approve/reject controls
  and show the review reason in the queue manager view. Review distinguishes
  temporary theme incoherence from permanent content-policy rejection.
- [Planned] Move final theme admission ownership to the canonical Performance
  boundary and support richer rule authoring and overlapping-window policy.

Theme rules remain event-specific. A curated `ThemeSong` join is not required
unless reusable theme playlists become an MVP need.

### 5. Fair Queue hardening

- Preserve event-level Fair Queue and host override audit.
- [Initial slice complete] Use stable user identity when available, treat new
  performers as zero completed turns, and exclude skipped songs from completed
  turn history.
- [Initial slice complete] Serialize event queue reorder operations under the
  event lock while preserving scoped host override audit.
- [Initial slice complete] Add database-backed race coverage for simultaneous
  event admissions and reorder requests.
- [Planned] Add broader production-load coverage and admission throughput
  instrumentation when real usage warrants it.
- Add configurable fairness modes only where real usage requires them.

### 6. MVP UX, accessibility, reliability, and presentation polish

- Complete responsive event, access-code, queue, and host workflows.
- Run accessibility and mobile reviews.
- Improve presentation mode, retry states, and operational feedback.
- Complete the human QA pass across the MVP.
- [Planned] Upgrade the GitHub Actions runtime dependencies needed to fully
  resolve the Node.js 20 deprecation warning and verify a warning-free quality
  run.

## Post-MVP

- RSVP or “interested” state, separate from queue authorization.
- Rich event-first public discovery and shareable event pages.
- Event images, social preview cards, and Partiful-like presentation.
- Downloadable calendar files, then calendar subscription URLs and provider
  integrations that can reflect event changes.
- Optional geolocation as a secondary presence signal.
- Dynamically displayed event QR codes as an optional shortcut.
- Owner-configurable presence-security profiles and rotating display access.
- Curated reusable theme playlists backed by a `ThemeSong` join.
- Duet-aware Fair Queue attribution and collaborative-turn exceptions.
- Advanced Fair Queue modes and automatic event extension.
- The future user-to-user `Request` concept, distinct from Song and
  Performance.
- Stronger anti-sharing and physical-location enforcement.

## Dependencies and guardrails

Contextual venue membership is the authorization foundation for event and host
work. Event lifecycle is the prerequisite for presence-gated queue admission;
the initial lifecycle and gate are now implemented. Canonical
Song/Performance separation remains the long-term owner of queue and theme
admission state; this slice establishes the persisted identity boundary while
the current queue record continues to carry transitional fields safely.
Each phase needs architecture rationale, acceptance criteria, automated
business-rule and authorization coverage, and relevant roadmap/QA updates in
the same change. The CI quality gate includes the full RSpec suite,
project-source and Rake-aware RuboCop, Brakeman, dependency audit, template
lint, migration checks, and schema cleanliness verification; vendored
dependency sources are not treated as application code.

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

The finished items are foundations. Richer theme tooling and deeper
concurrency/load hardening remain planned MVP work.
