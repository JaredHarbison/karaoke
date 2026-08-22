# Manual QA Guide

Use this guide for a short browser pass after changes. It covers the current
implemented product surface, including contextual membership management,
events/recurring series, event-scoped queueing, and the reusable theme
foundation. Fair Queue’s initial ordering, event toggle, explanation, and host
override audit are testable; venue/event presence access is now testable, while
physical location enforcement remains forthcoming.

## Setup

Run the development seed data:

```sh
bin/rails db:seed
```

Use the local development accounts printed by the seed command. The seeded
venue is `/demo-karaoke/songs`.

## Current QA pass

| Page | Action | Expected result |
| --- | --- | --- |
| `/` | Open the welcome page | Page loads; discovery and sign-in actions are reachable. |
| `/discover` | Search for `Demo Karaoke` | The public venue appears; the page remains usable with no results. |
| `/sign_in` | Sign in as the performer | Redirects to the app without an authorization error. |
| `/demo-karaoke/songs` | Add a song with a title and URL | Song appears in the queue with the performer identity. |
| Queue | Reload after adding a song | The song remains present and the layout remains usable on a narrow viewport. |
| Queue as performer | Inspect queue controls | Performer can manage their own song where supported, but cannot use host-only queue controls. |
| Queue as host | Finish, skip, pause, requeue, or unpause a song | The action succeeds and the queue reflects the new state. |
| Queue as host | Open presentation mode | Presentation page loads in a separate tab and does not expose owner settings. |
| `/demo-karaoke/settings` as performer/host | Open the owner-only URL | Request is rejected or redirected with an authorization message. |
| `/demo-karaoke/settings` as owner | Edit venue details and save | Changes persist and visible feedback confirms the update. |
| Settings as owner | Add an existing user as host | The host appears in the list and can manage the queue. |
| Settings as owner | Remove a host | The host disappears from the list and loses host queue authority. |
| Settings as owner | Add an email that is not yet registered | A host invitation link is created and the owner receives visible confirmation. |
| Host invitation | Open the invitation while signed out, then sign in with the invited email | The invitation is accepted and the user can manage the venue queue. |
| Host invitation | Try to accept with a different account email | Acceptance is rejected and the invitation remains pending. |
| `/help` as performer | Open help | General queue guidance appears; venue-operator guides are hidden. |
| `/help` as owner/host | Open help | General and planned venue-operator guides appear; planned guides are labeled forthcoming. |
| Signed-out `/help` | Open help | User is sent to sign in. |
| `/:venue_slug/events` | Open as an authenticated performer | Upcoming venue events appear without host-management controls. |
| `/:venue_slug/events/new` | Open as a venue host and create an event | The event is saved for the current venue and appears in the event list. |
| `/:venue_slug/events/new` | Open as a performer | Access is rejected or redirected; no event is created. |
| Event edit | Change one occurrence associated with a series | The occurrence changes while the series name and recurrence rule remain unchanged. |
| `/:venue_slug/event-series` | Open as venue owner/host | Existing recurring series appear and can be edited. |
| Recurring series form | Create or edit a series | Recurrence intent, schedule, time zone, and active state persist. |
| Recurring series list | Select “Generate next 8 weeks” | Supported daily/weekly occurrences are created once; repeating the action does not duplicate them. |
| Generated occurrence | Edit one generated event | The occurrence changes without changing the series or other occurrences. |
| `/:venue_slug/themes` | Open as a venue host and create/edit a theme | The reusable theme persists for the current venue; host-only routes work and rule enforcement is labeled forthcoming. |
| Event themes | Open an event as a venue host and apply/remove a theme | The event shows its applied reusable theme; cross-venue themes are rejected. |
| Event theme window | Apply a theme with start/end values inside the event | The event displays the bounded window; partial or out-of-event windows are rejected. |
| Theme window validation | Submit a partial or out-of-event theme window | The application is rejected and the existing event theme state is unchanged. |
| Theme isolation | Try to apply a theme from another venue or duplicate a venue theme name | The action is rejected and no cross-venue or duplicate theme is created. |
| Event Fair Queue | Open an event queue with performers who have different completed-turn histories, including a new performer | Fewer completed turns are favored; performers with no history are handled as zero completed turns; equal scores use stable queue order. |
| Event Fair Queue override | As a host, pause or unpause an event queue song | The event-scoped host override changes that event’s queue order without affecting another venue or event. |
| Event Fair Queue setting | As a host, edit an event and turn Fair Queue off, then open its queue | The queue explains that it is FIFO and follows entry order; turning it back on restores Fair Queue behavior. |
| Fair Queue override audit | As a host, pause or unpause an event queue song, then view the event | Recent Fair Queue overrides show the action, performer, host, and timestamp. Performers do not see the host audit section. |
| Temporary host delegation | As a permanent venue host, open an event and delegate a venue member for a time inside the event window | The event page lists the delegation and its time window; the delegated user can manage that event’s queue only while the delegation is active. |
| Temporary host revocation | As a permanent venue host, revoke an active delegation | The event page marks the delegation revoked and the delegated user no longer has event queue authority. |
| Temporary host boundaries | Try to delegate outside the event window or as a performer | The delegation is rejected; performers cannot create or revoke delegations. Event and delegation times use the minute precision shown in the forms. |
| Permanent venue QR access | Open the permanent venue presence URL or scan its QR destination | The URL resolves to that venue’s existing queue flow without selecting another venue. |
| Event access code | As a permanent venue host, generate an event access code and open it before expiry | The code resolves to the selected event queue. |
| Event access expiry/revocation | Open an expired or revoked event access code | Access is rejected and the user is sent to venue discovery. |

The following admission checks are planned and are not yet live in the queue:
selected videos must be verified karaoke, and explicit lyrics must be rejected
when the venue policy disallows them. Unknown provider metadata should produce
a review state rather than an automatic admission.

Theme rule evaluation is also not yet exposed as a queue workflow; its current
evaluator is covered by automated tests until provider metadata and host review
are integrated.

## Phase 1 membership checkpoint

The completed Phase 1 slice does not introduce a new visible page. Verify that
the existing queue and settings behavior remains stable while authorization and
host management resolve through contextual membership data. The legacy
`VenueAdmin` table and global user role are no longer used. The `/admins` URLs
may remain in links for compatibility, but the visible workflow is presented as
host management. PlatformMembership workflows are not yet exposed and require
a separate future QA section when venue-joining moderation is implemented.

## Phase 2 event checkpoint

The initial event surface adds venue-scoped event and recurring-series pages.
It generates daily/weekly occurrences and lets a queue song be associated with
an event. Venue-level queueing remains available. The current theme foundation
also supports reusable definitions, event applications, bounded windows, and
automated deterministic evaluator outcomes; live admission/review integration
is not yet exposed. Advanced Fair Queue policy and physical location security
remain planned. Temporary host delegation and event access sessions are
testable from the event page for authority, expiry, and revocation.

| `/:venue_slug/events/:id` | Open an event and choose “View event queue” | The queue is filtered to that event; queueing a song from the Add Song panel preserves the event context. |
| `/:venue_slug/songs?event_id=:id` | Open a scheduled event queue | The queue explains that submissions open when the host starts the event. |
| Event lifecycle | As a venue host, start a scheduled event | The event becomes Live and performers can proceed to event access. |
| Event lifecycle | As a performer, try to start or complete an event | The action is rejected; only an authorized event host can change lifecycle state. |
| Event access code | Open the active event access code, then queue a song for the live event | The event presence is remembered for the session and the song appears in that event queue. |
| Live event queue | Try to queue without opening an active event access code | The submission is rejected with an access-code/presence message. |
| Event lifecycle | As a host, complete a live event, then try to queue | The event closes to new submissions, including during the short presence grace period. |

## Record findings

For each issue, record the account, page, action, expected result, actual
result, browser/device, and a screenshot or console error when relevant.

Review this guide on every commit. Update it whenever the change affects a
testable page, action, authorization boundary, or operational workflow.
