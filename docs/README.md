# Documentation

This directory contains current application, operations, and architecture
guidance. The roadmap is the only source for planned work; guides and model
references describe behavior that exists today.

## Start here

- [Product roadmap](ROADMAP.md)
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
- [Presentation surfaces and routes](architecture/presentation_surfaces_and_routes.md)

The current code uses one `User`, venue-scoped routes, contextual
`VenueMembership` authorization, event-scoped `Performance` queue entries, and
canonical provider-backed `Song` identities.

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
