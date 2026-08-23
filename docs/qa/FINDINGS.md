# QA findings log

Add findings here during the manual pass. Keep one entry per issue or notable
result. Do not include real user passwords, private tokens, or personal data.

## Open findings

| ID | Role/account | Page | Action | Expected | Actual | Browser/device | Evidence | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-001 | Shared | `/` and `/discover` | Compare entry points | Discovery should have one clear purpose | The two entry points feel redundant for the current MVP |  |  | Product/UX question |
| QA-002 | Shared | Venue entry point | Open a venue, then navigate elsewhere | Venue context should remain explicit and stable | The QA wording was unclear about what “does not select another venue” means |  |  | Clarified in guide |
| QA-003 | Owner | Venue settings | Create an invitation | Invitation should remain findable until accepted or expired | The confirmation/link disappears quickly; an invitation index may be needed |  |  | Open |
| QA-004 | Owner | Host invitation | Follow the link while signed out/in with the wrong email | The intended account can accept; another account is rejected | Acceptance flow still needs complete manual verification |  |  | Open |
| QA-005 | Owner/Host | Event management | Create/edit an event as a host | Authorized hosts should have the intended event authority | Host creation/editing authority needs explicit QA confirmation |  |  | Open |
| QA-006 | Owner | Event edit | Save start/end values with queue settings | Event times and queue cutoff policy remain separate | Reported start/end behavior appeared to include queue-end buffering |  |  | Open |
| QA-007 | Owner | Recurring series and event edit | Save a series, then select it on an event | Saved active series should be selectable | Recurring series appeared not to save or appear in the selector |  |  | Open |
| QA-008 | Owner | Venue navigation | Move between settings, events, series, themes, and queue | Relevant management pages are reachable | Navigation completeness and consistency need review |  |  | Open |
| QA-009 | Owner/Host | Themes | Create/apply a theme | Theme controls are discoverable in event-management workflows | Theme setup/application is not surfaced where expected |  |  | Product/UX follow-up |
| QA-010 | Owner | Event theme application | Enter a theme window outside the event | Theme windows are constrained to the event window | Keep this validation in the focused theme QA pass |  |  | Open |
| QA-011 | Owner | Event queue | Find Fair Queue and queue cutoff controls | Event policies are visible at the event-management surface | Controls were not obvious during the pass |  |  | Open |
| QA-012 | Performer | Add Song | Select a YouTube result | Selected URL/title populate the queue form | Selection was silent because the form did not render the fields the controller targets |  |  | Fixed locally; manual recheck |
| QA-013 | Owner | Event delegation | Delegate a venue member | Owner can delegate another venue member; self-delegation is rejected | Only the invited host was available and a self-delegation/window validation error appeared |  |  | Open; verify setup/authority |
| QA-014 | Owner/Performer | Queue navigation | Use the queue route and controls | Route and terminology match the current event flow | `/songs`, alerts, top navigation, sidebar, and QR presentation feel inconsistent |  |  | UI overhaul follow-up |
| QA-015 | Owner/Performer | Queue submission | Select a video and submit | Request contains a `song` payload and returns a normal validation result | Browser reproduced `ActionController::ParameterMissing` for `song` |  |  | Fixed locally; manual recheck |
| QA-016 | All | Application-wide UI | Complete each journey | Layouts/components are concise, aligned, and consistent | Broad UI overhaul is needed beyond this focused bug pass |  |  | Deferred; requires product-owner direction |
| QA-017 | Performer | Event queue add-song flow | Select a YouTube result without an active presence session | Selection should prepare the form and make the access-code step visible before submission | Selection auto-submitted and exposed the admission error without showing the required code step |  |  | Fixed locally; manual recheck |
| QA-018 | Performer | Event queue admission error | Submit without event presence | The required recovery action should be visible and focused | The POST restored admission validation but not the selected event context, so the access-code prompt disappeared from the rendered response and focus remained on search |  |  | Fixed locally; manual recheck |

| QA-019 | Owner/Performer | Event access | Event times and access expiry should use the venue's local time zone | Rails was using UTC while the QA event was scheduled in Eastern time, making the event appear ended and all access sessions inactive |  |  | Fixed locally; manual recheck |
| QA-020 | Owner/Performer | Event access | The current short code should be easy to find; old codes should not compete with it | The page primarily listed raw token URLs and several historical sessions, with no visible code when the event was not recognized as live |  |  | Fixed locally; manual recheck |
| QA-021 | Shared | Sign-out/sign-in transition | Alerts should use one consistent semantic treatment without destabilizing layout | A reddish sign-in alert appeared after signing out; alert, warning, and success treatments need a shared strategy, with magenta likely representing alerts/errors |  |  | UI overhaul follow-up |
| QA-022 | Owner/Performer | Event index/event page | Selecting an event should stay within the event lobby/workspace | The current event page still links to `/songs`, so the journey lands on the legacy venue queue instead of the selected event context |  |  | Route migration follow-up |
| QA-023 | Shared | Application shell | The responsive role menu drawer must render through the repository's Sass pipeline | The first right-drawer implementation used CSS `min()` with a `calc()` value, which SassC rejected during the full CI RSpec render pass | Replaced it with equivalent `width` and `max-width` declarations | 2026-08-23 | Fixed; covered by shell request specs and full CI |
| QA-024 | Shared | Application shell | The navbar and menu should use the full viewport width while page content remains readable | The divider stopped short at the browser body padding, the navbar inherited content-width constraints, and the role drawer floated beneath the menu opener instead of occupying the right edge below the navbar | Removed the shell's inherited body inset, made the header full-width, and anchored the drawer from the navbar to the viewport bottom | 2026-08-23 | Implemented; visual recheck pending |
| QA-025 | Shared | Application shell | The role drawer must begin below the navbar at every browser scale | A fixed viewport offset allowed the drawer to overlap the navbar at the observed browser zoom; its cyan outline also competed with the yellow navbar divider | Anchored the drawer to the header's actual bottom edge and reused the yellow shell token for its outline and divider | 2026-08-23 | Implemented; visual recheck pending |
| QA-026 | Shared/Auth/Discovery | Shell consistency and discovery cards | Every surface should share the shell boundaries, alert treatment, menu behavior, identity presentation, divider weight, and non-jumping card interaction | Auth still used the legacy header and alert treatment; the drawer repeated its role label and used a text close control; discovery cards moved upward on interaction and displayed email-derived text directly | Routed auth through the shared shell, tightened auth rhythm, standardized menu/divider/card behavior, and used `User#display_name` for host identity | 2026-08-23 | Implemented; visual recheck pending |
| QA-027 | Shared/Auth | Flash messages and drawer controls should not move page content or disappear abruptly | The alert changed document flow; the drawer close control was not positioned independently; flash removal had no exit transition | Moved flash messages into a below-navbar overlay slot, added slide-in/slide-out behavior, and positioned the accessible `×` control in the drawer corner | 2026-08-23 | Implemented; visual recheck pending |
| QA-028 | Shared/Auth | Flash message layering | Translucent flash backgrounds allowed underlying page content to show through the message surface | Set alert and notice surfaces to a near-opaque midnight background while retaining their magenta/green semantic borders | 2026-08-23 | Implemented; visual recheck pending |
| QA-029 | Shared | Shell border hierarchy | The drawer contained a redundant internal line, its first action sat below the close control, and shell/component border weights were not clearly separated | Removed the drawer's internal rule, aligned its first action with `×`, and standardized `2px` for page-level shell boundaries versus `1px` for inner cards | 2026-08-23 | Implemented; visual recheck pending |
| QA-030 | Shared | Shell navigation labels | The role menu mixed title case and sentence case (`Sign Out` / `Sign in`) | Standardized navigation labels to title case | 2026-08-23 | Implemented; visual recheck pending |
| QA-031 | Discovery | Resume card and host identity | The resume card did not fill the discovery header row, and plus-addressing tags leaked into host-facing names | Stretched the resume card with space-between layout and stripped plus-addressing tags from the email-derived display-name fallback | 2026-08-23 | Implemented; visual recheck pending |

## Resolved findings

Move an entry here after the fix is deployed and manually rechecked.

| ID | Fix commit | Verification result |
| --- | --- | --- |

## Entry template

```text
ID:
Role/account:
Page:
Action:
Expected:
Actual:
Browser/device:
Screenshot or console error:
Status:
```
