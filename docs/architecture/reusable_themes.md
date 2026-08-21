# Reusable themes and event application

## Context / problem

Themes should be reusable, while a particular event needs a record of which
theme and rules applied at a given time. A song check can also be uncertain.

## Decision

The first implementation defines reusable venue-scoped `Theme` records and
`EventThemeApplication` records that attach them to one event. An application
may carry an optional event-time window. Store the applicable theme context with
the performance/queue admission. Deterministic checks should reject or admit
when reliable; uncertain cases go to host review. Theme-ineligible or pending
songs may return to normal/Fair Queue eligibility when the theme ends unless
explicitly rejected or removed for another reason.

## Consequences / implications

Theme behavior is auditable and reusable rather than copied into each song.
Host review is a deliberate fallback, not a false certainty. The current UI
labels deterministic rule enforcement as forthcoming.

## Deferred details

Metadata providers, rule authoring, review UI, time-window precedence, and
exact status transitions are deferred.
