# Manual QA Guide

Use this guide for a short browser pass after changes. It covers the current
implemented product surface; planned event UI, membership management, themes,
Fair Queue, presence, and QR session security are not testable yet.

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
It does not yet generate future occurrences, move queue songs into event scope,
or expose themes, Fair Queue, delegation, presence, or QR security.

## Record findings

For each issue, record the account, page, action, expected result, actual
result, browser/device, and a screenshot or console error when relevant.

Review this guide on every commit. Update it whenever the change affects a
testable page, action, authorization boundary, or operational workflow.
