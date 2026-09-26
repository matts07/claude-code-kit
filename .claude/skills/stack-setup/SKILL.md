---
name: stack-setup
description: Build or change the CI/CD pipeline, deploy and rollback workflows, backups, and scheduled checks for the chosen stack and host. Use once the stack and hosting are decided, or when any part of the pipeline needs adding or changing.
---

# Pipeline requirements

Stack-neutral requirements, implemented with the chosen stack's own tools.
Every change here is Present-first; follow `.claude/rules/ci-workflows.md`.

## 0. Ask, then propose
1. Ask for the stack (language/runtime, frameworks, database, test runner,
   packaging/artifact format) and the host, unless already decided.
2. Propose, for approval, how each requirement below will be implemented
   with that stack's own tools, plus the runtime version pin, lockfile,
   coverage thresholds, and `.gitignore` additions. Build in this order
   and present each piece before writing it.

## 1. CI
- Runs on pushes to `main` and the working branch, and on PRs to `main`.
- Order: install → vulnerability audit (fails on high/critical) → build
  including typecheck → full tests with coverage (hard gate at the
  thresholds in `.claude/rules/testing.md`).
- Secret scan on every push and PR.
- On PRs, a build-only check that the production artifact still builds.

## 2. Build once, deploy that build
The production artifact is built exactly once, after a merge to `main`
passes CI, tagged with the short commit SHA (plus `latest`). Deploys only
ship artifacts CI built.

## 3. Deploy workflow (manual, typed confirmation)
- Never automatic on merge. Deploys `main`'s build by default or a named
  one; fails loudly if the artifact doesn't exist.
- If the build includes a migration: pre-change backup, verified, first.
  Backup failure stops the deploy before any change.
- Keeps exactly one rollback target (the last build running before a
  different one replaced it), tracked explicitly so redeploying the same
  build doesn't lose it.
- Health-checks the new build; auto-rolls back on failure and fails the
  run.
- On success, comments on the source PR (silently skipped for direct
  pushes; a comment failure never fails the deploy).
- Free-text inputs validated against an allow-list pattern.

## 4. Rollback Now (manual, typed confirmation)
Switches straight back to the rollback target: no rebuild, no download.

## 5. Health endpoint
Implement the contract in `.claude/rules/code.md`.

## 6. Backups (whenever there's a database)
- **Daily** (e.g. 09:17 UTC) with the database's safe-while-running
  method; 14-day retention.
- **Pre-change** on demand (migration deploys, approved destructive data
  operations). Verified: completed, non-empty, passes integrity check.
  Kept at least as long as dailies.
- **Storage:** off the host, in separate access-controlled storage with
  its own credentials. Never CI artifacts or anywhere repo-readable.
  Encrypt before upload; key stored separately and listed in the
  disaster-recovery table. The app's credentials can't delete or
  overwrite backups. Access limited to named people and the backup job.
- **Restore runbook** in the deploy guide: where backups are, how to
  decrypt, how to restore to a scratch location, how to verify.

## 7. Scheduled checks
- **Uptime** (hourly, off the hour, e.g. :17): hit the health URL, 3
  retries; if still down, restart and recheck. Any restart fails the run,
  worded differently from "still down".
- **Disk** (every 6h, servers only): fail at ≥80% root usage; print the
  full picture each run. Managed platforms use their own quota alerts.
- **Security review reminder:** opens an issue on the 1st of each month.
- Alerting is the CI system's failed-run notification only.
- Server hosting: one shared set of SSH secrets (key, host, user);
  `ssh-keyscan` with retries and a longer timeout.
- Schedules start disabled until the host and its secrets exist; tell the
  user exactly what to set, and where.

## 8. Release workflow
Triggered by `v*` tags: same checks as CI, then create the release with
the git host's CLI, skipping creation if the release already exists
(web-UI releases create tag and release together). For example, with
GitHub Actions and the `gh` CLI:
```bash
gh release view "${{ github.ref_name }}" > /dev/null 2>&1 || \
  gh release create "${{ github.ref_name }}" --generate-notes --title "${{ github.ref_name }}"
```

## 9. Enforcement
- Branch protection on `main` where the host plan supports it.
- Add `permissions.deny` entries in `.claude/settings.json` for any
  production host, database client, or credential path the project
  introduces (e.g. `Bash(ssh <prod-host> *)`, `Bash(psql *prod*)`).
- Scope any still-unscoped files in `.claude/rules/` with `paths:`
  frontmatter matching the real directories (drop `ui.md` if there's no
  UI).

## 10. Lint and record
1. Lint every workflow with the CI system's linter (e.g. `actionlint` for
   GitHub Actions) and `bash -n` any scripts.
2. Update CLAUDE.md's Project section (stack, commands), the deploy
   guide's disaster-recovery table, and `docs/DECISIONS.md` for choices
   made.
