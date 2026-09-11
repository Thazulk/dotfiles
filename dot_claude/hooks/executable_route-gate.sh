#!/usr/bin/env bash
# UserPromptSubmit: when a prompt looks delegatable, require a machine-parseable
# routing decision before work starts, and log the match for the audit script.
# Silent on non-matching prompts, so ordinary turns cost nothing.
# ponytail: keyword match, not a classifier. Only upgrade if route-audit shows
# ponytail: the detector is the bottleneck (low match rate on real delegatable work).
set -uo pipefail

LOG="${ROUTE_LOG:-$HOME/.claude/route-log.jsonl}"
mkdir -p "$(dirname "$LOG")" 2>/dev/null
in=$(cat)
# python3 instead of jq: a missing jq made this exit silently, i.e. the gate
# disappeared with no signal. python3 is expected in this setup.
read_json() { printf '%s' "$in" | python3 -c "
import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
print(d.get(sys.argv[1]) or '', end='')" "$1"; }
p=$(read_json prompt | tr '[:upper:]' '[:lower:]')
[ -z "$p" ] && exit 0

pat='review|audit|átnéz|atnez|plan|terv|design|architect|brainstorm|refactor|migrat|migrál'
pat+='|sweep|all repos|cross-repo|minden repo|összes|osszes|where is|hol van|find all|map the'
pat+='|docs|dokument|readme|second opinion|másik vélemény|masik velemeny|independent|test scaffold'
pat+='|which model|melyik model|does .* exist|sanity check'
# HU/EN natural phrasings the keyword list missed on real prompts (verified 2026-08-26:
# "nezd meg lehet-e javitani a setupon" did not fire). Deliberately excludes bare
# fix/javit -- most of those are tiny solo edits and the gate would be pure friction.
pat+='|nézd meg|nezd meg|vizsgál|vizsgal|elemez|ellenőriz|ellenoriz|hasonlít|hasonlit|optimaliz'
pat+='|compare|investigate|trace|why does|check if|improve|optimi[sz]e|setup'
echo "$p" | grep -qE "$pat" || exit 0

# Sanitized: session_id lands in a filesystem path below.
sid=$(read_json session_id | tr -c 'A-Za-z0-9._-' '_')
# Denominator for the audit: every prompt the detector fired on.
# One short line, single append: O_APPEND makes this atomic enough that a lock
# would be pure ceremony for a single-developer machine.
SID="$sid" HEAD="$(printf '%s' "$p" | head -c 120)" python3 -c "
import json,os,time
print(json.dumps({'ts':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),
                  'session':os.environ['SID'],'event':'matched',
                  'prompt_head':os.environ['HEAD']}))" >> "$LOG" 2>/dev/null

# Clear any stale enforcement marker from the previous turn in this session.
rm -f "${TMPDIR:-/tmp}/route-gate-nudged-$sid" 2>/dev/null

jq -n '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:
"ROUTING GATE — this prompt matched a delegatable shape. You MUST emit a routing decision line before doing the work. Not a suggestion: no route line, no work.\n\nFormat, verbatim, on its own line:\n  route: <solo|codex|gemini|ollama> reason=<short reason>\n\nPick from ~/.claude/CLAUDE.md (Cross-Agent Routing + Quota Routing):\n- codex → fast execution, small diffs, mechanical fixes, focused implementation, second-pass review of your own patch\n- gemini → cross-repo discovery, large-context reads, architecture comparison, migration inventory, docs/test scaffolds, \"where does this concept appear\"\n- ollama → cheap sanity check, bulk mechanical pass, doc drafts, summarizing noisy evidence (free, no quota; low-trust — verify locally)\n- solo → tiny edits, tightly sequential work, same-file edits, secret/security reasoning, anything a local command answers faster, or delegation overhead > 5 min\n\n`solo` is a legitimate and often correct choice — but it must be stated with its reason, not defaulted into. Use `agent-route <cheap|code|hard|long>` if the pick is not obvious, `agent-quota` before a long paid run.\n\nAfter delegating, treat the peer answer as advice: verify with a local command before acting on it. When you route a review, hand over the diff WITHOUT saying who wrote it — anonymity is what makes the second opinion worth having."}}'
