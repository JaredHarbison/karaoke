# Karaoke Queue

Karaoke Queue is a multi-venue Rails application for running a collaborative
karaoke night. Performers join a venue and add songs from their phones, while a
venue owner or host manages the shared queue.

The project started as a small single-host queue and is being expanded into a
venue-scoped product. That evolution is visible in the domain model, slug-based
routes, role-aware authorization, and the migration notes under `docs/`.

## What it does

- Keeps upcoming, skipped, postponed, and completed songs in a shared queue
- Scopes queue data and URLs to a venue
- Lets performers manage their own song requests
- Lets owners and venue hosts advance or reorder the queue
- Supports venue discovery and joining
- Searches for karaoke videos and validates selected YouTube URLs
- Uses Turbo Streams for queue updates without a frontend framework
- Supports password and Google OAuth authentication through Devise

## Roles

- **Owner** creates and configures a venue and can appoint hosts.
- **Host** runs the karaoke queue for a venue.
- **Performer** joins a venue and submits or updates their own songs.

The current implementation still contains the legacy `admin` role and
`VenueAdmin` join model. They are compatibility-era foundations, not the final
permission architecture. The next domain phase will move venue permissions to
contextual venue membership; this Phase 0 change does not perform that
migration.

## Tech stack

- Ruby 3.3.0 and Rails 7.2
- PostgreSQL
- Hotwire (Turbo and Stimulus) with import maps
- ERB, Haml, and a custom Sass component system
- Devise and Google OAuth
- RSpec, Factory Bot, Capybara, and SimpleCov

## Architecture

Venue slugs form the application's tenancy boundary. `ApplicationController`
resolves the active venue into `Current`, and queue lookups are performed
through that venue. Authorization then combines venue ownership, contextual
venue membership, and performance ownership.

```text
/:venue_slug request
    -> resolve Current.venue
    -> authenticate Current.user
    -> authorize owner / host / performer action
    -> query Current.venue queue records
    -> render HTML or Turbo Stream response
```

`VenueMembership` is the contextual join model between users and venues for
owner, host, and performer membership. `YoutubeService` keeps external video
search and validation logic outside the controllers. The target route and
presentation surfaces are documented in
[`docs/architecture/presentation_surfaces_and_routes.md`](docs/architecture/presentation_surfaces_and_routes.md).

## Running locally

Prerequisites:

- Ruby 3.3.0
- PostgreSQL
- A Google OAuth client if Google sign-in is required
- A YouTube Data API key if video search is required

Install and prepare the application:

```sh
bundle install
bin/rails db:prepare
bin/dev
```

Open `http://localhost:3000`.

`bin/dev` starts Rails together with a small Sass watcher. View and Ruby
changes reload normally; changes to any Sass partial automatically invalidate
the application stylesheet while the server keeps running. It also runs
Rails' asset cleanup task on startup, retaining the two newest compiled asset
versions.

To clean generated assets manually:

```sh
bin/rails 'assets:clean[2]'
```

Copy `.env.example` to `.env` and fill in only the integrations you intend to
exercise. Never commit `.env`; it is ignored by Git.

## Quality checks

```sh
bundle exec rspec
bundle exec rubocop
bundle exec brakeman -q
bundle exec bundle-audit check --update
bundle exec erb_lint app/views
```

The pre-commit hook runs a fast staged-change gate. CI is authoritative for the
full suite and repository-wide security, dependency, style, and template
checks. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`docs/TESTING.md`](docs/TESTING.md).

## Project documentation

- [`docs/ROADMAP.md`](docs/ROADMAP.md) describes the agreed MVP and post-MVP
  sequencing.
- [`docs/architecture/`](docs/architecture/) records planned and current
  architectural decisions.
- [`docs/help/`](docs/help/) contains the version-controlled guides rendered at
  `/help`, with visibility determined by guide audience and user role.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) explains the development and commit
  conventions.

## Current direction

Phase 0 established documentation, engineering guardrails, and internal help.
Phase 1 established contextual `VenueMembership` authorization and
`PlatformMembership` identity. Phase 2 event/series and reusable-theme
foundations are now in progress; Fair Queue and later event operations follow.

## License

Karaoke Queue is available under the [MIT License](LICENSE).
