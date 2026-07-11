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

Some current code still calls the host role `admin`. The planned rename and its
data migration are documented in
[`docs/UI_IMPLEMENTATION_PHASES.md`](docs/UI_IMPLEMENTATION_PHASES.md).

## Tech stack

- Ruby 3.3.0 and Rails 7.1
- PostgreSQL
- Hotwire (Turbo and Stimulus) with import maps
- ERB, Haml, and a custom Sass component system
- Devise and Google OAuth
- RSpec, Factory Bot, Capybara, and SimpleCov

## Architecture

Venue slugs form the application's tenancy boundary. `ApplicationController`
resolves the active venue into `Current`, and song lookups are performed through
that venue. Authorization then combines venue ownership, host membership, and
song ownership.

```text
/:venue_slug request
    -> resolve Current.venue
    -> authenticate Current.user
    -> authorize owner / host / performer action
    -> query Current.venue.songs
    -> render HTML or Turbo Stream response
```

`VenueAdmin` is the join model between users and venues for the role currently
shown to users as Host. `YoutubeService` keeps external video search and
validation logic outside the controllers.

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
bin/rails server
```

Open `http://localhost:3000`.

Copy `.env.example` to `.env` and fill in only the integrations you intend to
exercise. Never commit `.env`; it is ignored by Git.

## Quality checks

```sh
bundle exec rspec
bundle exec rspec --tag critical
```

The suite includes model, request, workflow, and system coverage. Request specs
exercise venue isolation and role-based queue permissions; the critical tag
provides a faster check of the main user paths.

## Project documentation

- [`docs/UI_IMPLEMENTATION_PHASES.md`](docs/UI_IMPLEMENTATION_PHASES.md) tracks
  the staged product and terminology migration.
- [`docs/PHASE_1_COMPLETION.md`](docs/PHASE_1_COMPLETION.md) records the
  foundational venue and authorization work.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) explains the development and commit
  conventions.

## Current direction

The next major phase completes the user-facing Host terminology migration,
continues the role-specific interface work, and deepens the end-to-end coverage
of sign-in, venue discovery, and live queue management.

## License

Karaoke Queue is available under the [MIT License](LICENSE).
