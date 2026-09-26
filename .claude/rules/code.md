<!--
ADOPT: scope this rule by putting YAML frontmatter ABOVE this comment, as
the file's very first lines, e.g.
---
paths:
  - "src/**"
---
Until scoped, it loads every session. HTML comments are stripped from
context.
-->
# Code conventions

Stack-agnostic conventions. Each exists because breaking it causes a real
bug.

## Data and timestamps
- Timestamps are UTC ISO-8601 strings written explicitly by app code,
  never a database-default "now" (it can produce a non-ISO string that
  parses as local time and displays hours off). Display-timezone
  conversion lives in one shared helper module.
- A write that replaces user data sends the baseline it was edited from.
  The server rejects with `409` (nothing written) if the current data has
  diverged. Don't poll to solve this.

## Structure
- One source of truth for shared data and formatting (one date-formatting
  module, one constants list), never duplicated inline.
- Decision logic goes in pure functions testable without a database; I/O
  stays in thin wrappers around them.
- Extract logic into a shared service as soon as a second caller needs it,
  so every trigger path (manual button, scheduled job) runs the same code.
- New behavior that affects existing users ships switched off or otherwise
  safe for them. Upgrading must not, say, suddenly start emailing
  everyone.
- Scheduled jobs are idempotent: track what's been sent or done, so a
  re-run never double-sends.

## Logging and errors
- Never log secrets or personal data (passwords, tokens, keys, full
  emails or addresses, or request bodies containing them).
- Never swallow errors silently. Handle them, or log with enough context
  to diagnose and fail visibly. A deliberately ignored error gets a
  comment saying why.
- One error format for anything returned to clients, defined once in the
  API docs and used everywhere.
- Users see a helpful message, never internals (stack traces, SQL, file
  paths).

## Configuration and secrets
- Never commit secrets (keys, tokens, passwords, URLs with credentials):
  not in code, config, tests, docs, or commit messages.
- If a secret is committed anyway, rotate it first, then remove it.
  Removing it doesn't un-leak it.
- Required secrets fail fast in production: refuse to start rather than
  fall back to a default visible in source.
- Adding an environment variable is a checklist, done in the same change:
  `.env.example` (placeholder value), the environment-variable tables in
  the docs, and the deploy guide's disaster-recovery table (secret or
  not, and where it comes from on a rebuild).

## Health endpoint contract
Applies to anything that runs as a service. `GET /api/health` (or the
equivalent) is public and does a real database read. It returns
`200 {"status":"ok","time":"<ISO>","id":"<deployed build id>"}`, or `503`
with `"status":"error"` when the database is unreachable. Deploy
auto-rollback and the uptime check depend on it.
