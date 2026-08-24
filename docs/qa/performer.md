# Performer journey

Account: `jared.harbison+performer@gmail.com`  
Start: `/523-franklin-ave/songs`

## Discovery and event access

1. Complete the [shared discovery journey](README.md#shared-discovery-journey).
2. Open `/523-franklin-ave/events`.
   - Upcoming events are visible without host-management controls.
3. Open the scheduled event queue.
   - Confirm the Queue and Add Song tabs behave the same on desktop and mobile,
     without a permanent sidebar panel.
   - The page explains that submissions open when the host starts the event.
   - If the event is live but you lack presence, the access-code step is visible
     and focused before queue submission.
4. After the host starts the event, enter the active six-character code shown
   by the host/display.
   - Presence is granted for that event.
   - The event context remains visible after admission.
   - Invalid, expired, or revoked codes are rejected.

## Queueing

1. Add a valid karaoke YouTube selection.
   - The song appears once with your performer identity.
2. Retry or double-submit the same request.
   - Only one queue entry exists and the retry is explained.
3. Select the same eligible video again.
   - Each event Performance remains separate while canonical song identity is
     reused.
4. Try unknown/unverified metadata.
   - It enters review rather than silently queueing.
5. Try explicit content while the venue disallows it.
   - It is rejected with a content-policy message.
6. Try to queue after event completion, without presence, or after cutoff.
   - The action is rejected with a useful recovery message.

## Authorization boundaries

1. Open `/523-franklin-ave/settings`, event-management, theme-management, and
   host-only queue actions.
   - Access is rejected or redirected.
2. Inspect the queue.
   - You can manage your own song where supported.
   - Host-only controls and Fair Queue audit information are hidden.
3. Re-enter the event while your presence session remains active.
   - Re-entry works until expiry, revocation, or code rotation.

Finish with the [shared checks](shared.md).
