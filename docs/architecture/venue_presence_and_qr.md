# Venue presence and QR/session access

## Context / problem

A permanent printed venue QR is useful navigation but must not become a
permanent queue credential. Event access needs a bounded, privacy-aware presence
signal without requiring owners to print a new QR for every event.

## Decision

Planned MVP: keep one permanent venue QR for stable venue landing-page
navigation. Resolve it to the active event, next upcoming event, or event
discovery. After an event starts, display a short readable rotating code on
host/presentation screens and exchange its successful entry for an event-scoped
expiring presence/session credential. The code is not shown before the event
starts. Separate printed event QRs are optional future convenience, not the
security foundation.

Rate-limit attempts, expire sessions at event close plus grace, and allow host
regeneration without invalidating the permanent venue QR. A static QR or code
is not a perfect proof of physical presence; optional location and stronger
anti-sharing signals remain future work.

Planned owner control: expose a venue-level presence-security profile with a
conservative default and an optional stricter mode. The stricter mode may
rotate the QR/short code shown on presentation or host displays and reduce
re-entry tolerance. It must affect only dynamic event access—not the permanent
printed venue QR—and must have an accessibility fallback for performers who
cannot scan or read a changing code.

## Consequences / implications

Presence is event-scoped and time-limited; the printed QR is not proof of
physical presence or a reusable join secret. Privacy and accessibility fallbacks
are first-class requirements.

## Deferred details

Exact token storage, owner profile names, code rotation interval, re-entry,
late starts, extended events, inactivity, location retention, and abuse
handling are deferred. No owner-facing toggle should be presented until its
selected profile changes actual access enforcement.
