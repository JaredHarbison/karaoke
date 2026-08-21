# Temporary event host delegation

## Context / problem

Host authority may be needed for one event without granting a permanent venue
role or changing venue membership.

## Decision

Planned: delegate host authority for a specific event with explicit start/end
times, scoped permissions, revocation, and an auditable grant. Do not mutate a
permanent venue role to represent temporary authority.

## Consequences / implications

Authorization checks must evaluate venue membership, event scope, and current
time. Expiry and revocation become safety-critical behavior.

## Deferred details

Grant ownership, renewal, overlapping grants, invitation acceptance, audit
retention, and exact permission names are deferred.
