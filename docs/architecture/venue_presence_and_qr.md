# Venue presence and QR/session access

## Context / problem

A permanent printed venue QR is useful navigation but must not become a
permanent queue credential. Event access needs a bounded, privacy-aware presence
signal.

## Decision

Planned: keep a permanent venue QR for stable venue landing-page navigation.
For an active event, exchange an approved on-site presence check (coarse
location with consent, rotating presentation code, QR flow, or host approval)
for an event-scoped expiring presence/session credential. Rate-limit attempts,
expire sessions, and allow controlled host regeneration without invalidating
the permanent QR.

## Consequences / implications

Presence is event-scoped and time-limited; the printed QR is not proof of
physical presence or a reusable join secret. Privacy and accessibility fallbacks
are first-class requirements.

## Deferred details

Token format, rotation, re-entry, late starts, extended events, inactivity,
location retention, and abuse handling are deferred.
