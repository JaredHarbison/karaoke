# User identity and contextual venue permissions

## Context / problem

The app currently has one `User` table, a global role enum, and a legacy
`VenueAdmin` join model. A global role cannot accurately express that authority
belongs to a particular venue and may later vary by event.

## Decision

Keep one `User` identity model. Phase 1 begins replacing the ambiguous global venue
admin representation with a contextual `VenueMembership` relationship that
holds a user's venue-specific permissions. Authorization must resolve the
relevant venue (and event when applicable) before granting access.

## Consequences / implications

Users remain identifiable across venues, while venue permissions become
explicit, queryable, and auditable. Phase 1 adds the membership table and
backfills existing venue owners, legacy venue admins, and users with an
existing venue association. Existing `VenueAdmin` authorization remains as a
compatibility path until call sites and management workflows move to
memberships.

## Deferred details

Membership role semantics beyond the current owner/admin/performer compatibility
mapping, invitations, ownership transfer, event-level permissions, and final
legacy-table removal are deferred. The migration is in progress; event and
event-level authority are not implemented.
