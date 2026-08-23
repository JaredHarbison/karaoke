# Human QA journeys

This is the browser-level MVP verification path. Start at the public root,
follow the shared discovery path, then complete the owner, host, and performer
journeys using separate browser sessions. Record findings before moving to the
next role.

## Guided QA mode

For interactive passes, use one action at a time. Before each action, provide
the role, account state, page, setup, expected result, and what to report. After
the action, ask what appeared, whether the result was understandable, and how
the interaction felt. Carry successful setup forward—for example, the owner
adds the host before the host journey begins. Fix confirmed defects during the
slice, then update the relevant journey and findings together before committing.

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
