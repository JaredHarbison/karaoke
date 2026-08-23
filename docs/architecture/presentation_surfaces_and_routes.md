# Presentation surfaces and canonical routes

## Context / problem

The current application exposes queue, event, venue, recurrence, theme,
presence, and host operations through several partially overlapping pages. The
event detail page and event edit page both expose mutations, `/songs` carries
multiple queue contexts, and the event index is currently shaped like an
owner/host admin page even though it may become a public venue event discovery
surface.

The guided QA review also found that existing layout and styling obscure the
intended product model. Performers are primarily mobile users, hosts and owners
need mobile-to-desktop support, and display mode is a separate desktop use
case.

## Decision

Planned: reset the presentation layer around a shared application shell and a
small set of canonical surfaces.

- `/:venue_slug/events` is the venue event index and discovery surface. It is
  role-aware: public users see event information, while authorized owners and
  hosts receive relevant management actions.
- `/:venue_slug` is reserved for a future venue profile and is not the MVP
  event queue or lobby.
- `/:venue_slug/events/:event_slug` is the canonical event workspace. Its
  primary surface changes by lifecycle state: scheduled lobby, live queue, or
  completed summary.
- Full event configuration is a focused editing surface. The event workspace
  links to it rather than duplicating every mutation inline.
- Theme, temporary-host, and presence operations may be launched from focused
  panels or dialogs when hosts need them during queue operations, but they do
  not turn the queue into a settings dashboard.
- `/settings` remains venue-scoped and owns venue details, membership/host
  management, and venue configuration.
- `/songs` is not a target route. It will be removed after links, forms,
  redirects, tests, and QA journeys move to the canonical event workspace.
- Event slugs are now the user-facing identifier for event routes; numeric IDs
  remain an implementation detail. The broader canonical event-workspace and
  `/songs` removal are still planned slices.

The presentation reset will preserve domain behavior, authorization boundaries,
and semantic color decisions while replacing the current page-specific layout
system with concise shared tokens, primitives, and responsive rules. Mobile and
tablet share the compact tier; desktop receives the wider tier. Display mode is
desktop-oriented, while performer and host workflows remain usable on mobile.

## Consequences / implications

- Event state becomes the primary navigation context for queueing and event
  operations.
- Owner and host actions become easier to discover without requiring separate
  divergent dashboards.
- The event index can grow into public event discovery without introducing a
  second route family.
- Removing `/songs` requires a deliberate route migration across controllers,
  views, helpers, tests, QA guides, and external links.
- The layout reset requires a new visual QA pass in addition to functional
  regression testing.
- Existing palette and semantic color mapping remain stable, but obsolete
  page-specific SCSS and templates should be deleted as their replacements land.

## Deferred details

Exact event slug generation, collision handling, whether focused secondary
operations use dialogs or dedicated panels, event discovery filtering, venue
profile content, real-time queue updates, and the final display-mode controls
remain implementation details for their respective slices.
