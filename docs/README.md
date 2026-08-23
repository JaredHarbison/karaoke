# Documentation

This directory contains current-state guidance and explicitly labeled planned
architecture for Karaoke Queue. The roadmap is product-oriented; architecture
docs explain decisions without claiming future work is implemented.

## Start here

- [Product roadmap](ROADMAP.md)
- [Phase 0 completion record](PHASE_0_COMPLETION.md)
- [Definition of Done](../CONTRIBUTING.md#definition-of-done)
- [Testing and quality](TESTING.md)
- [Human QA journeys](qa/README.md)
- [Security guidance](SECURITY.md)
- [Accessibility guidance](ACCESSIBILITY.md)
- [Architecture decisions](architecture/)
- [Application help content](help/)

## Current architecture references

- [Authentication](architecture/authentication.md)
- [Multi-tenancy](architecture/multi_tenancy.md)
- [Current request context](models/current.md)
- [Current models](models/)
- [Planned presentation surfaces and routes](architecture/presentation_surfaces_and_routes.md)

The current code uses one `User`, venue-scoped routes, and contextual
`VenueMembership` authorization. The completed Phase 1 decision and its
remaining UI follow-ups, including PlatformMembership, are in [identity and
venue permissions](architecture/identity_and_venue_permissions.md).

## Quality tools

The Gemfile configures RSpec, RuboCop, Brakeman, bundler-audit, and ERB lint.
The pre-commit hook runs fast checks over staged changes; CI runs the full
authoritative gate. A missing required tool is a failure, not a skipped pass.

```sh
bin/rspec
bundle exec rubocop
bundle exec brakeman -q
bundle exec bundle-audit check --update
bundle exec erb_lint app/views
```

Update relevant documentation in the same commit when behavior, architecture,
operations, or developer workflow changes.
