---
name: gpt-toolset
description: Set up, assess, or operate a reusable AI-assisted software-development toolset. Use when asked to introduce or maintain project AGENTS.md policy, shared skills, MCP-based code intelligence, Context7 documentation lookup, fast search, task-output management, or the workflow described in the GPT Toolset guide.
---

# GPT Toolset

Use this workflow to turn the toolset guide into a safe, project-specific setup.

## Start with project policy

1. Read the nearest `AGENTS.md` before making repository changes.
2. Create or update the project-root `AGENTS.md` only with concise repository commands, safety boundaries, and verification requirements.
3. Keep secrets, credentials, machine-specific paths, and model choices out of committed policy.

## Choose tools deliberately

Read [the tool reference](references/toolset-guide.md) when identifying components or installation candidates. Do not install every listed tool by default. First establish the use case, available package manager, license, authentication requirements, and compatibility with the active Codex environment.

Prefer this order when investigating a repository:

1. Existing project instructions and native tooling.
2. Code intelligence (Codegraph or Codebase-Memory-MCP) when it is installed and indexed.
3. Fast filesystem search to scope the task.
4. Current library documentation through Context7.
5. External research only when needed.

## Configure MCP safely

Treat MCP configuration as environment-specific. Before adding a server:

1. Confirm its command is installed with `command -v`.
2. Check the official documentation for current package name, launch arguments, permissions, pricing, and authentication.
3. Configure the server through the active Codex client configuration rather than copying another client’s `.mcp.json` blindly.
4. Restart or reload the client and run a small read-only smoke test.

## Validate changes

Run the project’s native formatting, lint, typecheck, and tests before handoff. Re-index code-intelligence services after structural or contract changes. Record only portable commands in repository documentation.
