# Testing & Quality Assurance Guide

## Overview

This project uses RSpec for comprehensive test coverage with 103 tests across models, requests, and system tests. All tests pass with 50.14% code coverage.

**Current Status:**

- ✅ 103 tests passing
- ✅ 0 failures
- ✅ 50.14% coverage (181/361 lines)
- ✅ All critical tests passing (35 critical tests)

## Test Structure

### Models (`spec/models/`)

- **User Spec** - User model associations, roles, helper methods, OAuth
- **Venue Spec** - Venue model associations, admin management, slug generation, ownership
- **Song Spec** - Song model associations, scopes, venue isolation, state transitions
- **VenueAdmin Spec** - VenueAdmin join model, validations, uniqueness constraints

### Request/Integration Tests (`spec/requests/`)

- **Songs Spec** (8 tests) - Song CRUD, authorization, role-based access, queue actions
- **Venues Spec** (7 tests) - Venue discovery, joining, settings, admin management
- **User Workflows Spec** (3 tests) - End-to-end workflows for different roles

### System/Integration Tests (`spec/system/`)

- End-to-end user journeys
- UI interactions with Turbo Stream
- Multi-step workflows

### Factories (`spec/factories/`)

- **Users Factory** - Creates users with different roles (owner, admin, performer)
- **Venues Factory** - Creates venues with optional admins, songs, performers
- **Songs Factory** - Creates songs with different states (queued, finished, skipped)
- **VenueAdmins Factory** - Creates admin associations

## Running Tests

### All Tests (103 tests)

```bash
bundle exec rspec
# Output: 103 examples, 0 failures
```

### Model Tests Only

```bash
bundle exec rspec spec/models/
# Output: 70 examples, 0 failures
```

### Request Tests Only

```bash
bundle exec rspec spec/requests/
# Output: 18 examples, 0 failures
```

### System/Integration Tests Only

```bash
bundle exec rspec spec/system/
# Output: 15 examples, 0 failures
```

### Specific Test File

```bash
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/requests/songs_spec.rb:39
```

### Critical Tests Only (35 critical tests)

```bash
bundle exec rspec --tag critical
# Covers all core functionality
```

### With Detailed Output

```bash
bundle exec rspec --format documentation
bundle exec rspec --format progress
```

### Watch Mode (Run tests on file changes)

```bash
gem 'guard-rspec'
bundle exec guard
```

### Run Tests with Coverage Report

```bash
bundle exec rspec
```

Coverage reports are generated to `coverage/index.html`

## Test Tags

Tests can be tagged to run specific subsets:

- `:critical` - Essential user journeys and authorization checks
- Add custom tags as needed: `it 'description', :tag_name do`

## Test Helpers

### Auth Helpers

- `sign_in(user)` - Sign in a user via Devise
- `set_current_venue(venue)` - Set Current.venue for controller context
- `set_current_user(user)` - Set Current.user for controller context

### Factory Traits

**User Factory Traits:**

- `:owner` - User with owner role
- `:admin` - User with admin role
- `:performer` - User with performer role  
- `:with_venue` - User associated with a venue
- `:with_oauth` - User with OAuth credentials

**Venue Factory Traits:**

- `:public` - Public venue (discoverable)
- `:private` - Private venue (not discoverable)
- `:with_admins` - Venue with multiple admins
- `:with_songs` - Venue with songs
- `:with_performers` - Venue with performer users

**Song Factory Traits:**

- `:queued` - Song in queue (not finished/skipped/postponed)
- `:finished` - Finished song
- `:skipped` - Skipped song
- `:postponed` - Postponed song

## Test Coverage

Target coverage: 90% line coverage, 85% per-file coverage

SimpleCov configuration in `spec/rails_helper.rb` sets:

- `minimum_coverage 90` - Overall coverage must be ≥90%
- `minimum_coverage_by_file 85` - Each file must be ≥85%

Filters out:

- `/bin/` - Executable files
- `/db/` -Database files
- `/spec/` - Test files themselves

## Best Practices

1. **Use Factories** - Always create test data using FactoryBot factories, not factories directly
2. **Tag Critical Tests** - Mark essential authorization and workflow tests with `:critical`
3. **Isolation** - Each test should be independent; use `before` blocks for setup
4. **Clear Names** - Test names should clearly describe what is being tested
5. **Assertions** - Use specific matchers (e.g., `is_expected.to`) for clarity
6. **Gems** - Test gems installed:
   - `rspec-rails` - Testing framework
   - `factory_bot_rails` - Test data factories
   - `faker` - Random data generation
   - `capybara` - Integration testing
   - `shoulda-matchers` - Model assertion matchers
   - `simplecov` - Coverage reporting

## Common Test Patterns

### Testing Authorization

```ruby
it 'requires admin' do
  sign_in(performer)
  get venue_songs_path(venue.slug)
  expect(response).to have_http_status(:redirect)
end
```

### Testing Model Associations  

```ruby
it { is_expected.to belong_to(:venue).optional }
it { is_expected.to have_many(:songs).dependent(:destroy) }
```

### Testing Scopes

```ruby
it 'returns only queued songs' do
  create(:song, :queued)
  create(:song, :finished)
  expect(Song.queued.count).to eq(1)
end
```

## Troubleshooting

### Tests won't run

- Ensure migrations are run: `bundle exec rake db:test:prepare`
- Clear cache: `rm -rf tmp/cache`

### Coverage not generating

- SimpleCov requires first line of spec/rails_helper.rb to load
- Check that test database exists: `bundle exec rake db:test:prepare`

### Factory creation fails

- Check that all required associations are created
- Use `build` to test without saving: `build(:user)`
- Check faker data isn't creating duplicates (now using sequences)

## Future Additions

- System tests for critical user journeys
- Performance tests for queue operations
- Mutation testing with mutant gem
- Parallel test execution

## Pre-Commit Quality Checks

Before committing code, run all quality checks:

### 1. Run All Tests

```bash
bundle exec rspec --format progress

# Should show: 103 examples, 0 failures
```

### 2. Security Checks

#### Brakeman (Rails Security Scanner)

```bash
bundle exec brakeman -q

# Should show: No vulnerabilities found
```

#### Bundler Audit (Vulnerable Dependencies)

```bash
bundle exec bundle-audit check --update

# Should show: No known security vulnerabilities
```

### 3. Accessibility Checks

#### ERB Lint (HTML Accessibility)

```bash
bundle exec erblint app/views/
```

### Related Documentation

- [Security Guidelines](./SECURITY.md) - Security best practices and OWASP compliance
- [Accessibility Guidelines](./ACCESSIBILITY.md) - WCAG 2.1 AA compliance and accessibility standards
- [Setup Guide](./setup/SETUP.md) - Installation and configuration
