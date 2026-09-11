#!/usr/bin/env bash
# Stop hook: verify that a turn triggered by the routing gate actually emitted a
# `route:` decision line. Nudges once, never twice — a blocked turn that still
# refuses is recorded and let go, so this can never become a loop.
exec python3 "$HOME/.claude/hooks/route_enforce.py"
