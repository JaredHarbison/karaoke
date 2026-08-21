# Contributing to Karaoke Queue

## Definition of Done

A change is complete only when it preserves working behavior (unless an
intentional change is documented), is small and reviewable, and has appropriate
coverage and checks for its risk. Before handoff, review:

- Accessibility: semantic structure, keyboard use, focus, labels, contrast, and
  screen-reader behavior where UI changes are involved.
- Database polish: constraints, indexes, safe/reversible migrations, and schema
  consistency where data changes are involved.
- Performance: query count, scoping, indexes, and avoidable work on hot paths.
- Security: authentication, venue/event-scoped authorization, input handling,
  secrets, CSRF, and privileged behavior.
- Code quality: focused design, existing conventions, and no unnecessary
  rewrite or duplicate representation of a domain concept.
- Tests written for new business rules and authorization boundaries, and the
  relevant tests actually run. Never claim a check was run if it was not.
- Help documentation updated when a user or operator workflow changes.
- [`docs/QA_GUIDE.md`](docs/QA_GUIDE.md) reviewed on every commit and updated
  when the change affects a testable page, action, authorization boundary, or
  operational workflow.
- Architecture docs updated in the same change when the architecture changes.
- Each commit updates relevant documentation when the change affects product
  behavior, architecture, operations, or developer workflow.

Authorization must be scoped to the relevant venue or event context. Business
rules and privileged behavior require automated coverage. Prefer incremental,
reviewable changes over broad rewrites.

## Local quality gate

Enable the fast staged-change hook with:

```sh
git config core.hooksPath .git-hooks
```

The full authoritative gate runs in CI. The hook must fail when a required
tool is unavailable; it must not turn a missing or skipped check into a pass.

## Agent command workflow

When working through an approved agent shell, prefer one command per execution
so approval prefixes remain predictable. Use clean command prefixes such as
`bundle exec`, `bin/rails`, `gh run`, and the appropriate `git` subcommand;
avoid chaining unrelated commands with `&&` or prefixing commands with shell
environment assignments when an equivalent direct invocation is available.

After pushing, prefer one long-lived `gh run watch <run-id>` process over
repeated status polling. Keep commit, merge, rebase, push, destructive Git
operations, and production mutations approval-gated.

## Markdown standards

All documentation and markdown files must:

1. **Specify a language for every fenced code block**
   - Example:

     ```json
     { "key": "value" }
     ```

2. **Add a blank line before and after every heading, list, and code block**
3. **Align all table columns and ensure proper spacing**
4. **Avoid multiple consecutive blank lines**
5. **Run `markdownlint` locally before submitting PRs**
   - Install: `npm install -g markdownlint-cli`
   - Run: `markdownlint docs/**/*.md`
6. **Fix all markdownlint errors and warnings before merging**
7. **Use consistent indentation for lists (2 spaces recommended)**
8. **Do not commit files with unresolved markdownlint errors**

## Commit Message Format

All commits must use the `type(domain): message` format:

- `feat(songs): add drag-to-reorder queue`
- `fix(auth): redirect to venue after sign in`
- `docs(models): update venue model documentation`
- `refactor(controllers): extract venue scope concern`
- `test(songs): add RSpec coverage for skip action`
- `chore(deps): update gem lockfile`

Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`

Common domains: `auth`, `songs`, `venues`, `ui`, `models`, `controllers`, `routes`, `docs`, `deps`

## Enforcement

- PRs with markdownlint errors will be rejected.
- Commits not following the `type(domain): message` format will be rejected.
- Use pre-commit hooks or CI to automatically lint markdown files.

---

CI and the pre-commit hook enforce the checks that are available in the
repository. Keep documentation claims aligned with the code and commands that
were actually run.
