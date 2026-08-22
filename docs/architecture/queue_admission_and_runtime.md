# Queue admission and runtime protection

## Context / problem

An event queue must prevent remote or premature submissions and should not
silently schedule performances beyond the event’s planned end. Video duration
may be missing from provider metadata, and many performers may submit at once.

## Decision

The initial MVP admission implementation requires an authenticated user, a
live event, and an active event presence session. Host actions now transition
events between scheduled, live, and completed. The permanent venue QR is a
navigation entry point; the current event access URL establishes event
presence. A short rotating display code remains planned. Presence expires at
event close plus a small grace period.

Projected queue runtime sums each Performance’s effective video duration plus a
30-second transition buffer. Known provider duration is preferred. If it is
missing, the Performance uses the average of known-duration songs already in
that event queue; estimated values do not feed the average. A safe fallback is
used when no known durations exist.

Admission stops when projected completion exceeds the event end unless an
explicit, auditable host/owner overrun setting is enabled. Status, presence,
runtime, and insertion checks must be serialized or otherwise made atomic.

## Consequences / implications

Presence is separate from Devise authentication. A user can remain signed in
after losing event queue authority. The queue needs durable duration snapshots,
an idempotent submission strategy, and database-backed concurrency protection.

## Deferred details

Exact code rotation interval, grace-period length, location signals, provider
duration refresh policy, and automatic event extension remain deferred.
