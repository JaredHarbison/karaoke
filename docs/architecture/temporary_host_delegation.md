# Temporary event host delegation

## Context / problem

An event may need host coverage from someone who should not receive a permanent
venue administration role.

## Decision

Delegation is represented by an event-scoped record with a delegated user,
authorizing venue host, explicit start/end times, and revocation state. Active
delegation grants queue-management authority only for that event and time
window. It does not mutate venue membership or grant event editing, theme, or
recurring-series authority.

## Consequences / implications

Authority can be audited and expires automatically. Existing contextual venue
membership remains the source of permanent venue authority.
The event page is the management surface for authorized permanent hosts.
It exposes active and revoked delegations without making delegated users
responsible for venue-wide administration.

## Deferred details

Notification, conflict resolution between delegations, and future event-host
management UX refinements remain deferred.
