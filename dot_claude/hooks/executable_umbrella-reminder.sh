#!/usr/bin/env bash
# UserPromptSubmit: when the session's cwd is an umbrella folder (no .git, but
# 2+ git repos directly under it), remind the agent of the CLAUDE.md
# "Umbrella folders" rule. Silent everywhere else, so repo sessions cost nothing.
# A hook cannot move or start sessions itself; only the agent can, via app tools.
set -uo pipefail

in=$(cat)
# python3, not jq: same missing-dependency reasoning as route-gate.sh.
cwd=$(printf '%s' "$in" | python3 -c "
import json,sys
try: print(json.load(sys.stdin).get('cwd') or '', end='')
except Exception: pass")
[ -z "$cwd" ] && cwd=$PWD
[ -d "$cwd" ] || exit 0
[ -e "$cwd/.git" ] && exit 0

repos=()
for d in "$cwd"/*/; do
  [ -e "$d.git" ] && repos+=("$(basename "$d")")
done
[ "${#repos[@]}" -ge 2 ] || exit 0

REPOS="${repos[*]}" CWD="$cwd" python3 -c '
import json,os
repos=", ".join(os.environ["REPOS"].split())
print(json.dumps({"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext":
"UMBRELLA FOLDER — cwd " + os.environ["CWD"] + " is not a repo; it holds: " + repos + ".\n"
"Per ~/.claude/CLAUDE.md \"Umbrella folders\", settle where this work belongs this turn, read-only tasks included:\n"
"- one repo affected: move this session there (change_directory; Bash cd is not a move), file it in that repo sidebar group, set a ticket title;\n"
"- several repos with independent changes: stay here as coordinator, start_session per repo with cwd=<repo>, each in its repo group;\n"
"- no repo affected yet (question, cross-repo survey): stay here, nothing to move.\n"
"Skip if this session already did this for the current task."}}))'
