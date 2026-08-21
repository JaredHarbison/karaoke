# Fair Queue principles

## Context / problem

A simple FIFO queue can let one performer monopolize a collaborative karaoke
night, while rigid fairness can make host operations frustrating.

## Decision

The first implementation orders an event queue by completed turns recorded in
the existing event-scoped `Song` history, then uses stable queue position and ID
tie-breaking. A performer’s additional queued songs count as later turns in the
same ordering pass. Venue-level queues retain their existing FIFO ordering.
Host pause/unpause reordering remains the explicit override mechanism.

## Consequences / implications

Queue order reflects participation history without exposing unnecessary personal
history. Manual overrides and exceptional cases should be visible and auditable.
The current Fair Queue ordering is a service boundary; configurable mode,
explanatory UI, and durable override audit remain future work.

## Deferred details

Skipped songs, duets, newly joined performers, concurrency, configurable
fairness modes, position messaging, and durable override persistence are
deferred.
