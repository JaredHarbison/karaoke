# Host journey

Account: `jared.harbison+host@gmail.com`  
Start: `/523-franklin-ave/events`

Prerequisite: complete the owner journey’s “Add an existing user as a host”
step. Before that action, this account is authenticated but has no authority
over `523 Franklin Ave`.

## Event operations

1. Open the event list and event detail page.
   - Upcoming events are visible.
   - Host event controls are available; owner-only venue settings are not.
2. Start the scheduled event.
   - The event becomes live.
   - Performers can now proceed to event access.
3. Generate or rotate the event access code.
   - The active six-character code is readable.
   - The previous code no longer grants presence after rotation.
4. Open presentation mode.
   - Now-playing/upcoming queue content and event access context are visible.
   - Owner settings are not exposed.

## Queue management

1. Open the event queue with several pending entries.
   - Fair Queue favors fewer completed turns and keeps stable tie-breaking.
2. Finish, skip, pause, unpause, and requeue entries.
   - Each action succeeds and the queue reflects it.
   - Skipped songs do not count as completed turns.
   - Queue cards show the performer’s first name and last-name initial only.
   - On mobile, every activity button has the same height; hover, keyboard focus,
     and the open More menu use the cyan secondary-action state.
3. Toggle Fair Queue off and on.
   - FIFO behavior and the explanation are shown when disabled.
4. Inspect the Fair Queue override audit.
   - Action, performer, host, and timestamp are visible to hosts.
   - Performers cannot see the audit.

## Theme review and temporary authority

1. During a live theme, submit matching, non-matching, uncertain, and explicit
   content as a performer.
   - Matching metadata queues.
   - Theme-ineligible/uncertain entries enter Theme review.
   - Disallowed explicit content is reject-only and never releases on expiry.
2. Approve or reject a theme review entry.
   - Approval makes it queue-eligible.
   - Rejection records the reason and keeps it out.
3. Leave a non-policy review unresolved until the theme window ends.
   - It releases to normal/Fair Queue eligibility.
4. Use a temporary host delegation if the owner created one.
   - Authority works only during the event-specific delegation window.

Finish with the [shared checks](shared.md), then verify the same event as the
performer.
