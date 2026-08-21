# Recurring event series and editable occurrences

## Context / problem

Queue rules, themes, presence, and host authority belong to a particular
karaoke night. Recurring nights also need shared scheduling without forcing a
change to every occurrence.

## Decision

Phase 2 now has separate `Event` and `EventSeries` records and a first
venue-scoped management surface.
Both belong to a `Venue`; an `Event` may belong to one series, while every
occurrence owns its editable title, schedule, and lifecycle fields. A one-off
event has no series. `PlatformMembership` does not grant automatic venue
control.

## Consequences / implications

Events provide the future boundary for queue state, lifecycle, settings, and
audit history. Series provide reusable scheduling; occurrence overrides make
exceptions explicit and independently editable. Venue owners and hosts manage
events only through their contextual `VenueMembership`.

The current UI exposes event listing and host-managed event/series forms. The
first generator supports daily and weekly rules, materializes occurrences
idempotently, and preserves existing occurrence edits. It does not attach songs
to an event.

## Deferred details

Monthly/complex recurrence syntax, timezone/DST edge cases beyond the current
timezone-aware generator, cancellation, archival, publication, conflict
handling, and migration from the current venue queue are deferred.
