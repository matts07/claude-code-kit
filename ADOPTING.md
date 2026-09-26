# Adopting the kit in an existing project

Adoption is a change like any other, so it follows the kit's own rules
from the first step: nothing is overwritten or deleted without explicit
approval, every change is presented before it's made, and everything lands
in one reviewed, squash-merged PR.

Claude can run this procedure. Paste "Adopt the Claude Code template kit
per ADOPTING.md" with the kit available, and it should stop at each
**Present** point below.

## Ground rules for the adoption

- **Work on a branch.** Use the project's existing working branch, or a
  short-lived `chore/adopt-claude-kit` branch off `main` created with the
  user's OK.
- **Copy, never overwrite.** Stage the kit in a scratch folder outside the
  repo, and merge file by file. An existing file is never replaced
  wholesale.
- **Nothing is deleted in this PR.** Old instructions that no longer fit
  are moved or marked obsolete, never silently dropped. Removing existing
  hooks, commands, workflows, credentials, or backups is destructive and
  gets its own named approval, usually in a later PR.
- **Existing conventions win until changed on purpose.** Where the kit and
  the codebase disagree, use the convention-change procedure: list every
  usage, offer all-at-once or one-by-one, recommend one, and let the user
  decide.
- **Don't invent history.** `docs/HISTORY.md` is seeded only from real
  merged PRs, or left starting from the adoption PR.

## 1. Inventory (read-only)

Collect, without changing anything:

| Area | Look for |
|---|---|
| Instructions | `CLAUDE.md` (root, `.claude/`, subdirectories), `CLAUDE.local.md`, `AGENTS.md`, `.cursorrules`, `.cursor/rules/`, `.github/copilot-instructions.md` |
| Claude Code config | `.claude/settings.json`, `.claude/settings.local.json` (is it committed?), `.claude/hooks/`, `.claude/skills/`, `.claude/commands/`, `.claude/rules/`, `.claude/agents/` |
| Git and review | Branch model (one permanent branch, or per-feature?), number of contributors, merge style (squash, merge, rebase), branch protection, PR template, CODEOWNERS |
| CI/CD | Workflows: CI steps, vulnerability audit, secret scan, coverage gate, build-once artifacts, deploy trigger (manual or on merge?), rollback path, release process |
| Data | Migration tool and folder, whether past migrations are editable, seed data, any production data in dev/test/fixtures |
| Backups | Where, how often, retention, encrypted?, who can read or delete them, when last restored |
| Production access | Any credentials, SSH config, database URLs, or cloud CLIs Claude's environment can reach |
| Tests | Test runner, coverage tool, actual coverage per package |
| Docs | README, developer and deploy guides, API docs, changelog, ADRs |

**Present:** the inventory, plus a gap list against the kit (what's
missing, what conflicts, what's risky now). Flag anything urgent on its
own line, above all production credentials Claude can reach and backups
stored somewhere repo-readable.

## 2. Decisions for the user

Ask these together, with a recommendation for each:

1. **Branch model.** One developer and one Claude session → keep the
   kit's permanent branch (name it). Several contributors or parallel
   sessions → state that short-lived branches are the norm in CLAUDE.md,
   and set the hook's `PERMANENT_BRANCH` only if one exists.
2. **Merge style.** The kit assumes squash-merge with the description
   written from the diff. If the project uses something else, decide
   whether to switch (a convention change) or adapt `/pr`.
3. **Deploy trigger.** The kit requires manual deploys of a CI-built
   artifact. If the project deploys on merge, record it as a gap now and
   plan the change with `/stack-setup`; don't switch it in the adoption
   PR.
4. **Coverage baseline** (see step 7).
5. **Which parts to adopt now.** For example, skip `ui.md` for a service
   with no UI, or defer `/release` until the project cuts versions.

## 3. Map existing instructions into the kit's layers

For every section of every existing instruction file, pick one
destination:

| Kind of content | Goes to |
|---|---|
| Must hold every session, costly if missed (approval rules, safety, Git invariants) | `CLAUDE.md` |
| Convention for one area of the code | Matching `.claude/rules/` file, or a new one |
| Multi-step procedure | A skill (existing command or skill → keep it, and add the kit's gates) |
| History, logs, decisions, TODOs | `docs/` |
| Build, test, run commands and non-obvious layout | CLAUDE.md → Project |
| Contradicts the kit | Decision for the user (convention-change procedure) |
| Obsolete | Listed for the user; not deleted in this PR |

Merge rules:
- **CLAUDE.md:** start from the kit's file and add the project's
  invariants into the matching sections. Keep it under 200 lines; move
  detail to rules or skills rather than trimming meaning.
- **AGENTS.md shared with other tools:** keep it, and put `@AGENTS.md` at
  the top of CLAUDE.md, or move shared content into AGENTS.md. Don't
  duplicate it.
- **Nested CLAUDE.md files:** leave them; they load only when that
  directory is read. Remove from them anything that duplicates or
  contradicts the root file.
- **Existing skills or commands with the same names** (`pr`, `deploy`,
  …): merge the kit's gates into the existing procedure rather than
  replacing it. Keep `disable-model-invocation: true` on deploy and
  release.

**Present:** the mapping table (source section → destination) and every
conflict, before writing anything.

## 4. Fill in placeholders

- `<feature-branch>`, `<owner>/<repo>`, every `_TBD`.
- `PERMANENT_BRANCH` in `.claude/hooks/guard-destructive.sh`.
- Project section: run each install, build, and test command to confirm
  it works before writing it down.
- `/stack-setup` and `/deploy`: the project's actual workflow names and
  audit and outdated-dependency commands.

Check: `grep -rn '<feature-branch>\|<owner>/<repo>\|_TBD' CLAUDE.md .claude`
returns nothing, except in `docs/BACKLOG.md` and deliberate
`_None yet._` markers.

## 5. Scope the rules files

For each file in `.claude/rules/`, put `paths:` frontmatter as its first
lines (above the ADOPT comment), matching the project's real directories.
Delete the ADOPT comment once scoped. Rules that would match nothing
(e.g. `ui.md` with no UI) are dropped from the kit copy, not added.

## 6. Merge settings and hooks

- **settings.json:** merge key by key into any existing file. Keep
  existing allow, deny, and hook entries; add the kit's. Never widen an
  existing deny rule.
- **Add project-specific denies** for anything from the inventory that
  reaches production, e.g. `Bash(ssh <prod-host> *)`, `Bash(psql *prod*)`,
  `Read(./config/production.*)`.
- **Hooks:** copy both scripts, `chmod +x`, and confirm `jq` and `git`
  are installed. If the project already has a Bash `PreToolUse` guard,
  merge the patterns into one script rather than running two.
- **Local settings:** `.claude/settings.local.json` belongs in
  `.gitignore`. If it's committed, untracking it is a change the user
  approves; its rules are held until the folder is trusted anyway.

## 7. Close the data, backup, and coverage gaps, honestly

These rarely match the kit on day one. Record the gap and a plan; don't
paper over it.

- **Production access.** If Claude's environment can reach production
  credentials, that's the first fix: the user removes them from Claude's
  environment (removing or changing secrets is destructive, so it needs
  named approval), and settings.json gets deny rules for them.
- **Production data outside production.** Fixtures or dev databases
  built from real data: record in `docs/BACKLOG.md`, replace with
  synthetic seeds or a reviewed anonymization script, and treat existing
  copies as production data until then.
- **Backups.** Compare with the `/stack-setup` requirements. Backups in
  CI artifacts or other repo-readable places move to access-controlled,
  encrypted storage. Deleting the old copies is destructive and happens
  only after the new ones are verified, with named approval. If there
  has never been a restore test, do one in the first
  `/monthly-security-review`.
- **Migrations.** Expand/contract applies to new migrations from now on.
  Shipped migrations are never edited, even if they didn't follow it.
- **Coverage.** Non-UI code is 100% with no lowering, but an existing
  project may be far below that. The honest option: gate CI at the
  current actual numbers as an **adoption baseline**, recorded in
  `.claude/rules/testing.md` with the date and the user's sign-off, and
  ratchet up only. Add a plan to reach 100% to `docs/BACKLOG.md`. New
  and changed code meets the full thresholds immediately.
- **CI gaps** (no secret scan, no audit gate, deploy on merge, no
  rollback): record each in `docs/BACKLOG.md` and schedule with
  `/stack-setup`. Adding a missing secret scan or audit gate can go in
  the adoption PR if the user wants; changing how deploys work cannot.

## 8. Seed the docs

- `docs/DECISIONS.md`: one ADR per decision already made and still in
  force (stack, hosting, merge style, branch model), drawn from what the
  code and existing docs show. Mark any whose reasoning is unknown as
  "Context: not recorded".
- `docs/HISTORY.md`: start with the adoption PR, or backfill only from
  the git host's list of merged PRs.
- `docs/BACKLOG.md`: every gap from steps 1 and 7.
- `docs/SECURITY-LOG.md`: empty until the first review.

## 9. Verify before the PR

Run each check and record the result in the PR's "How it was tested"
section.

| Check | Expect |
|---|---|
| `wc -l CLAUDE.md` | Under 200 |
| `/context` in a fresh session | CLAUDE.md and any unscoped rules listed under memory files |
| Open a file matching a scoped rule, then `/context` | That rule now listed |
| `/hooks` | SessionStart freshness hook; PreToolUse guard on Bash; freshness on Edit and Write |
| `/skills` | `pr`, `monthly-security-review`, `stack-setup`, `deploy`, `release` all listed |
| Ask Claude to run `/deploy` | It can't; it tells you to run it |
| Ask Claude to run `git push --force --dry-run` | Permission prompt citing the destructive rule |
| Ask Claude to delete the permanent branch | Blocked by the hook |
| Ask Claude to read `.env` | Denied; `.env.example` still readable |
| Put the branch one commit behind its remote, start a session | Freshness warning appears |
| Full build and full test suite with coverage | Pass at the agreed thresholds |
| In a fresh session, ask "what do you do before a destructive action, and what counts as approval?" | Answer matches THE MOST IMPORTANT RULE |

## 10. Ship it

1. Commit locally as you go.
2. Open **one** adoption PR with `/pr`. The description lists every file
   added or changed, the mapping from step 3, the decisions from step 2,
   the gaps deferred to the backlog, and "Destructive changes: none".
3. Squash-merge once CI is green and the user approves.
4. Afterwards, in separate PRs: each deferred gap, in the order agreed,
   and then the first `/monthly-security-review` to set the security
   baseline (and the first restore test, if none has ever been done).

To back out, revert the adoption PR. Nothing outside it was changed.
