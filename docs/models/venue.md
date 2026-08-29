# Venue model

`Venue` is the tenancy boundary. It has a unique slug, optional owner,
contextual memberships, public-discovery settings, time zone, explicit-lyrics
policy, and a stable permanent presence token.

A venue owns performances, events, recurring series, reusable themes, and
invitations. `Current.venue` is resolved from the venue-scoped request route
before venue data is queried or authorized.
