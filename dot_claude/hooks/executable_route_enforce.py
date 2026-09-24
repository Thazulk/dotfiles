#!/usr/bin/env python3
"""Stop-hook half of the routing gate: enforce + record the `route:` decision.

Pairs with route-gate.sh (UserPromptSubmit). The gate logs a `matched` event and
demands a route line; this checks the turn actually produced one. Runs as a Stop
hook in both Claude Code and Codex: both send session_id/transcript_path, both
honour {"decision": "block", "reason": ...}.

ponytail: nudges at most once per matched prompt. Never blocks twice, so a
ponytail: misfire costs one extra turn, not a stuck session.
"""
import json, os, re, sys, time, pathlib

LOG = pathlib.Path(os.environ.get("ROUTE_LOG", os.path.expanduser("~/.claude/route-log.jsonl")))
TMP = pathlib.Path(os.environ.get("TMPDIR", "/tmp"))
ROUTE_RE = re.compile(r"^\s*route:\s*(solo|codex|claude|gemini|ollama)\b[ \t]*(?:reason=(.*))?$",
                      re.IGNORECASE | re.MULTILINE)


def log(**kw):
    kw.setdefault("ts", time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
    try:
        LOG.parent.mkdir(parents=True, exist_ok=True)
        with LOG.open("a") as f:
            f.write(json.dumps(kw) + "\n")
    except OSError:
        pass


TAIL_BYTES = 512 * 1024


def pending_match(session):
    """True if this session's most recent gate event is an unanswered `matched`.

    Reads only the tail: this runs on every Stop, and the log grows forever.
    """
    last = None
    try:
        size = LOG.stat().st_size
        with LOG.open("rb") as f:
            if size > TAIL_BYTES:
                f.seek(size - TAIL_BYTES)
                f.readline()          # discard the partial line
            for raw in f:
                try:
                    d = json.loads(raw)
                except ValueError:
                    continue
                if d.get("session") == session and d.get("event") in (
                        "matched", "route", "missing_route"):
                    last = d.get("event")
    except OSError:
        return False
    return last == "matched"


def last_turn_text(path):
    """Assistant text emitted since the most recent real user message.

    No fixed line window: a tool-heavy turn can run to thousands of transcript
    records, and a route line that scrolled out of a fixed tail would be reported
    as missing on a turn that actually complied. Walks back until the user message
    that opened the turn, with a byte cap only as a runaway guard.
    """
    try:
        raw = pathlib.Path(path).read_bytes()
    except OSError:
        return None
    if len(raw) > 40 * 1024 * 1024:      # guard, not a window: keep the tail
        raw = raw[-40 * 1024 * 1024:]
    lines = raw.decode("utf-8", "ignore").splitlines()
    out, seen_user = [], False
    for line in reversed(lines):
        try:
            d = json.loads(line)
        except ValueError:
            continue
        if not isinstance(d, dict):
            continue
        # Codex rollout: event_msg/user_message opens the turn; assistant text is
        # a response_item message with output_text parts.
        payload = d.get("payload")
        if isinstance(payload, dict):
            if d.get("type") == "event_msg" and payload.get("type") == "user_message":
                seen_user = True
                break
            if (d.get("type") == "response_item" and payload.get("type") == "message"
                    and payload.get("role") == "assistant"
                    and isinstance(payload.get("content"), list)):
                for c in payload["content"]:
                    if isinstance(c, dict) and c.get("type") == "output_text":
                        out.append(c.get("text", ""))
            continue
        m = d.get("message")
        if not isinstance(m, dict):
            continue
        role = m.get("role")
        if role == "user":
            # Tool results are user-role too; a real user turn ends the window.
            content = m.get("content")
            is_tool_result = isinstance(content, list) and any(
                isinstance(c, dict) and c.get("type") == "tool_result" for c in content)
            if not is_tool_result:
                seen_user = True
                break
        elif role == "assistant" and isinstance(m.get("content"), list):
            for c in m["content"]:
                if isinstance(c, dict) and c.get("type") == "text":
                    out.append(c.get("text", ""))
    return "\n".join(reversed(out)) if (out or seen_user) else None


def main():
    try:
        inp = json.load(sys.stdin)
    except ValueError:
        return 0
    session = inp.get("session_id") or ""
    if not session or not pending_match(session):
        return 0

    text = last_turn_text(inp.get("transcript_path") or "")
    last = inp.get("last_assistant_message")
    if isinstance(last, str) and last:
        text = last if text is None else text + "\n" + last
    if text is None:
        # No transcript to inspect — record and stay out of the way.
        log(session=session, event="missing_route", note="transcript unavailable")
        return 0

    m = ROUTE_RE.search(text)
    if m:
        log(session=session, event="route", target=m.group(1).lower(),
            reason=(m.group(2) or "").strip()[:200])
        return 0

    safe = re.sub(r"[^A-Za-z0-9._-]", "_", session)[:64]
    sentinel = TMP / f"route-gate-nudged-{safe}"
    if sentinel.exists():
        log(session=session, event="missing_route", note="nudged already, letting go")
        return 0
    try:
        sentinel.touch()
    except OSError:
        pass
    json.dump({
        "decision": "block",
        "reason": ("Routing gate: this turn matched a delegatable prompt but emitted no routing "
                   "decision. Add the line `route: <solo|codex|claude|gemini|ollama> reason=<short>` "
                   "and act on it. `solo` is fine when justified — state the reason. "
                   "This nudge fires once; it will not repeat."),
    }, sys.stdout)
    return 0


if __name__ == "__main__":
    sys.exit(main())
