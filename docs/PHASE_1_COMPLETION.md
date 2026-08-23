# Historical Phase 1 Foundation Record

**Date Started:** February 15, 2026  
**Status:** Historical foundation record; not the final domain architecture

## Summary

This records the venue, role, and authorization foundation implemented in
February 2026. It remains a current-state reference, but its global role and
`VenueAdmin` decisions were compatibility-era choices. Phase 1 replaced them
with contextual `VenueMembership`; this document remains historical.

---

## Completed Tasks

### 1.1 ✓ Database Migrations

- **AddRoleToUsers**: Added `role` enum to users (owner: 0, admin: 1, performer: 2) with default "performer"
- **AddOwnerToVenues**: Added `owner_id` foreign key to venues table for venue ownership
- **AddPublicToVenues**: Added `public` boolean to venues (default: true) for discoverability
- **CreateVenueAdmins**: Created join table for managing multiple admins per venue with unique constraint

All migrations applied successfully. Database schema updated.

### 1.2 ✓ Models & Associations

- **User Model Updates**:
  - Added enum: `role` (owner, admin, performer)
  - Added associations: `owned_venues`, `admin_for_venues`, `venues_as_admin`
  - Added helper methods: `owner_of?(venue)`, `admin_of?(venue)`

- **Venue Model Updates**:
  - Added `belongs_to :owner` relationship
  - Added admin management through `venue_admins` join table
  - Added methods: `add_admin(user)`, `remove_admin(user)`, `is_admin?(user)`

- **VenueAdmin Model**: New model for managing admin assignments with validations

### 1.3 ✓ Route Changes

- **From**: Query parameter-based (`?venue_slug=joes-bar`)
- **To**: Slug-based nested routes (`/:venue_slug/songs`)

**New route structure:**

```text
GET  /                           # Welcome page
GET  /discover                   # Venue discovery/search
POST /venues/join/:slug          # Join venue
GET  /:venue_slug/songs          # Queue page (Turbo Frame ready)
POST /:venue_slug/songs          # Add song
PATCH/:venue_slug/songs/:id/finish_song  # Finish song (admin only)
PATCH/:venue_slug/songs/:id/skip_song    # Skip song (admin only)
GET  /:venue_slug/settings       # Venue settings (owner only)
PATCH/:venue_slug/settings       # Update settings (owner only)
GET  /:venue_slug/admins         # Admin list (owner only)
POST /:venue_slug/admins         # Add admin (owner only)
DELETE/:venue_slug/admins/:id    # Remove admin (owner only)
```

### 1.4 ✓ SCSS System Reorganization

**New organized structure** (5 files → 10 files):

1. **_colors.scss** - Enhanced with semantic mapping + green success color
2. **_tokens.scss** - NEW: Design tokens (spacing, radius, shadows, breakpoints, z-index)
3. **_typography.scss** - Existing (untouched)
4. **_forms.scss** - Existing (untouched)
5. **_layout.scss** - Existing (updated with new structure awareness)
6. **_components.scss** - NEW: Reusable component styles (cards, badges, buttons, alerts)
7. **_youtube.scss** - Existing (untouched)
8. **_animations.scss** - NEW: Turbo Frame and interaction animations
9. **_accessibility.scss** - NEW: WCAG 2.1 focused styles (skip links, focus states, reduced motion)
10. **_roles.scss** - NEW: Role-based visibility patterns
11. **_utilities.scss** - NEW: Utility classes (spacing, text, layout, etc.)

**Color system enhanced:**

- Existing colors: beige, midnight, cyan, yellow, magenta, ink
- **NEW**: $green (#2ECC71) for success states
- Semantic mapping: `$status-next`, `$status-queued`, `$status-skipped`, `$status-finished`, `$status-success`, `$status-error`
- Text and background color variables for consistency

### 1.5 ✓ Authorization Middleware

- **ApplicationController updates**:
  - `set_current_venue` - Extracts venue from URL path
  - `set_current_user` - Devise integration
  - `require_venue_for_songs` - Ensures venue context for queue routes
  - `require_admin!` - Authorization check (owner or admin)
  - `require_owner!` - Strict ownership check
  - `render_404` - Custom 404 handling

- **SongsController updates**:
  - Changed all redirect URLs to slug-based paths
  - Added `authorize_admin_for_queue_actions` for play/skip operations
  - Updated `set_song` to scope to Current.venue
  - Added role determination method: `determine_user_role`
  - Integrated Turbo Stream responses for real-time updates (preparation for Phase 3)

---

## Key Architectural Decisions

1. **Roles System**: Three-tier (Owner → Admin → Performer) balances control and simplicity
2. **Routing**: Slug-based paths are cleaner, more SEO-friendly, and easier to track venue context
3. **SCSS**: Custom system with no framework provides full control and minimal overhead
4. **Enums for Roles**: Type-safe, queryable, and performant vs. string roles
5. **VenueAdmin Join Table**: Allows efficient many-to-many owner/admin relationships

---

## Data Migration Notes

**Existing users and venues:**

- All existing users default to `role = 2` (performer)
- All existing venues have `owner_id = NULL` (will need manual assignment or migration task)
- All venues default to `public = true`

**Next steps will require:**

- Create a management console or migration script for admins setup
- Allow owners to assign admins after joining

---

## Files Modified

### Controllers

- `/app/controllers/application_controller.rb` - Route-based venue handling, authorization
- `/app/controllers/songs_controller.rb` - Role checks, URL updates, Turbo preparation

### Models

- `/app/models/user.rb` - Role enum, associations
- `/app/models/venue.rb` - Owner/admin associations
- `/app/models/venue_admin.rb` - NEW

### Routes

- `/config/routes.rb` - Nested slug-based structure

### Stylesheets

- `/app/assets/stylesheets/application.scss` - Reorganized import order
- `/app/assets/stylesheets/partials/_colors.scss` - Enhanced with semantic mapping + green
- `/app/assets/stylesheets/partials/_tokens.scss` - NEW
- `/app/assets/stylesheets/partials/_components.scss` - NEW
- `/app/assets/stylesheets/partials/_animations.scss` - NEW
- `/app/assets/stylesheets/partials/_accessibility.scss` - NEW
- `/app/assets/stylesheets/partials/_roles.scss` - NEW
- `/app/assets/stylesheets/partials/_utilities.scss` - NEW

### Database

- `/db/migrate/20260215171336_add_role_to_users.rb` - NEW
- `/db/migrate/20260215171339_add_owner_to_venues.rb` - NEW
- `/db/migrate/20260215171342_add_public_to_venues.rb` - NEW
- `/db/migrate/20260215171853_create_venue_admins.rb` - NEW

---

## Testing Recommendations

Before moving to Phase 2, verify:

```bash
# Verify migrations
rails db:migrate:status

# Test model associations
rails c
> user = User.first
> user.role  # Should be 2 (performer)
> user.admin_of?(venue)
> venue.is_admin?(user)

# Verify routes
rails routes | grep songs
# Should show /:venue_slug/songs routes

# Check SCSS compilation
rails assets:precompile
```

---

## Historical limitations / follow-up

1. Existing data may still need owner and legacy host assignment at deployment.
2. The current permission model needs the planned contextual membership
   migration.
3. Events, recurring series, themes, Fair Queue, temporary delegation, and
   presence/session security remain future work.

---

## Historical UI next steps

The historical UI plan below is superseded. Current presentation work is
planned in [ROADMAP.md](ROADMAP.md) and the
[presentation-surface decision](architecture/presentation_surfaces_and_routes.md):
route/surface contract, shared shell reset, state-aware event workspace,
focused event configuration, mobile-first performer queue, host/owner
operations, and dedicated desktop display mode.

---

## Quick Reference

### Role Checks in Views

```haml
- if Current.venue.owner_id == current_user.id
  / Owner only
- elsif Current.venue.is_admin?(current_user)
  / Admin or owner
- else
  / Performer (default)
```

### Authorization in Controllers

```ruby
require_owner!      # Only venue owner
require_admin!      # Owner or admin
authorize_song_owner  # Own song or admin (already in place)
```

### New URL Patterns

```ruby
venue_songs_path(venue.slug)        # /joes-bar/songs
venue_songs_path(venue_slug)        # Using string directly
edit_venue_song_path(venue_slug, song)  # /joes-bar/songs/:id/edit
```

### SCSS Utilities

```scss
// Spacing
.m-md, .p-lg, .gap-sm

// Colors  
.text-primary, .bg-success, .shadow-lg

// Roles
.admin-only, .owner-only, .performer-only

// Accessibility
.sr-only, :focus-visible

// Layout
.container, .flex, .grid-cols-2, .hidden
```
