# User identity and contextual venue permissions

## Context / problem

The app currently has one `User` table, a global role enum, and a legacy
`VenueAdmin` join model. A global role cannot accurately express that authority
belongs to a particular venue and may later vary by event.

## Decision

Keep one `User` identity model. Planned: replace the ambiguous global venue
admin representation with a contextual `VenueMembership` relationship that
holds a user's venue-specific permissions. Authorization must resolve the
relevant venue (and event when applicable) before granting access.

## Consequences / implications

Users remain identifiable across venues, while venue permissions become
explicit, queryable, and auditable. Existing `VenueAdmin` data needs a safe,
reversible migration and compatibility path.

## Deferred details

Membership roles, invitations, ownership transfer, event-level permissions,
and migration sequencing are intentionally deferred. This is a planned
architecture, not a claim about the current schema.
