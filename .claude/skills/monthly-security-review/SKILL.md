---
name: monthly-security-review
description: Run the security and dependency review — advisories, outdated dependencies, CI action versions, secrets, access, and the quarterly backup restore test. Use for the monthly reminder, any security or dependency review request, or a newly reported advisory.
---

# Security review procedure

This is an audit: **present findings and change nothing** until the user
says what to fix.

## 1. Collect
1. **Advisories:** run the stack's vulnerability audit. List every
   finding by severity.
2. **Outdated dependencies:** run the stack's outdated check. Separate
   patch/minor from major; for each major, note breaking changes from its
   changelog.
3. **CI:** third-party actions pinned to commit SHAs and current;
   workflow permissions least-privilege.
4. **Secrets:** the secret-scan workflow is green; `.env.example` matches
   the variables the code reads; nothing secret-looking in the repo.
5. **Enforcement:** the hooks in `.claude/settings.json` still exist and
   run (the destructive guard prompts on a harmless test like
   `git push --force --dry-run`).
6. **Access:** list who and what can reach production, deploy workflows,
   and backup storage, as the user describes it. Flag anything stale.
7. **Backups:** the daily backup job ran on each of the last 7 days.
8. **Quarterly (January, April, July, October):** ask the user to run, or
   run via its workflow, a restore of the latest backup to an isolated
   scratch location. Confirm the data is readable and current, and confirm
   the scratch copy is destroyed. Never restore into dev or test.
9. Anything held back from earlier reviews in `docs/BACKLOG.md`.

## 2. Present
One table: finding, severity, proposed fix, effort. Recommend an order.
Critical or high advisories come first, each as its own PR.

## 3. After approval
- Dependency updates get their own PR, never mixed with feature work.
  Batch patch/minor; take majors one at a time.
- After any update: full build, tests with coverage, check in the running
  app.
- A held-back major gets a line in `docs/BACKLOG.md` saying why.

## 4. Record
Add a row to `docs/SECURITY-LOG.md`: date, scope, findings, outcome,
restore-test result if quarterly.
