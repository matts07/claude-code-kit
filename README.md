# Claude Code project template kit

A stack-agnostic setup that makes Claude Code work under explicit rules:
destructive actions need named approval, production is off-limits, and
code reaches `main` only through reviewed, squash-merged PRs.

- **New project:** follow "Set up a new project" below.
- **Existing project:** follow [ADOPTING.md](ADOPTING.md).

## What's in the kit

| Path | Loads | Holds |
|---|---|---|
| `CLAUDE.md` | Every session | Invariants: destructive-action rule, precedence, approval tiers, production and data rules, untrusted content, Git workflow, skill triggers, working practices, project facts. Kept under 200 lines. |
| `.claude/rules/*.md` | Every session until scoped with `paths:`, then only when matching files are read | Area conventions: `code`, `migrations`, `security`, `ui`, `testing` (with coverage policy), `ci-workflows` |
| `.claude/skills/*/SKILL.md` | Description always; body only when run | Procedures: `/pr`, `/deploy`, `/release`, `/monthly-security-review`, `/stack-setup`. `/deploy` and `/release` are user-only (`disable-model-invocation: true`), so Claude can never start them. |
| `.claude/settings.json` + `.claude/hooks/` | Enforced by Claude Code, not by the model | Destructive-command guard (prompts; hard-blocks deleting the permanent branch), branch-freshness warnings, deny rules for secret files and credential directories, read-only git allowlist |
| `docs/` | Never, unless read | `HISTORY.md` (one entry per merged PR), `DECISIONS.md` (ADRs), `SECURITY-LOG.md`, `BACKLOG.md` |
| `.github/pull_request_template.md` | — | PR sections `/pr` fills from the diff |

Why the split: CLAUDE.md loads into every session, and long files are
followed less reliably. Anything that must never be missed is in
CLAUDE.md or enforced by a hook; procedures load only when used; area
conventions load only when that area's files are read.

## Set up a new project

1. Copy the kit's contents into the repository root (skip `README.md` and
   `ADOPTING.md`, or keep them under `docs/`).
2. Replace placeholders:
   `grep -rn '<feature-branch>\|<owner>/<repo>\|_TBD' CLAUDE.md .claude`
   — including `PERMANENT_BRANCH` in `.claude/hooks/guard-destructive.sh`.
3. `chmod +x .claude/hooks/*.sh`. The hooks need `jq` and `git` on the
   PATH.
4. Add `.claude/settings.local.json` to `.gitignore`.
5. Once the stack exists, scope each rules file with `paths:` frontmatter
   (instructions are in each file's top comment) and fill in the Project
   section's commands.
6. Run `/stack-setup` when the stack and host are chosen.
7. Verify with the checklist in ADOPTING.md, step 9.
