# Security Guidelines

This is guidance and a review checklist, not a certification or claim that all
listed controls are implemented. Venue authorization now resolves through
contextual `VenueMembership` records; the legacy `VenueAdmin` table has been
removed. Event-level authorization is future work. Run the configured security
checks and report their actual results.

This document outlines security best practices and vulnerability prevention strategies based on OWASP Top 10 and industry standards.

## Security Standards

### OWASP Top 10 (2023)

1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable & Outdated Components
7. Authentication & Session Management Failures
8. Software & Data Integrity Failures
9. Logging & Monitoring Failures
10. SSRF (Server-Side Request Forgery)

## Implementation Guidelines

### 1. Authentication & Authorization

#### Password Security

```ruby
# ✅ Good: Using Devise with bcrypt
devise :database_authenticatable, :validatable

# Password requirements
validates :password, length: { minimum: 12 },
                    format: { with: /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/ }

# ✅ Good: Use Devise token auth for APIs
devise :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

# ❌ Avoid: Plain text passwords or weak hashing
user.password = "123456"  # INSECURE
BCrypt::Password.create("password", cost: 4)  # Cost too low
```

#### OAuth & Social Login

```ruby
# ✅ Good: Validate and scope OAuth tokens
config.omniauth :google_oauth2,
                ENV['GOOGLE_OAUTH_CLIENT_ID'],
                ENV['GOOGLE_OAUTH_CLIENT_SECRET'],
                scope: ['email', 'profile'],
                access_type: 'offline',
                prompt: 'select_account'

# ✅ Validate state parameter (CSRF protection for OAuth)
def from_omniauth(auth)
  user = User.find_or_create_by(email: auth.info.email)
  user.update(
    google_uid: auth.uid,
    name: auth.info.name
  )
  user
end

# ❌ Avoid: Requesting excessive scopes
scope: 'email,profile,drive'  # Only request what you need
```

#### Authorization Checks

```ruby
# ✅ Good: Explicit authorization checks
def require_owner!
  unless current_venue.owner == current_user
    redirect_to root_path, alert: 'Unauthorized'
  end
end

# ✅ Good: Scope queries to current user
songs = current_user.songs.where(venue_id: current_venue.id)

# ❌ Avoid: Trusting user input for authorization
Song.find(params[:id])  # Doesn't check ownership
```

### 2. SQL Injection Prevention

Always use parameterized queries:

```ruby
# ✅ Good: Parameterized queries (Rails default)
User.where("email = ?", user_email)
Song.where(venue_id: venue_id, status: status)
User.find_by_sql(["SELECT * FROM users WHERE email = ?", email])

# ✅ Good: Use ORM methods
User.where(email: email)
Song.joins(:venue).where(venues: { id: venue_id })

# ❌ NEVER: String interpolation with user input
User.where("email = '#{params[:email]}'")  # SQL INJECTION!
User.find_by_sql("SELECT * FROM users WHERE email = '#{email}'")  # INJECTION!
```

### 3. Cross-Site Scripting (XSS) Prevention

Never output user input without sanitization:

```erb
<!-- ✅ Good: Rails auto-escapes by default -->
<p><%= @song.performer %></p>
<p><%= link_to @venue.name, venue_path(@venue) %></p>

<!-- ✅ Good: Explicit HTML safe content -->
<div><%= sanitize @song.description, tags: ['p', 'br'] %></div>

<!-- ✅ Good: Use tag helpers -->
<input type="text" value="<%= @song.url %>">
<%= tag.button @song.performer, class: 'btn' %>

<!-- ❌ NEVER: Raw HTML from user input -->
<%= raw @song.description %>  <!-- XSS VULNERABILITY! -->
<%= @song.description.html_safe %>  <!-- XSS! -->
```

Content Security Policy (CSP):

```ruby
# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.base_uri :self
    policy.default_src :self, :https
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data
    policy.object_src :none
    policy.script_src :self, :https
    policy.style_src :self, :https, :unsafe_inline
  end
end
```

### 4. Cross-Site Request Forgery (CSRF) Protection

Rails provides CSRF protection by default:

```ruby
# ✅ Good: Rails default protection enabled
protect_from_forgery with: :exception

# ✅ Skip for APIs with token auth
protect_from_forgery with: :null_session, if: :api_request?

# ❌ NEVER: Disable CSRF protection
protect_from_forgery with: :null_session  # On ALL endpoints
```

### 5. Data Encryption

Encrypt sensitive data:

```ruby
# ✅ Good: Use encrypted attributes
class User < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :phone_number
end

# ✅ Good: HTTPS everywhere
config.force_ssl = true
config.ssl_options = { hsts: { expires_in: 365.days } }

# ✅ Good: Use environment variables for secrets
ENV['DATABASE_PASSWORD']
ENV['GOOGLE_OAUTH_CLIENT_SECRET']

# ❌ NEVER: Hardcoded secrets in code
api_key = "abc123xyz"  # EXPOSED!
password = "secret"    # INSECURE!
```

### 6. Session Management

Secure session configuration:

```ruby
# ✅ Good: Secure cookies
Rails.application.config.session_store :cookie_store,
  key: '_karaoke_session',
  secure: true,
  httponly: true,
  same_site: :lax

# ✅ Good: Devise session timeout
Devise.setup do |config|
  config.timeout_in = 30.minutes
  config.remember_for = 2.weeks
end

# ✅ Good: Regenerate session ID after login
def login
  reset_session
  session[:user_id] = user.id
end

# ❌ NEVER: Store sensitive data in sessions (unencrypted by default)
session[:password] = user.password
session[:api_key] = current_user.api_key
```

### 7. Dependency Management

Keep dependencies up to date:

```bash
# ✅ Regular security audits
bundle audit
npm audit

# ✅ Update dependencies
bundle update
npm update

# ✅ Lock file security
# Commit Gemfile.lock and yarn.lock

# Configure Dependabot (GitHub)
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: bundler
    directory: "/"
    schedule:
      interval: weekly
    allow:
      - dependency-type: "all"

  - package-ecosystem: npm
    directory: "/"
    schedule:
      interval: weekly
```

### 8. Input Validation & Sanitization

Validate all user input:

```ruby
# ✅ Good: Strict validations
class Song < ApplicationRecord
  validates :performer, presence: true, length: { maximum: 255 }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
end

# ✅ Good: Whitelist & sanitize
allowed_tags = ['p', 'br', 'strong', 'em']
sanitized_html = sanitize(user_input, tags: allowed_tags)

# ✅ Good: Use dedicated gems for validation
gem 'rails-html-sanitizer'
gem 'json_schemer'

# ❌ NEVER: Trust user input
Song.create(performer: params[:performer])  # Need validation
render_html(@venue.description)  # Needs sanitization
```

### 9. API Security

Secure API endpoints:

```ruby
# ✅ Good: API authentication
class Api::SongsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_api_token, if: :api_request?
  
  def create
    @song = current_user.songs.build(song_params)
    # Rate limiting
    check_rate_limit!
  end
  
  private
  
  def verify_api_token
    user_id = decode_jwt(request.headers['Authorization'])
    @current_user = User.find(user_id)
  rescue => e
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end

# ✅ Good: Rate limiting
gem 'rack-attack'

# config/initializers/rack_attack.rb
class Rack::Attack
  throttle('api/ip', limit: 100, period: 1.hour) do |req|
    req.ip if req.path.start_with?('/api')
  end
end

# ✅ Good: API versioning (security updates don't break clients)
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :songs
  end
end

# ✅ Good: Comprehensive logging
Rails.logger.info "User #{current_user.id} accessed songs"
```

### 10. Error Handling & Logging

Handle errors securely:

```ruby
# ✅ Good: Generic error messages for users
rescue ActiveRecord::RecordNotFound
  render json: { error: 'Not found' }, status: :not_found

# ✅ Good: Detailed logs for debugging
Rails.logger.error "Database connection failed: #{e.message}"
Rails.logger.debug "User #{current_user.id} action details"

# ✅ Good: Sensitive data not in logs
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [:password, :api_key, :token]

# ❌ NEVER: Show stack traces to users
raise "Database error: #{e.backtrace.join("\n")}"
render json: { error: e.message }, status: 500

# ❌ NEVER: Log sensitive data
Rails.logger.info "User password: #{user.password}"
```

### 11. Security Headers

Implement security headers:

```ruby
# ✅ Good: Add security headers in middleware
class SecurityHeadersMiddleware
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, response = @app.call(env)
    
    headers['X-Content-Type-Options'] = 'nosniff'
    headers['X-Frame-Options'] = 'DENY'
    headers['X-XSS-Protection'] = '1; mode=block'
    headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    headers['Permissions-Policy'] = 'geolocation=(), microphone=()'
    
    [status, headers, response]
  end
end
```

### 12. Third-Party Integrations

Secure external integrations:

```ruby
# ✅ Good: Validate API responses
response = HTTParty.get(url)
raise "Invalid response" unless response.is_a?(Hash)

# ✅ Good: Use whitelisted domains
ALLOWED_YOUTUBE_DOMAINS = ['www.youtube.com', 'youtube.com'].freeze

# ✅ Good: API key rotation
ENV['YOUTUBE_API_KEY']  # Changed regularly
ENV['GOOGLE_CLIENT_SECRET']  # Stored securely

# ❌ NEVER: Trust external APIs completely
@title = HTTParty.get(url)['title'].html_safe  # Could be XSS
```

## Pre-Commit Security Checks

Before committing, verify:

```bash
# Run security audit
bundle exec bundle-audit check --update

# Check for exposed secrets
bundle exec secrets-check
git diff --cached | grep -E "password|api_key|secret"

# Run OWASP dependency check
bundle add owasp_dependency_check

# Check for unsafe patterns
bundle exec brakeman -q

# Verify no debug code
git diff --cached | grep -E "binding\.pry|debugger|byebug"

# Manual checklist
- [ ] No hardcoded credentials
- [ ] All user input validated
- [ ] CSRF protection enabled
- [ ] SQL queries parameterized
- [ ] XSS prevention via escaping
- [ ] Authenticated endpoints require login
- [ ] Authorization checks present
- [ ] Sensitive data encrypted
- [ ] Logs don't contain secrets
- [ ] Dependencies up to date
- [ ] Security headers configured
```

## Testing Security

### Unit Tests

```ruby
describe User do
  it 'encrypts sensitive attributes' do
    user = User.create(email: 'test@example.com')
    expect(user.encrypted_email).not_to eq('test@example.com')
  end
  
  it 'validates strong passwords' do
    user = User.new(password: 'weak')
    expect(user.valid?).to be false
  end
end
```

### Integration Tests

```ruby
describe 'Authorization', type: :request do
  it 'prevents unauthorized access' do
    other_user_song = create(:song)
    sign_in(other_user)
    
    delete "/songs/#{other_user_song.id}"
    expect(response).to have_http_status(:forbidden)
  end
end
```

### Security Scanning

```bash
# Brakeman: Rails security analyzer
gem 'brakeman', require: false
bundle exec brakeman

# Bundler Audit: Vulnerable dependencies
bundle exec bundle-audit check --update

# Semgrep: Code scanning
brew install semgrep
semgrep --config=p/security-audit app/

# OWASP ZAP: Web app scanner
curl https://www.zaproxy.org/download/ # Docker available
```

## Vulnerability Response Plan

### If Vulnerability Found

1. **Assess Severity** - CVSS score, exploitability
2. **Create Patch** - Fix with tests
3. **Test** - Verify fix doesn't break functionality
4. **Deploy** - To production safely
5. **Communicate** - Inform affected users if needed
6. **Document** - Update security guidelines

### Responsible Disclosure

For external vulnerabilities:

1. Report privately to <security@yourdomain.com>
2. Allow 90 days for patch
3. Coordinate public disclosure
4. Credit reporter (if desired)

## Security Resources

### OWASP

- <https://owasp.org/www-project-top-ten/> - Top 10 vulnerabilities
- <https://owasp.org/www-project-dependency-check/> - Dependency checker
- <https://cheatsheetseries.owasp.org/> - Cheat sheets

### Ruby/Rails Security

- <https://brakemanscanner.org/> - Brakeman static analyzer
- <https://bundler.io/man/bundle-audit.1.html> - Bundler audit
- <https://api.rubyonrails.org/v7.0/classes/Rails/Application/Configuration.html#attribute-c-force_ssl> - Force SSL

### Tools & Scanning

- <https://www.zaproxy.org/> - OWASP ZAP penetration testing
- <https://securityheaders.com/> - Check security headers
- <https://csp-evaluator.appspot.com/> - CSP validator

### Learning

- <https://portswigger.net/web-security> - Web Security Academy
- <https://www.hacksplaining.com/> - Security lessons
- <https://snyk.io/learn/> - Security learning platform

## Team Responsibilities

### All Developers

- Follow security guidelines
- Validate & sanitize input
- Use parameterized queries
- Keep dependencies updated
- Report security issues

### Security Lead

- Review security code
- Conduct security reviews quarterly
- Manage vulnerability response
- Keep team trained

### DevOps/Infra

- Configure security headers
- Manage environment secrets
- Monitor for intrusions
- Update production systems

### QA/Testing

- Test security features
- Run vulnerability scans
- Test with malicious input
- Verify fixes work

## Quick Security Checklist

- ✅ SSL/TLS enabled (force_ssl = true)
- ✅ CSRF protection enabled
- ✅ Content Security Policy configured
- ✅ Security headers set (X-Frame-Options, etc.)
- ✅ No hardcoded secrets
- ✅ Input validation on all forms
- ✅ SQL queries parameterized
- ✅ User output escaped
- ✅ Authentication required for sensitive actions
- ✅ Authorization checks enforced
- ✅ Rate limiting on APIs
- ✅ Error messages don't expose system details
- ✅ Sensitive data in logs filtered
- ✅ Dependencies audited
- ✅ Secrets managed via environment variables
