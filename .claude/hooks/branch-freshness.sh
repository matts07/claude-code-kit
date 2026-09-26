#!/usr/bin/env bash
# Branch-freshness check. Warns, never blocks.
#   branch-freshness.sh session  -> SessionStart: fetch, then report if the
#                                   branch is behind its upstream.
#   branch-freshness.sh edit     -> PreToolUse on Edit|Write: no network;
#                                   report if behind the last fetch.
# Requires git and jq.

set -u
mode="${1:-edit}"
cat >/dev/null 2>&1 # drain hook input

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || exit 0

if [ "$mode" = "session" ]; then
  timeout 20 git fetch --quiet 2>/dev/null || {
    echo "Branch-freshness: could not fetch from the remote. Confirm '$branch' is at its remote head before editing (CLAUDE.md HARD RULE)."
    exit 0
  }
fi

behind=$(git rev-list --count "HEAD..$upstream" 2>/dev/null || echo 0)
[ "$behind" -gt 0 ] 2>/dev/null || exit 0

msg="Branch '$branch' is $behind commit(s) behind '$upstream'. CLAUDE.md HARD RULE: sync to the remote head before editing any file."
if [ "$mode" = "session" ]; then
  echo "$msg"
else
  jq -n --arg m "$msg (Checked against the last fetch.)" '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$m}}'
fi
exit 0
