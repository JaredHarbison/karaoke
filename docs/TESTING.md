# Testing and quality

## Required checks

Run the checks relevant to the change and report the exact commands and result.
CI is authoritative for the full repository:

```sh
bundle exec rspec
bundle exec rubocop
bundle exec brakeman -q -x EOLRails
bundle exec bundle-audit check --update
bundle exec erb_lint app/views
bin/rails db:abort_if_pending_migrations
```

The pre-commit hook is a fast staged-change gate. It checks debug code and
obvious secrets, runs RuboCop for staged Ruby, ERB lint for staged ERB, runs a
small Rails boot sanity check, and runs critical specs for staged application
or spec changes. It does not replace CI.

RuboCop uses a checked-in `.rubocop_todo.yml` baseline for legacy offenses. New
files must pass the configured cops, and existing exclusions should shrink as
files are touched. Brakeman excludes only its Rails end-of-life lifecycle
advisory; application security warnings remain blocking.

## Test conventions

- Put model behavior in `spec/models/`, HTTP behavior in `spec/requests/`, and
  end-to-end behavior in `spec/system/`.
- Add business-rule and privileged-authorization coverage with the feature.
- Use factories and isolated examples.
- Test both the authorized and denied venue/event contexts.
- Add accessibility assertions or manual verification for user-facing UI.

SimpleCov is configured in `spec/rails_helper.rb` with a current 50% overall
floor. Coverage should increase with feature work; the report is not evidence
that a run passed unless the command exits successfully.

## Database and migration checks

For migrations, inspect `bin/rails db:migrate:status`, run the migration in a
disposable/test database, verify constraints and indexes, and check that the
schema is clean. Prefer safe, reversible migrations where practical.

## Documentation maintenance

Update architecture docs when architecture changes, roadmap docs when product
sequencing changes, and help content when a user or operator workflow changes.
Each commit should update relevant docs as needed.
