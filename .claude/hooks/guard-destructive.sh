#!/usr/bin/env bash
# PreToolUse hook for Bash. Turns destructive commands into a permission
# prompt ("ask") the user must approve, and hard-blocks ("deny") deleting
# the permanent working branch. Prints nothing for everything else, so the
# normal permission flow applies. Requires jq.
#
# ADOPT: set PERMANENT_BRANCH to the project's permanent working branch.
# Extend PATTERNS when a new destructive command matters.

set -u
PERMANENT_BRANCH="<feature-branch>"

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

emit() { # $1 = ask|deny, $2 = reason
  jq -n --arg d "$1" --arg r "$2" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  exit 0
}

# Hard block: deleting the permanent branch, locally or on the remote.
# [^;&|] keeps each match inside one command, so "git branch -d other &&
# git switch <permanent>" isn't mistaken for deleting the permanent branch.
if [ "$PERMANENT_BRANCH" != "<feature-branch>" ]; then
  b=$(printf '%s' "$PERMANENT_BRANCH" | sed 's/[][\.*^$/]/\\&/g')
  seg='[^;&|]'
  end='([[:space:];&|]|$)'
  if printf '%s' "$cmd" | grep -Eq "git[[:space:]]$seg*branch$seg*[[:space:]](-d|-D|--delete)[[:space:]]+($seg*[[:space:]/])?$b$end" \
    || printf '%s' "$cmd" | grep -Eq "git[[:space:]]$seg*push$seg*[[:space:]](--delete|-d)[[:space:]]+($seg*[[:space:]/])?$b$end" \
    || printf '%s' "$cmd" | grep -Eq "git[[:space:]]$seg*push$seg*[[:space:]]:$b$end"; then
    emit deny "Blocked: '$PERMANENT_BRANCH' is the permanent working branch and is never deleted (CLAUDE.md)."
  fi
fi

# Start of a git command up to its subcommand: git, then any global options
# (-C <dir>, -c <key=value>, other flags). New patterns below match the
# subcommand itself, so a ref or path containing "branch" or "checkout"
# can't trigger them.
gs='(^|[;&|[:space:]])git([[:space:]]+(-[cC][[:space:]]+[^[:space:];&|]+|-[^[:space:];&|]+))*[[:space:]]+'

# Destructive patterns -> ask. Each entry: extended regex|description
PATTERNS=(
  'git[[:space:]].*push.*[[:space:]](--force|--force-with-lease|--force-if-includes|-[a-zA-Z]*f([[:space:]]|$))|force-push'
  'git[[:space:]].*push.*[[:space:]]\+[^[:space:]]+|force-push via +refspec'
  'git[[:space:]].*push.*(--delete|[[:space:]]-d([[:space:]]|$)|[[:space:]]:[^[:space:]]+)|remote branch or tag delete'
  'git[[:space:]].*push.*--mirror|mirror push'
  'git[[:space:]].*reset.*--hard|reset --hard (discards work)'
  'git[[:space:]].*clean[[:space:]]+-[a-zA-Z]*[fdx]|git clean (deletes untracked files)'
  'git[[:space:]].*checkout.*(--[[:space:]]|[[:space:]]\.([[:space:]]|$))|checkout over working-tree changes'
  "$gs"'checkout([[:space:]][^;&|]*)?[[:space:]](-[a-z]*f[a-z]*|--force)([[:space:];&|]|$)|checkout --force (discards changes)'
  "$gs"'switch([[:space:]][^;&|]*)?[[:space:]](-[a-z]*f[a-z]*|--force|--discard-changes)([[:space:];&|]|$)|switch discarding changes'
  'git[[:space:]].*restore([[:space:]]|$)|restore over working-tree changes'
  "$gs"'branch([[:space:]][^;&|]*)?[[:space:]](-[a-z]*f[a-z]*|--force)([[:space:];&|]|$)|branch force-move (can orphan commits)'
  "$gs"'worktree[[:space:]]+remove([[:space:]][^;&|]*)?[[:space:]](-[a-z]*f[a-z]*|--force)([[:space:];&|]|$)|worktree remove --force (discards its changes)'
  'git[[:space:]].*(rebase|filter-branch|filter-repo)([[:space:]]|$)|history rewrite'
  'git[[:space:]].*commit.*--amend|history rewrite (amend)'
  'git[[:space:]].*branch.*[[:space:]](-d|-D|--delete)([[:space:]]|$)|branch delete'
  'git[[:space:]].*tag.*[[:space:]](-d|--delete)([[:space:]]|$)|tag delete'
  'git[[:space:]].*stash[[:space:]]+(drop|clear)|stash drop'
  'git[[:space:]].*(update-ref[[:space:]]+-d|reflog[[:space:]]+(expire|delete)|gc[[:space:]].*--prune)|ref or reflog deletion'
  '(^|[[:space:]]|/)gh[[:space:]].*[[:space:]]delete([[:space:]]|$)|git host resource delete'
  '(^|[[:space:]]|/)gh[[:space:]]+(pr|issue)[[:space:]]+close|closing a PR or issue'
  '(^|[;&|[:space:]])rm([[:space:]][^;&|]*)?[[:space:]](-[a-zA-Z]*r[a-zA-Z]*|--recursive)([[:space:]]|$)|recursive delete'
  '(drop[[:space:]]+(table|database|schema|column)|truncate[[:space:]]+(table[[:space:]]+)?[a-z_"`]|delete[[:space:]]+from)|destructive SQL'
  '(terraform|tofu)[[:space:]].*(destroy|apply)|infrastructure change'
  'kubectl[[:space:]].*(delete|drain)|cluster resource delete'
  'docker[[:space:]].*((volume|image|container|system)[[:space:]]+(rm|prune)|rmi)|container resource delete'
)

# Patterns using [^;&|]* stay inside one command, so a later command in a
# chain (e.g. "&& git -C dir status") can't complete the match.
#
# Case-sensitive patterns, matched against the original command: these flags
# differ from harmless ones only by case (-B/-C/-M vs -b/-c/-m), which the
# lowercased match above can't tell apart.
CASE_PATTERNS=(
  "$gs"'checkout([[:space:]][^;&|]*)?[[:space:]]-[a-zA-Z]*B[a-zA-Z]*([[:space:];&|]|$)|checkout -B (resets an existing branch)'
  "$gs"'switch([[:space:]][^;&|]*)?[[:space:]]-[a-zA-Z]*C[a-zA-Z]*([[:space:];&|]|$)|switch -C (resets an existing branch)'
  "$gs"'branch([[:space:]][^;&|]*)?[[:space:]]-[a-zA-Z]*[MC][a-zA-Z]*([[:space:];&|]|$)|branch -M/-C (overwrites an existing branch)'
)

lower=$(printf '%s' "$cmd" | tr '[:upper:]' '[:lower:]')
check() { # $1 = text to match, rest = entries
  local text="$1" entry re desc; shift
  for entry in "$@"; do
    re="${entry%|*}"; desc="${entry##*|}"
    if printf '%s' "$text" | grep -Eq -- "$re"; then
      emit ask "Destructive command ($desc). Per CLAUDE.md: say exactly what this destroys and whether it can be undone, and get explicit approval for this specific action."
    fi
  done
}
check "$lower" "${PATTERNS[@]}"
check "$cmd" "${CASE_PATTERNS[@]}"
exit 0
