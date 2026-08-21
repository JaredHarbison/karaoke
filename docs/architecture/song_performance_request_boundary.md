# Song, performance, and future request boundary

## Context / problem

The current queue object represents a song submission and must remain stable
while the product grows. A canonical song, an event performance, and a future
request between performers have different lifecycles.

## Decision

Planned: preserve the current queue object while leaving room to separate a
canonical `Song` from an event `Performance`/queue entry. A future user-to-user
`Request` means one performer asking another to sing a song from that person's
history. Do not rename the current queue object to `SongRequest`.

## Consequences / implications

History, queue state, performer identity, and requests can evolve independently
without duplicate representations or a misleading rename.

## Deferred details

The migration shape, canonical metadata ownership, snapshots, duets, and
request permissions are deferred until event requirements are understood.
