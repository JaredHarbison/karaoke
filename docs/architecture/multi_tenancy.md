# Multi-Tenancy Architecture

## Overview

The Karaoke Queue app supports multiple venues (karaoke locations), each with their own queue and users.

## Components

### 1. Venue Model

- Represents a physical karaoke location
- Has unique slug for URL routing
- Contains many songs and users

### 2. Current Context

- Stores current venue and user per request
- Accessible via `Current.venue` and `Current.user`
- Automatically cleared after each request

### 3. Query scoping

- Controllers and services explicitly scope venue-owned queries through
  `Current.venue` or an equivalent venue relation.
- Users currently optionally belong to a venue; planned permissions are
  documented in [identity and venue permissions](identity_and_venue_permissions.md).

### 4. ApplicationController

Sets current venue/user before each request:

```ruby
before_action :set_current_venue  # Parse venue_slug param
before_action :set_current_user   # Set current_user via Devise
```

## Flow

1. **User visits**: `http://localhost:3000/joes-bar/songs`
2. **Controller sets**: `Current.venue = Venue.find_by(slug: "joes-bar")`
3. **Song queries**: Scope through `Current.venue` before loading records
4. **On create**: New songs auto-assigned to `Current.venue`

## Session Persistence

Venue slug is stored in session:

```ruby
session[:venue_slug] = venue_slug
```

This persists the venue choice across navigation.

## Future: Subdomain Routing

joes-bar.karaoke.app

Currently venue is accessed via URL parameter. Can be upgraded to subdomain routing:

```text
joes-bar.karaoke.app
```

Implementation would be in `ApplicationController.set_current_venue`:
def set_current_venue
  venue_slug = request.subdomain
  Current.venue = Venue.find_by(slug: venue_slug) if venue_slug.present?
end

```ruby
def set_current_venue
  venue_slug = request.subdomain
  Current.venue = Venue.find_by(slug: venue_slug) if venue_slug.present?
end
```

## Authorization

Current authorization combines venue ownership, contextual `VenueMembership`
assignments, and song ownership. The legacy `VenueAdmin` table has been removed;
venue memberships are now the only contextual permission assignment.

The contextual membership direction and remaining cleanup are documented in
[identity and venue permissions](identity_and_venue_permissions.md).
