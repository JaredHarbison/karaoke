# Karaoke Queue UI Implementation Phases

## Overview

This document outlines the phased approach to modernizing the UI with role-based access control, real-time Turbo Frames, slug-based routing, and a professional design system.

**Key Principles:**

- Highly accessible, conventional, modern, and professional
- Security and clarity highlighted throughout
- Custom SCSS system (no frameworks)
- Real-time updates via Turbo Frames
- Three user roles: Owner, Admin, Performer
- Venue discovery via QR code, location-based, or search

---

## Phase 1: Foundational Architecture (CURRENT)

### Phase 1 Objectives

Establish role system, routing structure, and SCSS organization.

### Phase 1 Tasks

#### 1.1 Database Migrations

- Add `role` enum to users table (owner, admin, performer)
- Add `owner_id` foreign key to venues table
- Add `created_at` index for sorting venues by proximity (prep for location feature)
- Add `public` boolean to venues (for discoverability)

#### 1.2 Models & Associations

- Update `User` model:
  - Add role enum with defaults
  - Add venue owner check method: `owner_of?(venue)`
  - Add admin check method: `admin_of?(venue)`
- Update `Venue` model:
  - Add `belongs_to :owner, class_name: 'User'`
  - Add associations for admins (has_many through join table)
  - Add methods: `admins`, `add_admin(user)`, `remove_admin(user)`

#### 1.3 Route Changes

- From: `?venue_slug=joes-bar` parameters
- To: `/:venue_slug/songs` nested routes
- Implement `set_current_venue` by path parameter instead of query param
- Session storage for venue context (for cross-page navigation)
- Routes structure:

  ```text
  GET  /
  GET  /sign_in
  GET  /sign_up
  
  GET  /:venue_slug/songs          # Queue page
  POST /:venue_slug/songs          # Add song
  GET  /:venue_slug/settings       # Admin/owner only
  GET  /:venue_slug/discover       # Join venue
  ```

#### 1.4 SCSS Reorganization

Current structure:

```text
_colors.scss (existing palette)
_forms.scss
_layout.scss
_typography.scss
_youtube.scss
```

New structure:

```text
_colors.scss           # Existing + new green success color
_tokens.scss           # Design tokens (spacing, shadows, radius)
_typography.scss       # Font families, scales
_forms.scss            # Form inputs, buttons
_layout.scss           # Grid, containers (reorganized)
_components.scss       # New: cards, badges, alerts
_roles.scss           # New: role-based visibility
_animations.scss      # New: Turbo transitions
_accessibility.scss   # New: focus states, skip links
_utilities.scss       # New: common utility classes
```

#### 1.5 Authorization Middleware

- Create `CurrentVenueScope` concern for ApplicationController
- Implement role-based before_action checks
- Ensure venue context is available in all views

### Phase 1 Deliverables

- [ ] Migrations created and tested
- [ ] Model associations updated
- [ ] Routes refactored to slug-based paths
- [ ] SCSS structure reorganized
- [ ] Authorization middleware implemented
- [ ] Tests passing

---

## Phase 2: UI & Component Architecture

### Phase 2 Objectives

Build foundational components and layout structure for role-based views.

### Phase 2 Tasks

#### 2.1 Layout Refactor

- Create `application.html.haml` with:
  - Persistent header (venue name, user context, role indicator, secure badge)
  - Main navigation (Home, Settings, Help)
  - Accessibility elements (skip link)
  - Flash messages (notice, alert, error)
- Create venue-specific layout: `venues/layout.html.haml`
- Create role-based layout variations

#### 2.2 Header Component

- Venue name prominently displayed
- Current user name with avatar placeholder
- Role indicator (with explanation tooltip)
- "Secure" badge/indicator
- Quick actions (settings for owner/admin, help, sign out)

#### 2.3 Queue Container & Structure

- Main queue section with Turbo Frame: `#songs-container`
- Queue subsections as separate Turbo Frames:
  - `#upcoming-songs` (rendered first)
  - `#finished-songs` (collapsed by default)
- Each song as smallest reusable component

#### 2.4 Color Implementation

- Define semantic color variables:
  - `$status-next: $cyan` (upcoming first song)
  - `$status-queued: $ink` (other queued)
  - `$status-skipped: $yellow` (postponed)
  - `$status-finished: $beige` (completed)
  - `$status-success: $green` (new: success actions)
  - `$status-error: $magenta` (existing: errors)
- Document all uses in SCSS comments

#### 2.5 Component Library (HAML mixins/partials)

Create reusable components:

- `_song_card.html.haml` (performer, title, artist, thumbnail, actions)
- `_action_button.html.haml` (play, skip, delete with icons)
- `_badge.html.haml` (role, status)
- `_user_context.html.haml` (avatar, name, role dropdown)
- `_venue_header.html.haml` (name, address, qr code)

### Phase 2 Deliverables

- [ ] New layout structure in place
- [ ] Header component implemented
- [ ] Color system documented and applied
- [ ] Component library established
- [ ] Turbo Frame structure set up

---

## Phase 3: Real-Time Updates with Turbo Frames

### Phase 3 Objectives

Implement live queue updates without manual refresh.

### Phase 3 Tasks

#### 3.1 Turbo Streams Setup

- Configure Rails for Turbo Streams (already in Gemfile likely)
- Create broadcast models:
  - `Song#create` → broadcasts to venue's songs frame
  - `Song#finish_song` → remove from upcoming, add to finished
  - `Song#skip_song` → visual update with status change
  - `Song#update` → update position/details

#### 3.2 ActionCable Configuration

- Set up ActionCable for venue-specific channels
- Create `QueueChannel` with venue context
- Subscribe clients to their venue's channel when viewing queue

#### 3.3 Stimulus Controllers

- `SongController`: song-specific interactions (play, skip, delete)
- `QueueController`: queue-level interactions (sorting, filtering)
- `DiscoveryController`: venue search/location features

#### 3.4 User Feedback During Updates

- Loading states on buttons
- Toast notifications for actions
- Smooth transitions between states (CSS animations)

### Phase 3 Deliverables

- [ ] Turbo Streams broadcasts configured
- [ ] ActionCable venue channels working
- [ ] Real-time song state updates working
- [ ] Stimulus controllers functional
- [ ] Loading indicators and animations in place

---

## Phase 4: Role-Based Views & Access Control

### Phase 4 Objectives

Implement three distinct user experiences based on roles.

### Phase 4 Tasks

#### 4.1 Owner View

- Full queue management (reorder, edit, delete any song)
- Settings page: manage admins, venue details, danger zone
- Analytics/reporting (songs played, most added, etc.)
- Access to all admin features
- Venue ownership transfer option

#### 4.2 Admin View

- Queue management (reorder, skip, finish songs)
- Add/remove songs from queue (management)
- Cannot access settings or delete venue
- Cannot manage other admins
- Limited analytics view

#### 4.3 Performer View (default)

- Add song form prominent at top
- View queue position (e.g., "You're #3")
- View upcoming performers and estimated times
- Edit/delete own songs only
- Real-time notifications when upcoming (e.g., "You're Next!")

#### 4.4 Authorization Layer

- Create `VenuePolicy` concern
- Implement authorization checks:
  - `can_edit_song?(song)` - owner/admin or song creator
  - `can_delete_song?(song)` - owner/admin or song creator
  - `can_manage_queue?` - owner or admin
  - `can_access_settings?` - owner only
- Use in controllers with `authorize!` checks

#### 4.5 UI Visibility Based on Role

- Show/hide buttons based on role
- Conditional forms (full form for admin, simple for performer)
- Role indicator in header with tooltip
- Disabled states with accessibility explanations

### Phase 4 Deliverables

- [ ] Authorization layer implemented and tested
- [ ] Three distinct view templates created
- [ ] Conditional rendering in place
- [ ] All role checks functional
- [ ] Tests covering authorization scenarios

---

## Phase 5: Discovery & Venue Joining

### Phase 5 Objectives

Allow users to discover and join venues through multiple methods.

### Phase 5 Tasks

#### 5.1 Venue Discovery Page (`/discover`)

- Search bar: find venues by name
- Location-based: show closest venues (requires lat/long)
- QR code scanner: join venue instantly
- List of public venues with join buttons

#### 5.2 QR Code Generation & Display

- Generate unique QR for each venue
- Display in queue page (performer reference)
- Include venue slug + unique identifier for security
- Ensure QR links to correct join flow

#### 5.3 Venue Join Mechanism

- `/venues/join/:slug` endpoint
- Validates venue exists and is public
- Auto-redirects to `/slug/songs` if authenticated
- Stores venue in session for navigation persistence
- Shows "New to this venue?" prompt on first join

#### 5.4 Location Services (Optional Phase 5.5)

- HTML5 Geolocation API
- Calculate distance to venues
- Sort by proximity
- Fallback to IP-based geolocation if needed

### Phase 5 Deliverables

- [ ] Venue discovery page created
- [ ] QR code generation and display working
- [ ] Join mechanism functional
- [ ] Search functionality working
- [ ] Location features (optional) integrated

---

## Phase 6: Accessibility & Polish

### Phase 6 Objectives

Ensure WCAG 2.1 AA compliance and professional polish.

### Phase 6 Tasks

#### 6.1 Accessibility Audit

- Keyboard navigation throughout app
- Screen reader testing (NVDA, JAWS, VoiceOver)
- Color contrast validation
- Form labels and ARIA attributes
- Focus management and skip links

#### 6.2 Keyboard Shortcuts

- `?` - Show help modal
- `n` - Add new song (focus form)
- `p` - Play next song (owner/admin)
- `s` - Skip current song (owner/admin)
- Accessible only when no form is focused

#### 6.3 Polish & Refinement

- Empty states with helpful copy
- Error messages with recovery hints
- Loading skeletons for Turbo transitions
- Mobile responsiveness final pass
- Performance optimization (asset caching, lazy loading)

#### 6.4 Security Indicators

- "Secure" badge on header
- HTTPS enforcement message
- Authentication status display
- Session timeout warnings

### Phase 6 Deliverables

- [ ] WCAG 2.1 AA compliance verified
- [ ] Keyboard navigation working throughout
- [ ] Screen reader compatibility tested
- [ ] Keyboard shortcuts implemented
- [ ] Security indicators visible

---

## Phase 7: Testing & Deployment

### Phase 7 Objectives

Comprehensive testing and production readiness.

### Phase 7 Tasks

#### 7.1 Test Coverage

- Unit tests for models (role checks, associations)
- Integration tests for routes and redirects
- Authorization tests for all roles
- Turbo Stream tests
- Feature specs for each role's workflow

#### 7.2 Performance Testing

- Load testing with multiple concurrent users per venue
- Turbo Frame update performance
- Asset pipeline optimization
- Database query optimization (N+1 checks)

#### 7.3 Security Review

- CSRF token validation
- Authorization enforcement on all endpoints
- SQL injection prevention
- XSS protection in templates
- Rate limiting on critical endpoints

#### 7.4 Browser/Device Testing

- Safari, Chrome, Firefox (latest versions)
- Mobile browsers (iOS Safari, Chrome Mobile)
- Tablet responsiveness
- Touch target sizes (min 48x48px)

#### 7.5 Deployment Checklist

- Environment variables set
- Database migrations run
- Asset preprocessing verified
- Caching headers configured
- Error monitoring set up

### Phase 7 Deliverables

- [ ] Test suite with >80% coverage
- [ ] All performance tests passing
- [ ] Security audit completed
- [ ] Cross-browser testing documented
- [ ] Deployment verified

---

## Implementation Timeline Estimate

| Phase | Complexity | Estimated Time | Prerequisites |
| ----- | ---------- | --------------- | ------------- |
| 1 | High | 4-6 hours | None |
| 2 | Medium | 3-4 hours | Phase 1 |
| 3 | High | 5-7 hours | Phases 1-2 |
| 4 | High | 6-8 hours | Phases 1-3 |
| 5 | Medium | 3-5 hours | Phases 1-4 |
| 6 | Medium | 3-4 hours | All prior |
| 7 | Medium | 4-6 hours | All prior |

Total: 28-40 hours

---

## Decision Log

- **Routing**: Slug-based paths (`/:venue_slug/songs`) instead of query params for cleaner URLs and SEO
- **Roles**: Three-tier (Owner, Admin, Performer) balances control and simplicity
- **Colors**: Using existing palette + green for success to maintain visual consistency
- **Framework**: Custom SCSS system for full control and minimal overhead
- **Real-time**: Turbo Frames + ActionCable for real-time updates without WebSocket overhead
- **Spectators**: Merged with Performer role (same view, no special indicator)
- **Auth**: Existing Devise + Google OAuth, adding authorization layer on top

---

## Notes for Future Reference

- Each phase builds on the previous one
- Phases can be parallelized (1 must complete first, then 2-4 can overlap)
- Phase 5 is semi-optional (venue discovery valuable but not critical MVP)
- Phase 6-7 recommended before production
- Refer to this document when checking what's next or prioritizing work
