"""Offline updater regression: all user plugins, declared tools, failure propagation."""
import os
from pathlib import Path
import subprocess
import tempfile
repo = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory() as d:
    root = Path(d)
    log = root / "calls"
    fake = root / "bin"
    fake.mkdir()
    for name in ("codex", "claude", "mise", "bootstrap-ai-toolstack"):
        tool = fake / name
        tool.write_text("#!/bin/bash\nprintf '%s %s\\n' \"$(basename \"$0\")\" \"$*\" >> \"$CALLS\"\n" +
            ("if [[ $1 == plugin && $2 == list && $3 == --json ]]; then printf '%s' '[{\"id\":\"custom@vendor\",\"scope\":\"user\",\"enabled\":false},{\"id\":\"project@vendor\",\"scope\":\"project\"}]'; fi\nif [[ $1 == plugin && $2 == update ]]; then exit \"${FAIL_UPDATE:-0}\"; fi\n" if name == "claude" else ""))
        tool.chmod(0o755)
    source = (repo / "dot_local/bin/executable_update-ai-toolstack").read_text()
    # Isolate fake binaries from the updater's user PATH prefix.
    source = source.replace('export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"', '')
    script = root / "update"
    script.write_text(source)
    env = os.environ | {"PATH": str(fake) + ":/usr/bin:/bin:/opt/homebrew/bin", "CALLS": str(log)}
    subprocess.run(["bash", str(script)], env=env, check=True, capture_output=True)
    calls = log.read_text()
    assert "mise install" in calls
    assert "claude plugin update custom@vendor --scope user --json" in calls
    assert "update project@vendor" not in calls
    assert subprocess.run(["bash", str(script)], env=env | {"FAIL_UPDATE": "1"}, capture_output=True).returncode == 1
print("ok: updater covers declared tools, every user plugin, and errors")
