<!--
ADOPT: scope by putting frontmatter ABOVE this comment, listing test files
and test-runner config, e.g.
---
paths:
  - "**/*.test.*"
  - "tests/**"
---
The "every change ships with tests" rule is also in CLAUDE.md.
-->
# Testing and coverage

## Conventions
- Every change ships with tests. Every bug fix gets a regression test that
  fails without the fix and asserts the exact thing that broke (e.g. a
  timestamp matches a strict ISO-8601 regex), not just "a value exists".
- Reset mocks between tests; a leftover queued return value can send a
  later test down a real code path.
- Restore fake timers in a `try/finally`.
- Stub platform APIs the test environment lacks once, globally, in the test
  setup file.
- A flaky test is fixed or quarantined with a tracking item. Never retry
  until green.
- Test data is synthetic, never production data.

## Coverage policy
Coverage is a hard CI gate. Thresholds live in the test runner's config;
the table below records them.
- **Non-UI code: 100%** lines, functions, branches, statements. Never
  lowered. If code can't be covered, restructure it.
- **UI code: starts at 100%.** A metric may go below 100% only where
  reaching it is impossible or clearly not worth it (e.g. tools counting
  defensive fallbacks as unreachable branches), with the reason recorded
  here and the user's sign-off. Lines and functions still reach 100%. Set
  exceptions as close to actual coverage as possible; thresholds only go
  up.
- **Adoption baseline** (existing projects only): the gate may start at
  the actual numbers on the adoption date, recorded below with the user's
  sign-off, and only ratchets up. New and changed code meets the full
  thresholds. The plan to reach 100% lives in `docs/BACKLOG.md`.
- **Exclusions:** only files that can't meaningfully be unit-tested
  (entry points, routing bootstraps, type-only files, always-mocked
  modules, tests themselves), each listed below with the reason.

| Package | Lines | Functions | Branches | Statements | Actual | Exceptions |
|---|---|---|---|---|---|---|
| Non-UI | 100% | 100% | 100% | 100% | — | none allowed |
| UI | 100% | 100% | 100% | 100% | — | none yet |

**Excluded from coverage:** _none yet._
