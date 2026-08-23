# User identity and contextual venue permissions

## Context / problem

The app has one `User` table. A global role cannot accurately express that authority
belongs to a particular venue and may later vary by event.

## Decision

Keep one `User` identity model. Phase 1 replaced the ambiguous global venue admin
representation with a contextual `VenueMembership` relationship that
holds a user's venue-specific permissions. Authorization must resolve the
relevant venue (and event when applicable) before granting access.

## Consequences / implications

Users remain identifiable across venues, while venue permissions become
explicit, queryable, and auditable. Phase 1 adds the membership table and
backfills existing venue owners, legacy venue admins, and users with an
existing venue association. Authorization and host management now resolve
through memberships; the legacy `VenueAdmin` table and global venue-role column
have now been removed. A separate `PlatformMembership` relationship is reserved
for application-wide staff authority and does not grant venue ownership.

User-facing identity collects first and last names at account creation. Compact
surfaces use a first name plus last-name initial; legacy accounts use a
sanitized email-derived fallback until they are updated.

## Deferred details

Membership role semantics beyond the current owner/admin/performer mapping,
PlatformMembership roles beyond the initial admin role, platform-admin
workflows such as venue-joining moderation, ownership transfer, event-level
permissions, and richer member management are deferred. Event and event-level
authority are not implemented.

## Planned UI/UX follow-up

The Phase 1 membership foundation does not add a new screen or change the
performer queue flow. Existing queue controls now resolve through the
membership boundary. Host management writes membership records directly.

The remaining frontend work is to make contextual authority visible and
manageable:

- Show the active venue and the user's venue-specific role clearly.
- Extend the membership-backed owner settings host management with explicit
  role editing, member visibility, and safer removal/ownership safeguards.
- Keep performer queueing unchanged while ensuring host controls appear only
  for the active venue membership.
- Add multi-venue membership navigation and empty/unauthorized states when
  users belong to multiple venues.
- Update help and accessibility copy when the management workflows become
  operational.
- Add an account profile flow for legacy users who need to supply their names.
