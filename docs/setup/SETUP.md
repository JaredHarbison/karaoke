# Setup Guide

## Prerequisites

1. Ruby 3.3.0
2. PostgreSQL
3. A Google Cloud project only if Google sign-in or YouTube search is needed

## Initial Setup

1. Clone the repository and install dependencies:

```bash
git clone <your-repo-url>
cd karaoke
bundle install
bin/rails db:prepare
```

1. Create a `.env` file in the root directory (copy from `.env.example`):

```bash
cp .env.example .env
```

## Google OAuth Configuration

### Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Name your project (e.g., "Karaoke Queue")
4. Click "Create"

### Step 2: Configure Google Identity Services

1. In your project, go to "APIs & Services" → "Library"
2. Google+ API is retired; no separate Google+ API enablement is required for
   OpenID Connect sign-in.

### Step 3: Configure OAuth Consent Screen

1. Go to "APIs & Services" → "OAuth consent screen"
2. Select "External" (or "Internal" if using Google Workspace)
3. Click "Create"
4. Fill in the required fields:
   - App name: "Karaoke Queue"
   - User support email: Your email
   - Developer contact: Your email
5. Click "Save and Continue"
6. On "Scopes" page, click "Add or Remove Scopes"
7. Add these scopes:
   - `.../auth/userinfo.email`
   - `.../auth/userinfo.profile`
8. Click "Save and Continue"
9. Add test users if using "External" type while in development
10. Click "Save and Continue" → "Back to Dashboard"

### Step 4: Create OAuth Credentials

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth client ID"
3. Choose "Web application"
4. Name it "Karaoke Queue OAuth"
5. Under "Authorized redirect URIs", add:
   - For development: `http://localhost:3000/users/auth/google_oauth2/callback`
   - For production: `https://yourdomain.com/users/auth/google_oauth2/callback`
6. Click "Create"
7. Copy the **Client ID** and **Client Secret**
8. Add them to your `.env` file:

```bash
GOOGLE_OAUTH_CLIENT_ID=your_client_id_here
GOOGLE_OAUTH_CLIENT_SECRET=your_client_secret_here
```

## YouTube Data API Configuration

### Step 1: Enable YouTube Data API v3

1. In the same Google Cloud project, go to "APIs & Services" → "Library"
2. Search for "YouTube Data API v3"
3. Click on it and click "Enable"

### Step 2: Create API Key

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API key"
3. Copy the API key
4. (Optional but recommended) Click "Restrict Key" to:
   - Set Application restrictions (HTTP referrers for web, or IP addresses for server)
   - Set API restrictions to "YouTube Data API v3" only
5. Click "Save"
6. Add it to your `.env` file:

```bash
YOUTUBE_API_KEY=your_youtube_api_key_here
```

## Database Setup

Create your first user via Rails console:

```bash
bin/rails console
User.create!(email: "your@email.com", first_name: "Your", last_name: "Name", password: "SecurePassword123!", password_confirmation: "SecurePassword123!")
```

Or use Google OAuth to sign in directly.

## Running the Application

### Development

```bash
bin/dev
```

Visit `http://localhost:3000` and sign in.

### Production

The GitHub Actions workflow deploys successful pushes to `main` to Heroku when
its deployment credentials are configured. Set OAuth and YouTube credentials in
the deployment platform's secret/configuration store; do not place values in
repository files or command history.

## Multi-Tenancy / Venue Setup

To create a venue for your karaoke location:

```bash
rails console
owner = User.first
Venue.create!(name: "Joe's Bar", owner: owner, location: "123 Main St")
```

Access the venue by visiting:

- Development: `http://localhost:3000/joes-bar/events`
- Production: `https://yourdomain.com/joes-bar/events`

## Troubleshooting

### OAuth Issues

- **Redirect URI mismatch**: Make sure the redirect URI in Google Console exactly matches your app's URL + `/users/auth/google_oauth2/callback`
- **Google hasn't verified this app**: Normal in development. Click "Advanced" → "Go to App (unsafe)" during testing

### YouTube API Issues

- **Quota exceeded**: YouTube API has daily quota limits. Monitor usage in Google Cloud Console
- **API key not working**: Make sure the API key restrictions match your application's domain/IP

## Security Notes

- Never commit `.env` file to git (it's in `.gitignore`)
- Keep your Client Secret and API keys secure
- Use environment variables in production (Heroku Config Vars, AWS Secrets Manager, etc.)
- Consider rotating API keys periodically
