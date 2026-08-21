# Events and recurring event series

## Context / problem

Karaoke nights need a durable event boundary before themes, queue policies,
temporary delegation, or presence security can be scoped correctly. A recurring
schedule must also allow one occurrence to change without mutating the series.

## Decision

Create separate `Event` and `EventSeries` domain records. Both belong to a
`Venue`. An `Event` may belong to one series, but every occurrence owns its
editable title, schedule, and lifecycle fields. A one-off event has no series.

Recurring-series data describes future recurrence intent; generated occurrences
are ordinary events and are not runtime copies of the series. Venue owners and
venue hosts may manage events only in venues where their `VenueMembership`
authorizes them. `PlatformMembership` does not grant automatic venue control.

## Consequences / implications

An occurrence can be edited, cancelled, or rescheduled independently while its
series remains reusable. Event-scoped authorization becomes the boundary for
future themes, Fair Queue configuration, temporary host delegation, and presence
sessions. The current song queue remains venue-scoped until a later migration
explicitly associates performances with events.

## Deferred details

Recurrence expansion, timezone/DST edge cases, series editing UX, event
publication, event-level roles, queue migration, themes, Fair Queue, delegation,
presence, and QR/session security are deferred. The first implementation should
keep recurrence representation replaceable and avoid claiming those behaviors
exist.
