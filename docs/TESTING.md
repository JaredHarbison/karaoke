# Test Configuration and Running Guide

## Overview
This project uses RSpec for comprehensive test coverage with near-100% target across models, controllers, and integration tests.

## Test Structure

### Models (`spec/models/`)
- **User Spec** - User model associations, roles, helper methods
- **Venue Spec** - Venue model associations, admin management, slug generation
- **Song Spec** - Song model associations, scopes, venue isolation
- **VenueAdmin Spec** - VenueAdmin join model, validations, uniqueness

### Request/Integration Tests (`spec/requests/`)
- **Songs Spec** - Song CRUD, authorization, role-based access
- **Venues Spec** - Venue discovery, joining, settings, admin management

### Factories (`spec/factories/`)
- **Users Factory** - Create users with different roles (owner, admin, performer)
- **Venues Factory** - Create venues with optional admins, songs, performers
- **Songs Factory** - Create songs with different states (queued, finished, skipped)
- **VenueAdmins Factory** - Create admin associations

## Running Tests

### All Tests
```bash
bundle exec rspec
```

### Model Tests Only
```bash
bundle exec rspec spec/models/
```

### Request Tests Only
```bash
bundle exec rspec spec/requests/
```

### Specific Test File
```bash
bundle exec rspec spec/models/user_spec.rb
```

### Critical Tests Only (Tagged with `:critical`)
```bash
bundle exec rspec --tag critical
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
