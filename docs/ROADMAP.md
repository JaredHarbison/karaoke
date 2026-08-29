# Product Roadmap

Karaoke Queue is a multi-venue Rails app for collaborative karaoke nights.
This roadmap is product-oriented; architectural rationale lives in
[`docs/architecture/`](architecture/).

## Current status

The engineering, identity, contextual venue authorization, event/series,
reusable theme, initial Fair Queue, temporary delegation, presence-token,
short-code exchange, and initial event-lifecycle foundations are complete. The
remaining MVP work is the route/presentation reset, expanded UX,
accessibility, reliability, and human-QA sequence below.

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
  Performance queue record; Performance owns this field.

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
  outcomes through the canonical Performance admission boundary.
- [Initial slice complete] Release unresolved review entries into normal/Fair
  Queue eligibility when the theme ends; explicit rejections remain out.
- [Initial slice complete] Give authorized event hosts approve/reject controls
  and show the review reason in the queue manager view. Review distinguishes
  temporary theme incoherence from permanent content-policy rejection.
- [Initial slice complete] Move theme admission transitions and release rules
  to the canonical Performance boundary.
- [Initial slice complete] Provide venue-host rule authoring for required and blocked keywords.
- [Initial slice complete] Reject overlapping bounded theme windows on the same event so theme precedence is deterministic.
- [Planned] Expand rule types only when provider metadata and product policy support them.

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
- [Initial slice complete] Add realistic larger-queue coverage and publish
  admission outcome notifications for throughput instrumentation.
- [Planned] Measure production latency/volume and tune Fair Queue only when
  real usage identifies a bottleneck.
- Add configurable fairness modes only where real usage requires them.

### 6. MVP UX, accessibility, reliability, and presentation phase

This is intentionally a multi-slice phase. Each slice should be independently
reviewable, manually testable, and documented in the same commit.

#### 6.1 Route and surface contract

- [Planned] Make `/:venue_slug/events` the venue event index and discovery
  surface, with role-aware management actions rather than an admin-only page.
- [Planned] Reserve `/:venue_slug` for a future venue profile; use
  `/:venue_slug/events/:event_slug` for the event lobby and queue.
- [Initial slice complete] Introduce venue-scoped event slugs for user-facing
  event URLs; the remaining canonical event-workspace migration is still
  planned.
- [Planned] Remove `/songs` after queue links, forms, redirects, tests, and QA
  journeys move to the canonical event surface; do not preserve dead route
  compatibility indefinitely.
- [Planned] Keep `/settings` venue-scoped and separate from event operations.

#### 6.2 Presentation reset and shared shell

- [Initial slice complete] Establish one shared application shell for event,
  venue-management, theme, and recurring-event surfaces; queue and auth
  surfaces remain intentionally scoped follow-ups.
- [In progress] Keep the navbar limited to the root/venue identity and a
  role-labeled menu opener; expose role-aware navigation in a right-side drawer
  rather than a permanent sidebar or duplicated navbar links.
- [In progress] Replace the current page-by-page presentation layer with one shared
  application shell, responsive container, navigation, page header, cards,
  forms, buttons, links, alerts, and status treatments.
- [Planned] Define one shared alert/warning/success strategy, including
  consistent semantic colors, placement, persistence, and non-jumping layout.
- [Planned] Preserve the existing palette and semantic color mapping while
  consolidating it into concise design tokens and reusable SCSS primitives.
- [Initial slice complete] Standardize interactive color semantics across shared
  button primitives: magenta-filled for the single primary action, cyan-outline
  for secondary/navigation actions, magenta-outline for destructive actions,
  and green/yellow reserved for status and headings. Do not introduce
  page-specific button variants.
- [Initial slice complete] Use yellow for every heading and eyebrow, and Title
  Case for every visible heading and form/control label. Cyan remains limited
  to secondary and navigation affordances.
- [Planned] Use a compact mobile/tablet layout tier and a wider desktop tier.
- [Planned] Keep performers mobile-first, support hosts and owners from mobile
  through desktop, and make display mode desktop-oriented.
- [Planned] Delete obsolete page-specific styles and templates as each surface
  moves to the shared system.
- [In progress] Apply the shared shell and motion rules to authentication and
  queue pages while keeping existing sign-in/sign-up and queue behavior stable.
- [Initial slice complete] Add semantic main landmarks to authentication and
  discovery pages, announce registration errors, and improve keyboard focus
  when opening and closing the role menu. A live browser/assistive-technology
  audit remains a follow-up when browser tooling is available.
- [In progress] Keep primary CTA link states readable across hover, focus,
  active, and visited states; transient feedback must never produce
  magenta-on-magenta text.

#### 6.3 Event index and state-aware event workspace

- [Planned] Make the event page state-aware: scheduled lobby, live queue, and
  completed summary.
- [Planned] Keep the event page focused on status, context, lobby/queue, and
  concise operational actions rather than making it a giant settings form.
- [Planned] Give authorized users clear links to full event editing; avoid
  duplicate mutation surfaces on both show and edit pages.
- [Planned] Make the event name, venue, status, timing, and current queue
  context visible throughout the workflow.

#### 6.4 Event configuration and secondary operations

- [Initial slice complete] Add manager-only queue tabs for Themes, Temporary
  Hosts, and Event access/activity: venue admins can create, apply, and manage
  reusable themes and temporary hosts; active temporary hosts can reconcile
  held theme entries. The Themes toggle displays the number awaiting review,
  and the selected manager tab persists through queue actions and redirects.
- [Planned] Consolidate event name, timing, recurrence, queue policy, and
  occurrence editing into a focused configuration workflow.
- [Planned] Keep theme application, temporary host delegation, and presence
  code operations discoverable without crowding the primary queue surface;
  use focused panels or dialogs where the action is operationally needed.
- [Planned] Make recurrence structured and selectable rather than requiring
  users to type recurrence syntax.

#### 6.5 Performer queue UX

- [Initial slice complete] Move the queue onto the shared navbar and role menu;
  place song selection before the QR card and finished performers below it.
  Queue-specific behavior and the remaining mobile interaction polish are
  still planned.
- [In progress] Use one queue-card hierarchy: performer first name plus
  last-name initial and song title in ivory, with no redundant category pill;
  apply the shared primary, secondary, and destructive action semantics.
  Secondary actions share one Sass interaction rule across hover, focus, and
  disclosure-open states.
- [Planned] Paginate long queues without nested mobile scrolling; reveal more
  entries through a consistent pink outlined control while preserving fair order.
- [Initial slice complete] Normalize provider-style song titles for queue
  display without changing stored metadata or using the provider URL as the
  visible song name.
- [Initial slice complete] Ensure provider metadata and local QA fixtures save
  an explicit song title; legacy records without metadata remain identifiable
  for future backfill rather than silently using their URL as a title.
- [Initial slice complete] Add a provider-backed title backfill task for legacy
  queue records with missing titles; it requires `YOUTUBE_API_KEY` and skips
  records whose provider metadata cannot be retrieved.
- [Initial slice complete] Simplify the pause dialog copy and spacing while
  preserving the shared 1px yellow modal treatment; keep its actions compact
  and its close control square on hover/focus.
- [In progress] Keep the mobile shell compact and stable: preserve a usable
  keyboard skip link without a persistent success banner, keep brand and role
  menu controls on one row, and prevent drawer/page animation from shifting
  queue content.
- [Planned] Improve add-song feedback, validation errors, duplicate-submission
  messaging, retry states, and event-context preservation.
- [In progress] Keep event presence recovery visible and focused when a
  performer attempts admission without an active event session.
- [Initial slice complete] Send event-entry and event-queue submissions through
  the canonical event queue URL; require an access code only for performers,
  while venue owners and temporary hosts bypass it.
- [Initial slice complete] Remove the redundant event selector and explicit
  queue CTA from the event queue; Enter searches, and selecting a verified
  video queues it directly.
- [Initial slice complete] Present search results as horizontally browsable,
  vertically structured selection cards, with the next result visible on
  mobile.
- [Initial slice complete] Use the same Queue and Add Song tab
  structure on desktop and mobile so desktop no longer reserves a permanent
  add-song sidebar; keep QR access in presentation and host contexts.
- [Initial slice complete] Tighten desktop queue spacing and use compact
  icon-over-label mobile action rows: four columns for the Next card and three
  columns for ordinary cards while preserving accessible control sizes.
- [Initial slice complete] Use one centered, bounded Queue/Add Song toggle at
  every responsive tier; keep its inactive labels and outline cyan, its active
  tab cyan-filled, and its action groups right-aligned within a shared maximum.
- [Initial slice complete] Keep action labels ivory while preserving semantic
  icon colors, and make mobile action controls square without changing the
  desktop/tablet row treatment.
- [Initial slice complete] Keep the Next card’s cyan border and surface
  treatment consistent across desktop, tablet, and mobile.
- [Planned] Make selection state and the immediate queue action explicit.

#### 6.6 Host and owner operations

- [Planned] Improve finish, skip, pause, requeue, theme-review, cutoff, and
  authorization feedback for venue hosts and temporary event hosts.
- [Planned] Reduce divergent owner/host actions by using shared operational
  surfaces and focused secondary actions.

#### 6.7 Presentation and display mode

- [Planned] Refine now-playing, upcoming queue, event name, short-code, and
  host-facing access context for display screens.
- [Planned] Build display mode as a dedicated desktop-oriented surface rather
  than another variation of the performer queue.

#### 6.8 Accessibility and responsive review

- [Planned] Review keyboard flow, focus management, status announcements,
  labels, semantic structure, contrast, and error association.
- [Planned] Review queue, add-song, event, theme, presence-code, and host
  screens at narrow viewport sizes.

#### 6.9 Reliability and operational feedback

- [In progress] Use the venue's configured time zone for event, recurrence, and
  presence-code deadlines; keep event inputs at minute precision and show one
  active performer access code clearly.
- [Planned] Improve loading states, stale submissions, concurrency responses,
  unavailable metadata, expired presence, and recovery paths.

#### 6.10 Human QA completion

- [Planned] Run the page/action/result guide as owner, host, and performer;
  record failures, fix them in focused commits, and complete the MVP pass.
- [Planned] Use guided one-action QA interviews that carry setup forward across
  owner, host, performer, and display-mode journeys, recording both behavior and
  interaction clarity.
- [Planned] Repeat functional and visual QA after the presentation reset; the
  current QA findings are not considered closed merely because the layout is
  replaced.
- [Initial slice complete] Provide an idempotent, opt-in local QA fixture for
  owner, host, performer, venue, and event workflow testing.

#### 6.11 Discovery enhancements

- [Future] When venues have reliable coordinates, use browser location
  permission to suggest the nearest active/upcoming event in the resume area
  when the user has no previous venue.

- [Initial slice complete] Upgrade the GitHub Actions runtime dependencies needed to fully
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
admission state; Performance now owns the admission transitions while the
existing queue table continues to carry the fields safely.
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
concurrency/load hardening remain planned MVP work. Shared layout and broader
interaction cleanup remain a separate UI/UX overhaul informed by the guided QA
pass.
