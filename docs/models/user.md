# User model

`User` is the identity for password and Google OAuth sign-in. New accounts
require first and last names; `display_name` renders a compact first-name plus
last-initial form on queue surfaces.

Venue authority comes from `VenueMembership`: owner, admin (host), and
performer. `PlatformMembership` is separate application-wide authority and
does not grant venue access. Users can own venues, submit performances, receive
invitations, hold temporary event-host delegations, and create presence sessions.
