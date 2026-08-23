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
