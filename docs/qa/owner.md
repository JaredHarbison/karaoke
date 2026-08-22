# Owner journey

Account: `jared.harbison@gmail.com`  
Start: `/523-franklin-ave/events`

## Venue and membership

1. Open `/523-franklin-ave/settings`.
   - Venue details can be edited and saved.
   - “Allow explicit lyrics” persists and affects future selections.
2. Add an existing user as a host.
   - The host appears and receives host authority.
3. Remove the host.
   - The host disappears and loses host authority.
4. Create an invitation for an unregistered email.
   - A pending invitation and visible confirmation appear.
   - Accepting with the wrong email is rejected.

## Events and recurring series

1. Open `/523-franklin-ave/events` and create or edit an event.
   - The event belongs to this venue.
   - Performers cannot access owner event-management actions.
2. Open the recurring-series page.
   - Create/edit recurrence intent, schedule, time zone, and active state.
   - Generate the next eight weeks twice; occurrences are not duplicated.
3. Edit one generated occurrence.
   - The occurrence changes without changing its series or sibling occurrences.

## Theme and queue setup

1. Open `/523-franklin-ave/themes`.
   - Create a reusable theme with required and blocked comma-separated words.
   - Edit it and confirm the values persist normalized.
2. Apply the theme to an event.
   - Bounded windows must stay inside the event.
   - Overlapping windows on one event are rejected; touching windows work.
3. Open the event queue.
   - Fair Queue can be enabled/disabled.
   - Queue cutoff and overrun settings are visible and audited.

## Presence and delegation

1. Start the scheduled event, generate an event access code, and open its URL.
   - The code is shown only in live host/presentation contexts.
2. Rotate the code.
   - The prior code/session is revoked; the permanent venue entry point remains.
3. Delegate a venue member for a time inside the event.
   - The event lists the delegation and its expiry.
   - Revoke it and confirm authority is removed.

Finish with the [shared checks](shared.md), then repeat relevant queue actions
as the host and performer.
