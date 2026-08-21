# Fair Queue principles

## Context / problem

A simple FIFO queue can let one performer monopolize a collaborative karaoke
night, while rigid fairness can make host operations frustrating.

## Decision

Planned: Fair Queue favors performers with fewer completed turns before repeat
turns. It needs deterministic, explainable tie-breaking and explicit host
override authority. The mode is event-scoped and independently configurable.

## Consequences / implications

Queue order reflects participation history without exposing unnecessary personal
history. Manual overrides and exceptional cases should be visible and auditable.

## Deferred details

Skipped songs, duets, newly joined performers, tie-breaking, position messaging,
concurrency, and override persistence are deferred.
