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
     trail.) A fix found while the PR is still unmerged: ask whether to
     fold it into that PR rather than defaulting to a follow-up PR.
   - **Merged or none:** confirm opening a new PR.
   - **Something new raised while a PR is in flight** is not permission to
     add it to that PR. Ask.

## 2. Gate
1. Full build including typecheck/compile: must pass.
2. Full test suite with coverage: must pass, and coverage must not drop.
   - **No build or tests exist yet** (before `/stack-setup`): say so
     plainly in the go-over and in the description ("no build or test
     suite yet — nothing to run"). Never skip them silently, and never
     treat "nothing ran" as "passed".
   - **The PR contains code but no tests exist yet:** stop and ask. Code
     shouldn't merge without the coverage gate, so the likely answer is
     `/stack-setup` first.
3. **Docs are complete.** From the diff, list every doc the change could
   affect (README, user and developer guides, API reference, deploy guide
   and its disaster-recovery table, `.env.example`, CLAUDE.md's Project
   section, `.claude/rules/`). Mark each "updated" or "not affected,
   because …". Any doc left unchecked or out of date: stop. Docs describe
   `main` plus this PR only.
4. For migrations: expand/contract followed; any data-loss step called
   out.
5. For new user-tied state: backward-compatibility answer written down.
6. Run the built-in `/code-review` on the changes. Present what it
   confirms in the go-over, each with a proposed fix; fixes the user
   approves go into this PR before it opens.

Any failure: stop and report. Don't open the PR.

## 3. Write the description from the diff
1. Pull the actual file list and diff for the PR's range.
2. Write the title and body from that diff only, never from memory or from
   `docs/HISTORY.md` (that covers already-merged work).
3. Fill every section of the PR template: what changed, why, how tested,
   docs updated (the list from gate step 3), destructive changes (or
   "none"), follow-ups.
4. Add the `docs/HISTORY.md` entry for this PR (one numbered entry: what
   shipped, and any decision worth remembering), from the diff, as a
   commit on the branch, so it's part of what's reviewed. If the PR number
   isn't known yet, add the entry right after opening the PR.
5. Updating an existing PR: re-read the full diff and rewrite the
   description and the HISTORY entry to match it.

## 4. Open or update
Push the branch and open or update the PR. Report the link.

## 5. Merge (only when asked, or as part of an approved chain)
1. Wait for CI to be green. Red CI or a merge conflict: stop and report.
2. **Squash-merge.** PR title = commit title; PR description = commit
   body.
3. Merge `main` back into the working branch with a normal merge (never a
   reset or force-push) and push.
4. **Never delete the permanent working branch.** A short-lived branch is
   deleted only with explicit approval.
5. If the user's request chains to `/deploy` or `/release`, stop here and
   tell them to run that command themselves; those skills are user-only.

## Auth errors
Any push rejection, permission error, or not-found on a write: tell the
user to reconnect the git host integration. No workarounds.
