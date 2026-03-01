# API Endpoints

## Songs Controller

### Search YouTube

```http
GET /songs/youtube_search
```

Query Parameters:

- `query` (required) - Search term for karaoke videos

Response:

```json
{
  "items": [
    {
      "video_id": "dGw8w3tiWow",
      "title": "Song Name - Artist Karaoke",
      "description": "...",
      "thumbnail": "https://i.ytimg.com/vi/...",
      "channel": "Channel Name",
      "url": "https://www.youtube.com/watch?v=dGw8w3tiWow"
    }
  ]
}
```

Errors:

- `{ "error": "YouTube API key not configured" }`
- `{ "error": "Failed to fetch YouTube results" }`

---

### Validate Video

```http
GET /songs/validate_video
```

Query Parameters:

- `url` (required) - YouTube URL or video ID

Response (Valid):

```json
{
  "valid": true,
  "video_id": "dGw8w3tiWow",
  "title": "Song Name - Karaoke (Lyrics)",
  "has_karaoke": true,
  "has_lyrics": true,
  "thumbnail": "https://i.ytimg.com/vi/..."
}
```

Response (Invalid):

```json
{
  "valid": false,
  "video_id": "dGw8w3tiWow",
  "title": "Something...",
  "has_karaoke": false,
  "has_lyrics": false,
  "thumbnail": "..."
}
```

---

### Index Songs

```http
GET /songs
```

Renders: `songs/index.html.haml`

Queries songs scoped to current venue and organizes by status.

---

### Create Song

```http
POST /songs
```

Parameters:

```ruby
{
  song: {
    performer: "String",
    category: "String",
    url: "String",
    finished: "Boolean (optional)",
    skipped: "Boolean (optional)",
    postponed: "Boolean (optional)"
  }
}
```

Auto-set:

- `user_id` - Current user
- `venue_id` - Current venue

---

### Finish Song

```http
GET /finish_song
```

Query Parameters:

- `id` - Song ID

Sets `finished: true` on song and redirects to songs index.

---

### Skip Song

```http
GET /skip_song
```

Query Parameters:

- `id` - Song ID

Toggles `skipped` boolean and redirects to songs index.

---

### Update Song

```http
PATCH/PUT /songs/:id
```

Authorization: User must own the song

---

### Delete Song

```http
DELETE /songs/:id
```

Authorization: User must own the song
