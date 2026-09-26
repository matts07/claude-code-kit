<!--
ADOPT: scope by putting frontmatter ABOVE this comment, listing CI config,
e.g.
---
paths:
  - ".github/workflows/**"
---
The full pipeline requirements live in the /stack-setup skill.
-->
# CI workflow conventions

- **Permission scopes:** declaring any explicit permissions block usually
  resets every unlisted scope to none. A workflow that adds one write
  scope may also need read access to contents, or checkout fails with a
  misleading "Repository not found". Examples: creating a release with
  the git host's CLI needs write access to contents; a secret-scan action
  that lists a PR's commits (e.g. gitleaks-action) needs read access to
  pull requests, or the repository's first PR fails with a 403.
- **Least privilege:** each workflow grants only the scopes it needs.
- **Pin third-party actions to a full commit SHA**, with the version in a
  comment. Prefer the git host's own CLI over third-party actions.
- **No heredocs inside a YAML block scalar (`run: |`):** bash needs the
  terminator at column 0, YAML needs it indented. Use a `&&` chain or a
  script file, and `bash -n` anything with tricky quoting before pushing.
- Free-text workflow inputs that reach a shell are validated against a
  strict allow-list pattern first.
- Schedules run off the top of the hour (e.g. :17), where scheduled-run
  delays peak, and no more often than needed.
- Alerting is the CI system's own failed-run notification. A job that
  self-heals (e.g. restarts the app) still fails the run so the alert
  fires.
- Never store backups or production data as CI artifacts.
- `ssh-keyscan` from hosted runners gets retries and a longer timeout.
