"""Run with python3 tests/check_agent_setup.py; no accounts or network required."""
import json
import os
from pathlib import Path
import runpy
import subprocess
import tempfile
import tomllib

repo = Path(__file__).resolve().parents[1]
merge = runpy.run_path(str(repo / "dot_local/scripts/executable_configure-agent-defaults"))["merge"]
defaults = json.loads((repo / "dot_config/agents/codex-defaults.json").read_text())
model_matrix = (repo / "dot_claude/MODEL-MATRIX.md").read_text()
assert "agent-route <class>" in model_matrix
assert "gpt-5.5" in model_matrix and "gpt-6-astra" in model_matrix
manifest = tomllib.loads((repo / "dot_config/mise/config.toml").read_text())
for tool in ["npm:pnpm", "ast-grep", "rtk", "npm:@upstash/context7-mcp", "npm:codebase-memory-mcp", "npm:@suatkocar/codegraph", "npm:@playwright/mcp", "npm:nx-mcp", "npm:codeburn", "pipx:ddgs", "pipx:repowise", "pipx:headroom-ai"]:
    assert tool in manifest["tools"]
assert manifest["tools"]["pipx:repowise"]["uvx_args"] == "--python 3.13"
assert "mcp<2" in manifest["tools"]["pipx:ddgs"]["uvx_args"]
for file in ["executable_bootstrap-ai-toolstack", "executable_bootstrap-ai-toolstack.ps1"]:
    bootstrap = (repo / "dot_local/scripts" / file).read_text()
    assert "npm install -g" not in bootstrap and "uv tool install" not in bootstrap
assert "TOOLSTACK_ENABLE_FFF" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack").read_text()
assert "CLOCKIFY_API_KEY" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack").read_text()
assert "nx-mcp" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack").read_text()
assert "nx-mcp" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack.ps1").read_text()
assert "playwright-mcp" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack").read_text()
assert "have brew" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack").read_text()
assert "mcp-server" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack").read_text()
assert "Claude Desktop MCP" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack").read_text()
assert "superpowers@openai-curated" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack").read_text()
assert "superpowers@claude-plugins-official" in (repo / "dot_local/scripts/executable_bootstrap-ai-toolstack.ps1").read_text()
for file in [
    "agent-ask-codex",
    "agent-ask-claude",
    "agent-ask-gemini",
    "agent-health",
    "agent-quota",
    "agent-route",
    "matrix-evidence",
]:
    assert (repo / "dot_local/bin" / f"executable_{file}").exists()
for file in [
    "AGENT-ROUTES.md",
    "CAVEMAN.md",
    "CODEBURN.md",
    "PONYTAIL.md",
    "REPOWISE.md",
    "RTK.md",
    "SETUP-PROMPTS.md",
    "WHOLE-SETUP.md",
]:
    assert (repo / "dot_claude/agent-routing-toolkit-docs" / file).exists()
for file in [
    "executable_cbm-code-discovery-gate",
    "executable_cbm-session-reminder",
    "executable_route-enforce.sh",
    "executable_route-gate.sh",
    "executable_route_enforce.py",
]:
    assert (repo / "dot_claude/hooks" / file).exists()
source = 'model = "old"\n# preserve me\n[features]\nfoo = true\n[mcp_servers.private]\ncommand = "private-tool"\n'
result = merge(source, defaults)
assert tomllib.loads(result) == tomllib.loads(source) | defaults
assert merge(result, defaults) == result
assert "# preserve me" in result
assert tomllib.loads(merge("", defaults)) == defaults
try:
    merge('model = """\nold\n"""\n', defaults)
except (ValueError, tomllib.TOMLDecodeError):
    pass
else:
    raise AssertionError("Complex TOML must not be silently damaged")

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    brief = root / "brief.md"
    brief.write_text("Goal: review only. Files: app.py. Failures: none. Output: findings.")
    fake = root / "claude"
    fake.write_text('#!/usr/bin/env python3\nimport json,os,sys\nif sys.argv[1:3] == ["auth","status"]: sys.exit(int(os.getenv("FAIL_AUTH","0")))\nprint(json.dumps({"args":sys.argv[1:],"cwd":os.getcwd(),"brief":sys.stdin.read()}))\n')
    fake.chmod(0o755)
    quota = root / "agent-quota"
    quota.write_text('#!/bin/sh\nprintf "%s\\n" "codex   : 5h 1%" "claude  : ok" "gemini  : ok"\n')
    quota.chmod(0o755)
    env = os.environ | {"PATH": str(root) + os.pathsep + os.environ["PATH"]}
    command = ["zsh", str(repo / "dot_local/bin/executable_agent-ask-claude"), str(brief)]
    response = subprocess.run(command, env=env, capture_output=True, text=True, check=True)
    data = json.loads(response.stdout)
    assert brief.read_text() in data["args"]
    assert "-p" in data["args"] and "--permission-mode" in data["args"]
    assert subprocess.run(["zsh", str(repo / "dot_local/bin/executable_agent-ask-claude")], env=env, capture_output=True).returncode == 2
    route = ["python3", str(repo / "dot_local/bin/executable_agent-route"), "code"]
    routed = subprocess.run(route, env=env, capture_output=True, text=True, check=True)
    assert "class: code" in routed.stdout and "Codex gpt-5.5" in routed.stdout
    bad_route = subprocess.run(["python3", str(repo / "dot_local/bin/executable_agent-route")], env=env, capture_output=True)
    assert bad_route.returncode == 1
    npm = root / "mise"
    npm.write_text('#!/bin/sh\nprintf "%s\\n" "$FAKE_NPM_ROOT"\n')
    npm.chmod(0o755)
    launcher = ["bash", str(repo / "dot_local/bin/executable_codegraph"), "--version"]
    env["FAKE_NPM_ROOT"] = str(root / "packages")
    assert subprocess.run(launcher, env=env, capture_output=True).returncode == 1
    native = Path(env["FAKE_NPM_ROOT"]) / "lib/node_modules/@suatkocar/codegraph/bin/codegraph-native"
    native.parent.mkdir(parents=True)
    native.write_text('#!/bin/sh\nprintf "%s\\n" "$1"\n')
    native.chmod(0o755)
    assert subprocess.check_output(launcher, env=env, text=True).strip() == "--version"

for file in ["executable_agent-route", "executable_agent-quota", "executable_matrix-evidence"]:
    subprocess.run(["python3", "-m", "py_compile", str(repo / "dot_local/bin" / file)], check=True)
subprocess.run(["python3", "-m", "py_compile", str(repo / "dot_claude/hooks/executable_route_enforce.py")], check=True)
for file in ["executable_agent-ask-codex", "executable_agent-ask-claude", "executable_agent-ask-gemini", "executable_agent-health"]:
    subprocess.run(["zsh", "-n", str(repo / "dot_local/bin" / file)], check=True)
for file in ["executable_route-gate.sh", "executable_route-enforce.sh", "executable_cbm-code-discovery-gate", "executable_cbm-session-reminder"]:
    subprocess.run(["bash", "-n", str(repo / "dot_claude/hooks" / file)], check=True)
print("ok: config preservation/idempotence and agent-routing-toolkit checks")
