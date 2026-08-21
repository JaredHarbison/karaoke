# Recurring event series and editable occurrences

## Context / problem

Queue rules, themes, presence, and host authority belong to a particular
karaoke night. Recurring nights also need shared scheduling without forcing a
change to every occurrence.

## Decision

Phase 2 implementation begins with separate `Event` and `EventSeries` records.
Both belong to a `Venue`; an `Event` may belong to one series, while every
occurrence owns its editable title, schedule, and lifecycle fields. A one-off
event has no series. `PlatformMembership` does not grant automatic venue
control.

## Consequences / implications

Events provide the future boundary for queue state, lifecycle, settings, and
audit history. Series provide reusable scheduling; occurrence overrides make
exceptions explicit and independently editable. Venue owners and hosts manage
events only through their contextual `VenueMembership`.

## Deferred details

Timezone rules, recurrence syntax, cancellation, archival, publication,
conflict handling, and migration from the current venue queue are deferred.
