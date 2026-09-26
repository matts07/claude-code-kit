---
name: deploy
description: Ship main's latest (or a named) build to production through the deploy workflow and verify it. User-invoked only.
disable-model-invocation: true
argument-hint: "[build-id]"
---

# Deploy procedure

Only the user starts this skill. Claude never touches production directly:
everything below goes through the deploy workflow, never a shell on a
host.

## 1. Preconditions (report and stop if any fails)
1. Target build: `$ARGUMENTS` if given, otherwise `main`'s current commit.
   Its artifact must exist (built once by CI after merge). If it doesn't,
   stop; never rebuild or redeploy what's running.
2. CI for that commit is green.
3. List what changed since the currently deployed build, from the git
   range.
4. **Migrations in range?** Confirm each follows expand/contract, so the
   rollback target can run against the new schema. A migration that
   breaks that is destructive: stop and get explicit approval naming it.
5. **Data-loss migration in range?** It needs its own explicit approval
   naming the loss and the pre-change backup it relies on.

## 2. Confirm
Show the user: build id, change summary, migrations (if any), the
pre-change backup plan, and the current rollback target. Wait for a yes.

## 3. Run
1. Trigger the deploy workflow with its typed confirmation. The workflow,
   not Claude:
   - takes and verifies a pre-change backup when the build includes a
     migration, and stops before changing anything if that fails;
   - starts the new build, health-checks it, and auto-rolls back on
     failure (failing the run);
   - records the rollback target.
2. Watch the run to completion.

## 4. Verify
1. Request the public health endpoint; confirm `status: ok` and that `id`
   matches the deployed build.
2. Exercise the change the deploy was for, using only public, read-only
   paths.
3. For an infra or deploy fix, re-trigger the thing that originally failed.

## 5. Report
Deployed build, verification results, and the rollback target. On any
failure or auto-rollback: report what happened and stop. Rollback Now is
the user's call; offer it, don't run it unasked.
