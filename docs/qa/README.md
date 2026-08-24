# Human QA journeys

This is the browser-level MVP verification path. Start at the public root,
follow the shared discovery path, then complete the owner, host, performer, and
display journeys using separate browser sessions. The target route model uses
the event workspace as the canonical queue surface; current `/songs` links are
temporary implementation state and should not be treated as the target UX.
Record findings before moving to the next role.

## Guided QA mode

For interactive passes, use one action at a time. Before each action, provide
the role, account state, page, setup, expected result, and what to report. After
the action, ask what appeared, whether the result was understandable, and how
the interaction felt. Carry successful setup forward—for example, the owner
adds the host before the host journey begins. Fix confirmed defects during the
slice, then update the relevant journey and findings together before committing.

For the presentation reset, verify one page at a time. Finish the page's
primary path and record what was visible, what action was taken, what happened,
and how clear the interaction felt before moving to another page. The first
route-foundation check is the venue event index followed by one event page;
confirm that the event URL is readable and venue-scoped.

## Before starting

Run the development fixture:

```sh
KARAOKE_QA_FIXTURE=franklin KARAOKE_QA_PASSWORD='local-only-password' bin/rails db:seed
```

Use the same password for:

| Role | Email | Start page |
| --- | --- | --- |
| Owner | `jared.harbison@gmail.com` | `/523-franklin-ave/events` |
| Host | `jared.harbison+host@gmail.com` | `/523-franklin-ave/events` |
| Performer | `jared.harbison+performer@gmail.com` | `/523-franklin-ave/songs` |

The fixture is development-only and safe to rerun. Do not use these accounts
or the local password in production.

The fixture includes one scheduled event and two pending queue entries. The
host email is intentionally only a registered user at first; the owner journey
adds that user to the venue before the host journey begins.

Discovery cards now open the venue's current event workspace when one exists;
they no longer send a performer to the legacy `/songs` surface.

Optional read-only fixture check, only if the UI does not show the expected
records:

```sh
bin/rails runner 'venue = Venue.find_by!(slug: "523-franklin-ave"); puts({ venue: venue.name, owner: venue.owner.email, hosts: venue.hosts.pluck(:email), events: venue.events.pluck(:name), queue: venue.performances.where.not(event_id: nil).pluck(:performer) }.inspect)'
```

## Shared discovery journey

1. Open `/`.
   - The welcome page loads.
   - Discovery and sign-in actions are reachable.
2. Open `/discover` and search for `523 Franklin Ave`.
   - The venue appears.
   - Empty and unsuccessful searches remain usable.
   - Record any discovery/navigation concerns in `FINDINGS.md`.
3. Open the venue from discovery.
   - The venue queue or event entry point loads.
   - The permanent venue entry point does not select another venue.
     - This means the venue URL remains scoped to the venue you opened; it must not silently switch `Current.venue` to another venue.
   - The public discovery/venue surface shows no owner- or host-only controls.
4. Open `/sign_in` and sign in with the role under test.
   - Authentication succeeds without an authorization error.
5. Continue with the matching role journey:
   - [Owner journey](owner.md)
   - [Host journey](host.md)
   - [Performer journey](performer.md)
6. Apply the checks in [shared checks](shared.md) to every role.
7. Type findings directly into the [findings log](FINDINGS.md).

## Recording a finding

Use the findings log during the pass. Keep credentials, private tokens, and
unnecessary personal data out of it.

Review this directory on every commit. Update the relevant journey whenever a
change affects a testable page, action, authorization boundary, or operational
workflow.

## Identity and shared motion check

On sign-up, verify first name and last name are required. After creating a
named account, verify compact venue and host surfaces display `First L.` and
never expose plus-addressing tags. Existing accounts should remain usable with
their sanitized fallback name. When a flash message, drawer, or interactive
card appears, confirm its motion is brief and consistent with the shared shell
motion; page content should not jump as a result.

On the root page, verify the heading says “Today” before 6:00 PM in the
browser's local time and “Tonight” from 6:00 PM onward. Verify the resume card
uses the same hover/focus expansion treatment as discovery cards; when its
height exceeds the copy beside it, the heading/copy column should distribute
its content without collapsing or jumping.

Verify each venue card's status sits above its centered CTA, with both aligned
to the same content edge. The resume card should match the venue-card content
and spacing exactly, with only its “Continue where you left off” eyebrow added
above the venue name. Its CTA should read “Go to event,” matching the shared
event-entry action.

The resume CTA and discovery CTA share the same event-entry wording; keep this
assertion aligned if the label changes.

The card footer should shrink to the CTA width and center as one unit; its
status should align to the CTA's left edge above the button.

Expired or not-yet-started events must not display “open for signups”; only a
live event inside its configured start/end window may do so.

An active event's discovery card and venue join action should open its
slug-based queue at `/:venue_slug/events/:event_slug/queue` for every role.
Scheduled events may open the event lobby instead; management controls belong
behind explicit owner/host actions. Expired events should not appear in
discovery until the event lobby/recap surface is ready.

Activated primary CTAs should remain readable briefly: magenta text uses an
ivory background and thin magenta border rather than magenta-on-magenta, then
the CTA returns to its normal state. Repeat after revisiting the page and after
keyboard focus; browser link-state styling must not turn the CTA text magenta
while its background remains magenta.

The resume card follows the venue saved in the current session. If two venues
share a display name, verify the address and event name before treating their
cards as duplicates.

The root discovery page shows only public venues with a current or upcoming
event. Venues with no event, expired events, or completed events must not appear
as discovery cards.

Verify the role menu slides in from the right below the navbar, while flash
messages slide down from the navbar using the same brief timing and easing.

## Queue surface checks

On the queue page, verify the shared navbar and role menu are present for the
current user. Confirm the queue, Queue a Song, scan-to-join, and Finished
Performers sections use the shared card border, background, padding, and yellow
section-heading treatment. The song selector should show results as horizontal
cards that can be keyboard-focused and scrolled on narrow screens.

Confirm the order is Queue a Song, scan to join, then Finished Performers in the
secondary column. The QR card should have one outer card padding treatment, not
an extra nested panel inset. The redundant Fair Queue explanatory sentence
should not appear on the queue surface.

Queue cards should present the performer name once in yellow and the song title
once in ivory, without a redundant category pill. Play may remain magenta;
Pause, Skip, and More use cyan; Remove uses yellow. Confirm opening the role
drawer does not animate or shift the queue content itself.

When a selected video has a provider-style title, verify the queue displays the
recognizable song name without a YouTube URL or obvious karaoke/instrumental/key
descriptors. A missing title should display “Untitled song,” never the raw URL.

## Accessibility smoke checks

On sign-in, sign-up, and discovery, verify there is one labeled main landmark
and that the page heading identifies the current surface. On an invalid sign-up,
verify the error summary is announced to assistive technology and remains
visible without requiring a visual-only cue.

Open the role menu with the keyboard. Focus should move into the drawer; close
it with the close control or Escape and verify focus returns to the menu opener.
Repeat this check at mobile/tablet and desktop widths. A live axe scan and full
screen-reader pass remain pending until browser tooling is available.
