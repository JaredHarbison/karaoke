# Recurring event series and editable occurrences

## Context / problem

Queue rules, themes, presence, and host authority belong to a particular
karaoke night. Recurring nights also need shared scheduling without forcing a
change to every occurrence.

## Decision

Planned: model an event occurrence separately from an optional recurring event
series. A single occurrence can store an override for time, venue settings, or
other supported event attributes without mutating the series defaults.

## Consequences / implications

Events provide the boundary for queue state, lifecycle, settings, and audit
history. Series provide reusable scheduling; occurrence overrides make
exceptions explicit and independently editable.

## Deferred details

Timezone rules, recurrence syntax, cancellation, archival, publication,
conflict handling, and migration from the current venue queue are deferred.
