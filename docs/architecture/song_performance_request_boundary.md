# Song, performance, and future request boundary

## Context / problem

The current queue object represents a song submission and must remain stable
while the product grows. A canonical song, an event performance, and a future
request between performers have different lifecycles.

## Decision

The initial slice preserves the current queue object while adding a transitional
provider metadata and duration boundary. Planned: introduce a canonical `Song`
separate from an event `Performance`/queue entry. Reuse the canonical Song when
the same provider video is selected again, but create a new Performance for every
performer/event queue entry. A future user-to-user
`Request` means one performer asking another to sing a song from that person's
history. Do not rename the current queue object to `SongRequest`.

## Consequences / implications

History, queue state, performer identity, and requests can evolve independently
without duplicate representations or a misleading rename. Admission validation
belongs at the provider/performance boundary: karaoke status, venue content
policy, and duration should be established before a Performance is admitted.
Duration is snapshotted on the Performance with its source (`provider` or
`average`) for runtime cutoff decisions.

## Deferred details

The migration shape, canonical metadata ownership, curated theme membership,
duets, request permissions, provider metadata verification beyond the current
adapter, and the final Performance migration remain deferred.
