# Host journey

Account: `jared.harbison+host@gmail.com`  
Start: `/523-franklin-ave/events`

Prerequisite: complete the owner journey’s “Add an existing user as a host”
step. Before that action, this account is authenticated but has no authority
over `523 Franklin Ave`.

## Event access and queue management

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
   - The canonical event presentation URL is used and its Now, Up Next, and
     Up Second performers match the queue page.
   - Start a queued song from either surface and confirm it becomes Now on all
     open queue/presentation screens without a manual reload.
   - Let an embeddable YouTube video finish: the performance finishes once and
     presentation remains open on the newly selected next performer.
   - Use End & Advance and End Without Progressing. The former finishes the
     performance; the latter restores the waiting state without a delayed
     automatic advance.
   - Owner settings are not exposed.

## Queue management

1. Open the event queue with several pending entries.
   - On desktop and mobile, Queue and Add Song use the same tab structure;
     only the selected panel is visible.
   - Fair Queue favors fewer completed turns and keeps stable tie-breaking.
2. Finish, skip, pause, unpause, and requeue entries.
   - Each action succeeds and the queue reflects it.
   - Skipped songs do not count as completed turns.
   - Queue cards show the performer’s first name and last-name initial only,
     with the performer and song title using the ivory text treatment.
   - Queues larger than ten entries show a pink outlined `+ More` control and
     reveal the next page without changing queue order.
   - On mobile, every activity button has the same height; hover, keyboard focus,
     and the open More menu use the cyan secondary-action state.
   - The Next card uses one row of four equal icon-over-label actions; other
     cards fit Open, Pause, and More on one row without reducing touch-target height.
   - The Next card uses the same cyan border and surface treatment on desktop,
     tablet, and mobile.
   - The Queue/Add Song toggle is centered and bounded at every viewport size;
     its inactive labels and outline are cyan, and its selected tab is cyan-filled.
   - Action labels are ivory while their icons retain the semantic action colors;
     mobile action controls are square and do not overflow the card.
   - The pause dialog keeps compact Cancel/Pause buttons, and its close icon
     shows a square magenta hover/focus target.
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
   - The Themes toggle shows the number of performances awaiting reconciliation.
   - Approval makes it queue-eligible.
   - A non-matching song may instead be held until the theme window ends.
   - Rejection records the reason and keeps it out.
3. Leave a non-policy review unresolved until the theme window ends.
   - It releases to normal/Fair Queue eligibility.
4. Use a temporary host delegation if the owner created one.
   - Authority works only during the event-specific delegation window.
   - The Event tab shows that scope and its end time, without venue setup or
     performer-access controls.

Finish with the [shared checks](shared.md), then verify the same event as the
performer.
