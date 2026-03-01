# 🎤 Karaoke Queue - Getting Started

## What's Been Implemented

### ✅ Completed Enhancements

1. **Security Fixed**
   - Removed hardcoded credentials from views
   - Added authentication enforcement on all controllers
   - Users now own their songs and can only edit/delete their own

2. **Google OAuth + Password Auth**
   - Sign in with Google (primary method)
   - Password authentication available (collapsed by default)
   - OmniAuth integration with Devise

3. **Multi-Tenancy Foundation**
   - `Venue` model for location-based queues
   - Songs and users scoped to venues
   - `Current` context for venue/user tracking
   - Ready for subdomain or path-based routing

4. **User Ownership**
   - Songs belong to users
   - Authorization checks prevent editing others' songs
   - Automatic user assignment on song creation

5. **Modern JavaScript (Stimulus)**
   - Migrated inline JS to Stimulus controllers
   - `instructions_controller.js` - toggle instructions
   - `song_action_controller.js` - finish/skip actions
   - `youtube_search_controller.js` - YouTube integration

6. **YouTube Integration**
   - In-app YouTube search with preview
   - Video validation for "karaoke" and "lyrics" keywords
   - Embedded video preview before queuing
   - `YoutubeService` for API interactions

## Next Steps to Run

### 1. Install Dependencies

```bash
bundle install
```

### 2. Setup Environment Variables

```bash
cp .env.example .env
```

Then follow [SETUP.md](SETUP.md) to get your:

- Google OAuth credentials
- YouTube API key

### 3. Run Migrations

```bash
rails db:migrate
```

### 4. Create Your First Venue

```bash
rails console
Venue.create!(name: "Your Venue Name", slug: "your-venue", location: "Your City")
exit
```

### 5. Start the Server

```bash
rails server
```

### 6. Access the App

Visit: `http://localhost:3000?venue_slug=your-venue`

Sign in with Google OAuth or create a password account.

## Key Files Changed

### Models

- [app/models/venue.rb](app/models/venue.rb) - NEW: Venue model
- [app/models/current.rb](app/models/current.rb) - NEW: Current context
- [app/models/song.rb](app/models/song.rb) - Added venue/user associations, validations, scoping
- [app/models/user.rb](app/models/user.rb) - Added OAuth, venue/songs associations

### Controllers

- [app/controllers/application_controller.rb](app/controllers/application_controller.rb) - Venue/user context setting
- [app/controllers/songs_controller.rb](app/controllers/songs_controller.rb) - Auth, ownership, YouTube endpoints
- [app/controllers/users/omniauth_callbacks_controller.rb](app/controllers/users/omniauth_callbacks_controller.rb) - NEW: OAuth handling

### Services

- [app/services/youtube_service.rb](app/services/youtube_service.rb) - NEW: YouTube API integration

### Views

- [app/views/songs/index.html.haml](app/views/songs/index.html.haml) - Removed credentials, added Stimulus
- [app/views/songs/_form.html.haml](app/views/songs/_form.html.haml) - YouTube search integration
- [app/views/devise/sessions/new.html.haml](app/views/devise/sessions/new.html.haml) - Google OAuth button

### JavaScript (Stimulus)

- [app/javascript/controllers/instructions_controller.js](app/javascript/controllers/instructions_controller.js) - NEW
- [app/javascript/controllers/song_action_controller.js](app/javascript/controllers/song_action_controller.js) - NEW
- [app/javascript/controllers/youtube_search_controller.js](app/javascript/controllers/youtube_search_controller.js) - NEW

### Styles

- [app/assets/stylesheets/partials/_youtube.scss](app/assets/stylesheets/partials/_youtube.scss) - NEW
- [app/assets/stylesheets/partials/_forms.scss](app/assets/stylesheets/partials/_forms.scss) - OAuth button styles

### Migrations

- `20260213210716_add_omniauth_to_users.rb` - OAuth fields
- `20260213210950_create_venues.rb` - Venues table
- `20260213211007_add_venue_to_songs.rb` - Venue association
- `20260213211008_add_venue_to_users.rb` - Venue association
- `20260213211017_add_user_to_songs.rb` - User ownership

## What You Need to Do

1. **Get API Credentials** (see [SETUP.md](SETUP.md))
   - Google OAuth Client ID & Secret
   - YouTube Data API Key

2. **Run Migrations**

   ```bash
   rails db:migrate
   ```

3. **Create Venues** for each location you want to track

4. **Test the Features**
   - Sign in with Google
   - Search for karaoke videos
   - Queue songs
   - Test finish/skip functionality

## Future Enhancements (Not Yet Built)

Only implement these when you're ready:

1. **Turbo Streams** - Real-time updates without page refresh
2. **Video Embedding** - Play videos in-app instead of new tab
3. **Song Reordering** - Drag-and-drop queue management
4. **Subdomain Routing** - `venue1.karaoke.app` per venue
5. **Admin Roles** - Host vs performer permissions
6. **Song History** - Track past performances
7. **Popular Songs** - Analytics and recommendations

## Notes

- **Postponed field**: Currently in schema but not actively used. You mentioned it's different from "skipped" - we can implement the logic when you're ready.

- **Default Scope**: Songs are automatically scoped to the current venue. If no venue is set, all songs appear (for backward compatibility).

- **Authorization**: The `authorize_song_owner` method only prevents editing/deleting. Anyone can still skip or finish songs. Let me know if you want stricter controls.

- **Ruby Version**: Your Gemfile specifies Ruby 3.2.2, but your system has 3.3.0. You might want to use a version manager like `rbenv` or `rvm` to switch to 3.2.2, or update the Gemfile to 3.3.0.

## Questions?

Refer to [SETUP.md](SETUP.md) for detailed setup instructions, or let me know what you'd like to tackle next!
