# Song and performance models

`Song` is the canonical provider identity stored in `song_identities`. It
deduplicates provider/video IDs and holds title, karaoke eligibility,
explicit-lyrics status, duration, and metadata-check information.

`Performance` is an event-specific queue entry backed by the legacy `songs`
table. It belongs to a venue, user, optional event, and optional canonical
`Song`. It owns queue state, idempotency, effective duration, and
theme-admission/review state.

Use `Performance#song` for the canonical association. `song_identity` remains
a compatibility alias, as do the external `songs` routes and view directory.
