# Shared QA checks

Apply these checks while completing each role journey.

## Responsive and accessibility

- Test narrow mobile and desktop widths for discovery, queue, event, theme,
  presence-code, and host screens.
- Navigate primary actions with the keyboard only.
- Confirm visible focus, useful labels, associated validation errors, semantic
  headings, status announcements, and readable contrast.
- Confirm dialogs, alerts, and redirects explain what happened and how to
  recover.

## Reliability and concurrency

- Reload after adding, changing, or reviewing a queue entry; state persists.
- Retry stale or double-submitted actions; no duplicate queue entries appear.
- Confirm visible action labels use Title Case consistently, including Sign In
  on the authentication surfaces.
- Perform two host reorder actions close together; one consistent queue order
  remains and both authorized actions are audited.
- Try expired presence, unavailable metadata, event cutoff, and completed-event
  actions; each produces a clear recovery path.

## Security and scope

- Venue settings, themes, delegations, event access generation, and queue
  overrides remain scoped to the current venue/event.
- A performer cannot use owner/host controls by directly opening their URLs.
- The permanent venue entry point remains stable when an event code rotates.
- Do not treat future geolocation, rotating QR profiles, RSVP, event sharing,
  or duet behavior as implemented; those remain roadmap items.

## QA handoff

For each finding, record:

```text
Role/account:
Page:
Action:
Expected:
Actual:
Browser/device:
Screenshot or console error:
```
