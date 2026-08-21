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

## Planned UI/UX follow-up

The Phase 1 membership foundation does not add a new screen or change the
performer queue flow. Existing queue controls now resolve through the
membership boundary, with the legacy `VenueAdmin` read path retained during
cutover.

The remaining frontend work is to make contextual authority visible and
manageable:

- Show the active venue and the user's venue-specific role clearly.
- Replace owner settings' legacy host list with membership-backed host/member
  management, including invitations and safe removal/role changes.
- Keep performer queueing unchanged while ensuring host controls appear only
  for the active venue membership.
- Add multi-venue membership navigation and empty/unauthorized states when
  users belong to multiple venues.
- Update help and accessibility copy when the management workflows become
  operational.
