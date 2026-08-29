# HTTP surface

Karaoke Queue is primarily an HTML and Turbo application. The queue resource
is still exposed through legacy `songs` routes while its records are
`Performance` instances; the roadmap tracks that naming migration.

## Venue and event entry points

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/` | Public venue discovery |
| `GET` | `/:venue_slug/events` | Venue event index |
| `GET` | `/:venue_slug/events/:event_slug/queue` | Event queue workspace |
| `GET` | `/:venue_slug/events/:event_slug/presentation` | Host presentation surface |
| `GET` | `/venues/presence/:token` | Permanent venue QR entry |
| `GET` | `/event-presence/:token` | Event-presence URL exchange |
| `GET` | `/event-presence/code` | Event-code entry |

## Queue routes

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/:venue_slug/songs` | Legacy venue queue surface |
| `POST` | `/:venue_slug/songs` | Submit a queue performance |
| `POST` | `/:venue_slug/events/:event_slug/queue` | Submit in an event context |
| `GET` | `/:venue_slug/songs/youtube_search?query=` | Search YouTube metadata |
| `GET` | `/:venue_slug/songs/validate_video?url=` | Validate a selected video |
| `PATCH` | `/:venue_slug/songs/:id` | Update the submitter's performance |
| `DELETE` | `/:venue_slug/songs/:id` | Remove the submitter's performance |
| `PATCH` | `/:venue_slug/songs/:id/{start,stop,finish,pause,unpause,requeue,skip}_song` | Authorized queue action |
| `PATCH` | `/:venue_slug/songs/:id/review_theme` | Authorized theme decision |

Queue routes require authentication. Submission additionally requires a live
event and active event presence for performers; venue owners and authorized
hosts bypass the performer presence gate. Queue-action routes require the
appropriate venue or temporary event-host authority.
