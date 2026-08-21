# Fair Queue principles

## Context / problem

A simple FIFO queue can let one performer monopolize a collaborative karaoke
night, while rigid fairness can make host operations frustrating.

## Decision

The first implementation orders an event queue by completed turns recorded in
the existing event-scoped `Song` history, then uses stable queue position and ID
tie-breaking. A performer’s additional queued songs count as later turns in the
same ordering pass. Venue-level queues retain their existing FIFO ordering.
Performers with no completed history are treated as having zero completed
turns.
Hosts can enable or disable Fair Queue per event, and pause/unpause actions are
recorded as event-scoped overrides.

## Consequences / implications

Queue order reflects participation history without exposing unnecessary personal
history. The event queue explains its active mode, and recent host overrides are
visible to authorized venue users. The ordering service remains isolated from
the canonical Song model and can evolve without a queue-domain migration.

## Deferred details

Skipped songs, duets, newly joined performers, concurrency, configurable
fairness modes beyond the event toggle, and position messaging are deferred.
