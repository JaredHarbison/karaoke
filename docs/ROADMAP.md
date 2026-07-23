# Product Roadmap

This roadmap captures planned product work beyond the current owner/host queue interface. Ordering is directional; each phase should receive a technical design and acceptance criteria before implementation.

## Event Foundation

- Add an `Event` or karaoke-session model so queue behavior, QR codes, themes, and optional rules belong to a specific night rather than permanently to a venue.
- Add a first-class performer display name to the user profile; keep the song-level performer value as a historical snapshot.
- Define event lifecycle states, start/end times, timezone handling, and archival behavior.

## Venue Presentation Screen

- Add a presentation-focused venue screen for TVs and projectors.
- Show now playing, next performers, queue status, current event details, and a scannable join QR.
- Keep controls on the authenticated owner/host interface rather than the public presentation display.
- Support automatic live updates without reloading.

## Performer Venue Join

- Offer location-based venue discovery and joining when the performer grants location access.
- Rank active nearby events using venue coordinates and a bounded proximity check.
- Always provide QR joining as the privacy-preserving and permission-free fallback.
- Make location consent explicit, minimize retained location data, and avoid background tracking.

## Event QR Lifecycle

- Support permanent, printable venue QR codes that open a stable venue landing page; venues should not need to reprint signage for every event.
- Treat the printed QR as navigation, not proof that a performer is physically present and not as a permanent queue-join credential.
- When an event is active, exchange an on-site presence check for an event-scoped, expiring join session.
- Offer several owner/host-selectable presence policies:
  - One-time, coarse location check with explicit consent and no retained precise coordinates.
  - A rotating short code displayed on the venue presentation screen for performers who decline location access.
  - Host approval as an accessibility and device-capability fallback.
- Generate the active event session and rotating presentation code 30 minutes before the scheduled event.
- Keep a controlled owner/host regeneration action for compromised or incorrectly shared event codes without invalidating the permanent printed QR.
- Require an active on-site presence session before a performer can join or submit songs; off-site submissions are out of scope.
- Rate-limit join attempts and expire presence sessions after the event or a configurable inactivity period.
- Define behavior for code sharing, late starts, extended events, re-entry, already-joined performers, and devices without location support.
- Never place a long-lived secret or reusable authorization token directly in the printed QR.

## Theme Rules

- Let owners/hosts set or change the active event theme throughout the night.
- Show the active theme at the top of Add Song, immediately before search.
- Validate selected songs against the active theme when reliable metadata is available.
- Treat uncertain matches as host-reviewable rather than falsely authoritative.
- Preserve the theme that applied when each song was added.

## Optional Queue Modes

The following event-level modes must be independently enabled or disabled by an owner/host:

### Fair Queueing

- Prefer performers with fewer completed songs over performers who have already sung more often.
- Define tie-breaking, newly joined performers, skipped songs, duets, and host overrides.
- Explain position changes to performers without exposing unnecessary personal history.

### Host Queue Rearrangement

- Allow owners/hosts to reorder queued songs and explicitly choose who is next.
- Provide accessible non-drag controls alongside optional drag-and-drop.
- Record manual overrides and prevent concurrent edits from silently replacing one another.

### Voting

- Let eligible event participants vote on queued songs or performers.
- Define vote limits, visibility, tie-breaking, abuse controls, and whether voting influences order or is informational only.
- Keep owner/host override authority and allow voting to be disabled at any time.

## Delivery Notes

- Real-time venue-scoped updates are a prerequisite for presentation mode, voting, and trustworthy multi-device queue state.
- Event settings need authorization, auditability, and safe defaults.
- Mobile/tablet navigation can use role-aware tabs: Queue by default for owners/hosts and Add Song by default for performers.
