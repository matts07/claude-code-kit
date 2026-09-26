---
name: release
description: Prepare and cut a versioned release (tag plus release notes) from main. User-invoked only.
disable-model-invocation: true
argument-hint: "[version]"
---

# Release procedure

Only the user starts this skill.

## 1. Is a release warranted?
Only if at least one PR merged into `main` since the last release. Direct
pushes to `main` never justify one. If none: say so, and if the working
branch has unmerged work, offer to PR it first (`/pr`); if the user
chooses that, continue the release after it merges. Otherwise stop.

## 2. Check readiness
`main`'s latest CI run is green. If it's red, stop and report.

## 3. Pick the version
- **Patch** (`x.y.Z`): refactors, bug fixes, code quality only.
- **Minor** (`x.Y.0`): any new user-facing feature. One minor bump per
  release batch, however many features.
- **Pre-release:** `-beta.N`, N incrementing globally across all
  releases. First release is `v1.0.0-beta.1`.
- The `-beta` suffix is dropped only when the user says the app is
  production-ready, never on Claude's call.
- `$ARGUMENTS` overrides the computed version; still show the reasoning.

## 4. Draft notes
Build the notes from the merged PRs' squash commits since the last tag,
not from memory. Show version and notes; wait for a yes.

## 5. Cut it
1. Create the `v*` tag on `main`'s head and push it. The release workflow
   runs the CI checks and creates the release, tolerating a release that
   already exists.
2. If tag pushes are blocked in this environment, tell the user to create
   the release in the git host's web UI with the drafted notes.
3. Watch the workflow; report the release link or the failure.

Deleting or moving a tag or release is destructive: explicit approval
only.
