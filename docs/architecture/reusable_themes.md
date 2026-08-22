# Reusable themes and event application

## Context / problem

Themes should be reusable, while a particular event needs a record of which
theme and rules applied at a given time. A song check can also be uncertain.

## Decision

The first implementation defines reusable venue-scoped `Theme` records and
`EventThemeApplication` records that attach them to one event. An application
may carry an optional event-time window bounded by the event. Store the applicable theme context with
the performance/queue admission. Deterministic checks should reject or admit
when reliable; uncertain cases go to host review. Theme-ineligible or pending
songs may return to normal/Fair Queue eligibility when the theme ends unless
explicitly rejected or removed for another reason.

The initial live evaluator supports simple required and blocked keyword rules as
a provider-independent foundation. Eligible songs enter the event queue;
uncertain or theme-ineligible songs enter host review. A host may approve or
explicitly reject a review entry, and unresolved review entries are released to
normal queue eligibility after the active theme window ends.

Theme review is separate from hard content-policy admission: a video rejected
because the venue disallows explicit lyrics may be held in a reject-only theme
review panel for the authorized host, but it is never released by theme expiry.

## Consequences / implications

Theme behavior is auditable and reusable rather than copied into each song.
Computed eligibility belongs to the event Performance/theme-application
context, not a global Song/Theme join. The transitional queue record stores the
application, outcome, explanation, and review decision until the planned
Song/Performance boundary is completed. A future `ThemeSong` join may represent
curated reusable playlists, but it should not replace event-time evaluation.
Host review is a deliberate fallback, not a false certainty.

## Deferred details

Metadata providers, richer rule authoring UI, provider-to-metadata
normalization, Performance-owned status transitions, and time-window precedence
for multiple overlapping applications remain deferred.
