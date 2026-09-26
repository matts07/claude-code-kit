---
name: pr
description: Prepare, open, update, or squash-merge a pull request from the working branch into main. Use when the user asks to open a PR, PR it, make a PR, send it for review, update the PR, or merge it.
---

# Pull request procedure

CLAUDE.md wins over anything here. Opening or updating a PR is the
Present-first tier; merging is part of an approved chain or needs its own
go-ahead.

## 1. Check state
1. Fetch; confirm the local branch is at its remote head.
2. Find any PR from this branch and its state (open, merged, none).
3. Ask the user, never assume:
   - **Open PR:** add this work to it, or open a new PR? (One PR per
     feature or fix is the default, for cherry-picking and a clean audit
     trail.)
   - **Merged or none:** confirm opening a new PR.
   - **Something new raised while a PR is in flight** is not permission to
     add it to that PR. Ask.

## 2. Gate
1. Full build including typecheck/compile: must pass.
2. Full test suite with coverage: must pass, and coverage must not drop.
3. Docs for this feature are in this PR; docs describe `main` plus this PR
   only.
4. For migrations: expand/contract followed; any data-loss step called
   out.
5. For new user-tied state: backward-compatibility answer written down.

Any failure: stop and report. Don't open the PR.

## 3. Write the description from the diff
1. Pull the actual file list and diff for the PR's range.
2. Write the title and body from that diff only, never from memory or from
   `docs/HISTORY.md` (that covers already-merged work).
3. Fill every section of the PR template: what changed, why, how tested,
   destructive changes (or "none"), follow-ups.
4. Updating an existing PR: re-read the full diff and rewrite the
   description to match it.

## 4. Open or update
Push the branch and open or update the PR. Report the link.

## 5. Merge (only when asked, or as part of an approved chain)
1. Wait for CI to be green. Red CI: stop and report.
2. Add the `docs/HISTORY.md` entry (one numbered entry: what shipped, and
   any decision worth remembering) as a commit on the branch, from the
   diff.
3. **Squash-merge.** PR title = commit title; PR description = commit
   body.
4. Merge `main` back into the working branch with a normal merge (never a
   reset or force-push) and push.
5. **Never delete the permanent working branch.** A short-lived branch is
   deleted only with explicit approval.
6. If the user's request chains to `/deploy` or `/release`, stop here and
   tell them to run that command themselves; those skills are user-only.

## Auth errors
Any push rejection, permission error, or not-found on a write: tell the
user to reconnect the git host integration. No workarounds.
