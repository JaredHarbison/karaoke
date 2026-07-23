# Documentation Directory

Complete documentation for the Karaoke Queue application covering setup, architecture, testing, security, and accessibility.

## Quick Links

### Getting Started

- **[Setup Guide](./setup/SETUP.md)** - Installation, configuration, OAuth setup
- **[Getting Started](./setup/GETTING_STARTED.md)** - Quick start guide and features overview

### Development

- **[Testing & QA](./TESTING.md)** - Running tests, pre-commit checks, code quality
- **[Testing Coverage](./TESTING.md#test-coverage)** - 103 tests, 50.14% coverage, all passing ✅

### Quality & Standards

- **[Security Guidelines](./SECURITY.md)** ⭐ NEW - OWASP Top 10, vulnerability prevention, pre-commit security checks
- **[Accessibility Guidelines](./ACCESSIBILITY.md)** ⭐ NEW - WCAG 2.1 AA compliance, testing tools, manual checks

### Architecture & Design

- **[Architecture Overview](./architecture/authentication.md)** - OAuth, authentication flow, session management
- **[Multi-Tenancy](./architecture/multi_tenancy.md)** - Venue-based isolation, Current context, routing
- **[Current Context](./models/current.md)** - Request-scoped venue and user storage
- **[Product Roadmap](./ROADMAP.md)** - Planned event, presentation, joining, theme, and optional queue features

### Reference

- **[API Endpoints](./api/endpoints.md)** - Songs, venues, YouTube integration endpoints
- **[Data Models](./models/)** - User, Venue, Song, VenueAdmin schemas and associations

## Structure

docs/
├── ACCESSIBILITY.md          ⭐ NEW - WCAG 2.1 AA standards and guidelines
├── SECURITY.md               ⭐ NEW - OWASP Top 10 and vulnerability prevention
├── TESTING.md                - Test running, coverage, pre-commit checks
├── README.md                 - This file
├── api/
│   └── endpoints.md          - API endpoint documentation
├── architecture/
│   ├── authentication.md      - OAuth and session management
│   └── multi_tenancy.md       - Venue-based multi-tenancy
├── models/
│   ├── current.md            - Current context (request-scoped)
│   ├── song.md               - Song model and associations
│   ├── user.md               - User model and roles
│   └── venue.md              - Venue model and ownership
└── setup/
    ├── SETUP.md              - Detailed setup guide
    └── GETTING_STARTED.md    - Quick start and feature overview

```text
docs/
├── ACCESSIBILITY.md          ⭐ NEW - WCAG 2.1 AA standards and guidelines
├── SECURITY.md               ⭐ NEW - OWASP Top 10 and vulnerability prevention
├── TESTING.md                - Test running, coverage, pre-commit checks
├── README.md                 - This file
├── api/
│   └── endpoints.md          - API endpoint documentation
├── architecture/
│   ├── authentication.md      - OAuth and session management
│   └── multi_tenancy.md       - Venue-based multi-tenancy
├── models/
│   ├── current.md            - Current context (request-scoped)
│   ├── song.md               - Song model and associations
│   ├── user.md               - User model and roles
│   └── venue.md              - Venue model and ownership
└── setup/
    ├── SETUP.md              - Detailed setup guide
    └── GETTING_STARTED.md    - Quick start and feature overview
```

## Recent Updates

### ✅ Test Suite (February 2026)

- All 103 tests passing ✅
- 35 critical tests covering core functionality
- 50.14% code coverage (181/361 lines)
- Fixed authorization, view templates, and queue operations

### ⭐ New Documentation (February 2026)

- **[Security Guidelines](./SECURITY.md)** - Comprehensive OWASP compliance
- **[Accessibility Guidelines](./ACCESSIBILITY.md)** - WCAG 2.1 AA standards
- Pre-commit security and accessibility checks
- Integration with development workflow

## Key Standards

### Security

- ✅ OWASP Top 10 2023 compliance
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS prevention (Rails auto-escaping)
- ✅ CSRF protection (Rails default + validation)
- ✅ Authentication via Devise with OAuth
- ✅ Data encryption for sensitive attributes
- ✅ Dependency auditing (bundle-audit)

### Accessibility

- ✅ WCAG 2.1 AA compliance target
- ✅ Semantic HTML structure
- ✅ Keyboard navigation support
- ✅ Screen reader compatibility
- ✅ Color contrast (4.5:1 minimum)
- ✅ Focus indicators on all interactive elements
- ✅ Image alt text and ARIA labels
- ✅ Form labels and error messaging

### Testing

- ✅ 103 tests covering models, requests, and system workflows
- ✅ 35 critical tests for core functionality
- ✅ 50.14% code coverage with SimpleCov
- ✅ RSpec with FactoryBot factories
- ✅ Shoulda matchers for model testing
- ✅ Accessibility testing integration
- ✅ Pre-commit quality checks (tests + security + accessibility)

## Running Pre-Commit Checks

Before committing, verify code quality:

```bash
# Run all tests (103 tests, ~5 seconds)
bundle exec rspec --format progress

# Security scan
bundle exec brakeman -q
bundle exec bundle-audit check --update

# Accessibility lint
bundle exec erblint app/views/

# Code style
bundle exec rubocop

# Or use the pre-commit hook
git config core.hooksPath .git-hooks
```

See [TESTING.md](./TESTING.md) for detailed pre-commit setup.

## Documentation Maintenance

This documentation should be updated when:

1. **Architecture Changes** - Update [architecture/](./architecture/) docs
2. **New Security Patterns** - Update [SECURITY.md](./SECURITY.md)
3. **Accessibility Issues** - Update [ACCESSIBILITY.md](./ACCESSIBILITY.md)
4. **Setup Instructions** - Update [setup/](./setup/) guides
5. **API Changes** - Update [api/endpoints.md](./api/endpoints.md)
6. **New Features** - Add to appropriate category

Before committing updated docs:

- Verify code examples are current
- Test all commands in examples
- Check links and references
- Ensure consistency with codebase

## Support

For questions or issues:

1. Check the relevant documentation file
2. Review code comments and git history
3. Run tests to verify behavior
4. Check GitHub issues for similar problems
