<!--
ADOPT: scope by putting frontmatter ABOVE this comment, listing server,
API, and auth code, e.g.
---
paths:
  - "server/**"
  - "api/**"
---
-->
# Security conventions

## Authentication and authorization
- Every endpoint checks authorization on the specific object requested,
  not just "logged in". A user changing an id in the URL must never reach
  someone else's record.
- Passwords are hashed with a modern password-hashing algorithm, never a
  general-purpose hash.
- No account enumeration: login and password-reset responses, and their
  timing, never reveal whether an account exists (run the hash compare
  against a dummy hash when there's no user).
- Endpoints reachable by non-admins never return other users' personal
  data. Return an id plus a display name; key "is this me" off the id.
  Check the raw API response, not just the UI.

## Input and output
- Validate on the server at every trust boundary. Client checks and
  client clocks are cosmetic.
- Escape user-supplied text in HTML (including HTML emails) through the
  shared escape helper, every time.
- Validate free-text input that reaches a shell (e.g. a manual workflow
  input in an SSH command) against a strict allow-list pattern.
- Don't leak hidden data through ordering, placeholders, counts, or
  differing responses.

## Abuse and secrets
- Rate-limit every unauthenticated write and every endpoint with an
  external side effect (login, reset, sign-up, email).
- Security-sensitive randomness (passwords, codes, tokens) uses a
  cryptographically secure source.
- Default or seeded credentials are changed immediately outside local dev.

## Browser
- Security headers (CSP, HSTS, frame options) on by default. Verify a real
  production build still loads under the default CSP.
- Session cookies are `HttpOnly`, `Secure`, and `SameSite`; state-changing
  requests are protected against cross-site request forgery.

## Dependencies
- A new dependency needs approval (Present-first tier): say what it's for,
  its maintenance status, and its license.
- Always commit the lockfile, and pin the runtime version.
- High or critical advisories fail CI and are fixed right away in their
  own PR. Everything else goes to `/monthly-security-review`.
