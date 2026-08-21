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
idempotently, and preserves existing occurrence edits. Existing `Song` records
can now optionally point to an event for transitional event-scoped queueing;
venue-level songs remain supported.

Planned MVP event lifecycle adds scheduled, live, and completed states. Queue
submission is unavailable before a host starts the event and closes after event
completion. Admission checks must be atomic so simultaneous submissions cannot
bypass event or runtime limits.

## Deferred details

Monthly/complex recurrence syntax, timezone/DST edge cases beyond the current
timezone-aware generator, cancellation, archival, publication, conflict
handling, and the eventual canonical `Performance` migration from the current
`Song` queue object are deferred.
