# Backlog

Pending work, held-back dependency upgrades (with why), and conventions
waiting to be promoted into `.claude/rules/`.

## Pending work
- [ ] **API layout** (if the project has an API): all routes under
      `/api/*`, served by the backend; the frontend dev server proxies
      `/api` to it; in production the backend serves the built frontend.
      Record in `docs/DECISIONS.md` once adopted.

## Held-back upgrades
_None._

## Deferred conventions
Promote into `.claude/rules/` when they become relevant:
- A disabled feature returns a bare `404`, indistinguishable from a
  nonexistent route, and its page redirects away too, not just its API.
- Bot mitigation without third-party services: honeypot field, minimum
  form-fill time, and a rate limit. No CAPTCHA.
- Prefer first-party mechanisms over new dependencies or services.
- Imports skip records that already exist.
- Admin-editable content lives in the database. A repo copy is only a
  seed and won't auto-sync; say so wherever that applies.
- Settings go in a generic key/value table, not a new column per setting.
- RPO/RTO targets, stated, and backup frequency derived from them.
- Incident procedure: stop and report, roll back or forward, no manual
  data fixes, written post-incident note.
- Structured logs, error tracking, and audit logging of admin and
  sensitive actions.
- Timeouts, retries with backoff, and idempotency keys on external calls
  with side effects.
- Feature-flag lifecycle: flags get an owner and are removed after
  rollout.
