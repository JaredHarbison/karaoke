# Owner journey

Account: `jared.harbison@gmail.com`  
Start: `/523-franklin-ave/events`

The public discovery and venue pages are intentionally role-neutral. Owner
controls begin after sign-in and venue authorization; verify that boundary
during the shared journey before continuing here.

## Venue and membership

1. Open `/523-franklin-ave/settings`.
   - Venue details can be edited and saved.
   - “Allow explicit lyrics” persists and affects future selections.
2. Add an existing user as a host.
   - `jared.harbison+host@gmail.com` is already registered but is not yet a
     member of this venue.
   - The host appears and receives host authority after the owner adds them.
3. Remove the host.
   - The host disappears and loses host authority.
4. Create an invitation for an unregistered email.
   - A pending invitation and visible confirmation appear.
   - Accepting with the wrong email is rejected.

## Events and recurring series

1. Open `/523-franklin-ave/events` and create or edit an event.
   - Event links use a readable event slug under `/523-franklin-ave/events/`.
   - The event remains scoped to 523 Franklin Ave when opened.
   - Following the event's primary action should remain in the selected event
     workspace; landing on `/songs` is a route-migration finding.
   - Verify the event start/end values remain the values entered; queue cutoff is a separate policy and must not rewrite event times.
   - The event belongs to this venue.
   - Performers cannot access owner event-management actions.
   - Event, recurring-series, and theme forms use the same labeled-control,
     validation, checkbox, and action treatment as the event queue’s host
     controls.
   - Events has one Create Event action. Verify its form creates either a
     one-off event or the first occurrence of a recurring series without
     leaving the event-management flow.
2. Open the recurring-series page.
   - Create/edit recurrence intent, schedule, time zone, and active state.
   - Generate the next eight weeks twice; occurrences are not duplicated.
   - Confirm a saved series appears in the event form’s recurring-series selector.
   - Events, recurring series, and themes use the shared management header,
     card/list, form, and action treatments at desktop and narrow widths.
3. Edit one generated occurrence.
   - The occurrence changes without changing its series or sibling occurrences.
4. Confirm the venue, event, recurring-series, theme, and queue-management pages have reachable navigation links.

## Theme and queue setup

1. From the event queue, open the **Themes** toggle.
   - Create a reusable theme with familiar song or artist examples and optional
     avoid terms, apply it to the event, and edit it from the managed-theme list.
   - Confirm the values persist normalized and the theme controls stay within
     the event workflow.
   - Bounded theme windows must stay inside the event start/end window.
2. Apply the theme to an event.
   - Bounded windows must stay inside the event.
   - Overlapping windows on one event are rejected; touching windows work.
3. Open the event queue.
   - Fair Queue can be enabled/disabled.
   - Queue cutoff and overrun settings are visible and audited.
   - Verify both settings on the event detail/edit pages, not only on the queue page.
   - Select a YouTube result and confirm the queue form receives its URL/title before submitting.

## Presence and delegation

1. Confirm the venue time zone in venue settings, start the scheduled event,
   and generate an event access code.
   - The current short code is prominent and its expiry uses the venue's local time.
2. Open the access link and confirm it reaches the event's queue context.
3. Rotate the code.
   - The prior code/session is revoked; the permanent venue entry point remains.
4. Open the **Temporary Hosts** toggle and delegate a
   venue member for a time inside the event.
   - The owner may delegate to another venue member; a delegator cannot delegate to themself.
   - The event lists the delegation and its expiry.
   - Revoke it and confirm authority is removed.

Finish with the [shared checks](shared.md), then repeat relevant queue actions
as the host and performer. Log navigation, alert, sidebar, QR, and styling
concerns in `FINDINGS.md`; the broader UI overhaul is intentionally outside
this QA pass.
