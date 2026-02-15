# OAuth & Authentication Architecture

## Devise Configuration

### Modules Enabled

```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable,
       :omniauthable, omniauth_providers: [:google_oauth2]
```

| Module | Purpose |
|--------|---------|
| database_authenticatable | Password-based authentication |
| registerable | User signup (currently disabled via routes) |
| recoverable | Password reset |
| rememberable | "Remember me" functionality |
| validatable | Email/password validation |
| omniauthable | OAuth provider support |

### OAuth Providers

Currently supports Google OAuth 2.0 via OmniAuth.

Configuration:
```ruby
# config/initializers/devise.rb
config.omniauth :google_oauth2,
                ENV['GOOGLE_OAUTH_CLIENT_ID'],
                ENV['GOOGLE_OAUTH_CLIENT_SECRET'],
                scope: 'email,profile',
                prompt: 'select_account'
```

## Authentication Flow

### Google OAuth

1. **User clicks**: "Sign in with Google" button
2. **Redirects to**: `/users/auth/google_oauth2`
3. **Google redirects back**: `/users/auth/google_oauth2/callback`
4. **OmniAuthCallbacksController**:
   - Calls `User.from_omniauth(auth)`
   - Creates or finds user
   - Signs in user
5. **Redirect**: To song queue or error page

### Password Authentication

1. Collapsible form on login page
2. Standard Devise password flow
3. Email + password fields

## User Creation

### From OAuth

```ruby
User.from_omniauth(auth) do |user|
  user.email = auth.info.email
  user.password = Devise.friendly_token[0, 20]  # Random password
end
```

### From Password

Via Devise form (signup currently disabled but password auth works).

## Session Management

- Uses Devise's session handling
- Persisted via Rails session store
- Remember-me token optional

## Routes

Protected routes require authentication:
- `/songs` - Songs index
- `/welcome` - Welcome page

Both have `before_action :authenticate_user!`

## Security Notes

- `.env` stores OAuth credentials (never committed)
- Client Secret never exposed in frontend
- OAuth callback implements state verification
- Passwords encrypted with Devise bcrypt
