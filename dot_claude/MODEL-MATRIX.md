<!-- verified: 2026-09-11 -->
# Model Matrix

Shared by Claude Code and Codex. Pick the cheapest row that clears the task's reliability bar, then fall back down the chain when a quota is exhausted. Check with `agent-quota` first; pick with `agent-route <class>`.

## Classes

| Class | Use for | Primary | Fallback 1 | Fallback 2 |
|---|---|---|---|---|
| `cheap` | renames, formatting, boilerplate, log triage, bulk mechanical edits | **Claude Haiku 4.5** | Gemini 3.8 Flash | local gpt-oss:20b (free, when installed) |
| `code` | features, bugfixes, refactors — the default | **Codex gpt-5.5** | Codex gpt-6-astra for high-value implementation/review | Claude Sonnet 5 |
| `hard` | architecture, tricky debugging, security, final review | **Codex gpt-6-astra** | Claude Opus 5 | Codex gpt-5.5 |
| `long` | whole-repo sweeps, huge logs, long-context reads | **Claude Sonnet 5** | Claude Opus 5 | Gemini 3.8 Flash |
| `orchestrate` | coordinating subagents, implementation/review loops, multi-agent decisions | **Codex gpt-6-astra** | Codex gpt-5.5 | Claude Opus 5 |

## Cost per 1M tokens (in/out, Sep 2026)

| Model | In | Out | Context | Note |
|---|---|---|---|---|
| local gpt-oss:20b | $0 | $0 | 131K | free, no quota; only local model both harnesses can drive |
| Gemini 3.8 Flash | $0.75 | $3.75 | 1M | Antigravity free-tier available; Flash intro pricing through 2026-12-31 |
| Claude Haiku 4.5 | $1.00 | $5.00 | 200K | only non-1M Claude |
| Gemini 3.1 Pro | $2.00 | $12.00 | 1M | best $/long-context |
| Claude Sonnet 5 | $3.00 | $15.00 | 1M | $2/$10 intro through 2026-08-31 |
| Claude Opus 5 | $5.00 | $25.00 | 1M | coding/agentic default |
| Codex gpt-6-astra | $10.00 | $50.00 | 1.05M | premium Codex model; excellent for implementation, review, and subagent orchestration, but expensive |
| Claude Fable 5 | $10.00 | $50.00 | 1M | only when Opus 5 is not enough |

Claude Code and Codex CLI bill against subscription quota, not per-token — treat the prices above as a relative-cost ranking and quota-burn proxy.

## Pinned and banned

- **Codex: keep `gpt-5.5` as the everyday default.** `gpt-6-astra` is the premium Codex escalation for hard implementation, review, and subagent orchestration. It is excellent when correctness and agent control matter, but it burns allowance faster and is expensive on top-up/API pricing.
- **Codex: avoid `gpt-5.6-*` for now.** `gpt-5.6-*` (sol/terra/luna) is a documented regression — weaker instruction adherence and execution than 5.5 despite better planning; every effort-matched 5.6 config scored below 5.5 on a 711-task eval.
- **Claude: `claude-opus-5` for hard work, `claude-sonnet-5` for volume, `claude-haiku-4-5` for cheap.** Never downgrade tier to save cost without the user asking.
- **Effort is the cheaper lever than model choice.** On Opus 5 / Sonnet 5, `effort: low` for subagents and simple tasks, `high` as the sweet spot, `max` only when correctness beats cost.

## Routing rules

1. Run `agent-quota`, then `agent-route <class>`. EXHAUSTED is a cost signal, not a wall -- Codex has a top-up plan and usually still serves, and `agent-route` proves it with a cached `gpt-5.5` one-word probe (15-min TTL).
1b. **Top-up costs real money; quota does not.** When Codex quota is spent, `agent-route` demotes Codex below every free or already-paid option but keeps the selected class's Codex model. Inside quota, `code` stays on `gpt-5.5`; `hard` and `orchestrate` intentionally use `gpt-6-astra`.
2. **Capability floor beats per-token price.** Downgrading only pays where the task is genuinely easy. Use Astra for hard implementation, review, and orchestration when one strong run is cheaper than multiple weaker retries.
3. Match the model to the goal, not the budget. Pick the class by what the task actually is; let the router handle cost inside that class. Downgrading the class itself to save money is how a 10-minute task becomes an afternoon.
4. Start at the right class, then escalate only when output fails a real check.
5. Local models are low-trust advisors — never final verification, never autonomous edits.
6. Prefer one well-scoped call at high effort over three retries at low effort; retries cost more than the tier upgrade.

Model IDs verified against installed Antigravity and the Gemini API helper on 2026-09-11: `gemini-3.8-flash-low`, `gemini-3.8-flash-medium`, `gemini-3.8-flash-high`, and API model `gemini-3.8-flash` work. the former 3.5 Flash low Antigravity slug is no longer recognized. Gemini remains a flash-tier peer for code/long second opinions; do not route to Gemini Pro until billing/allocation is explicitly confirmed.

## Cost tiers the router enforces

| Tier | Meaning | Members |
|---|---|---|
| `free` | no quota, no money | local Ollama (gpt-oss:20b) |
| `paid-for` | subscription already bought; marginal cost zero until exhausted | Claude Code, Codex **inside quota**, Gemini |
| `COSTS $` | real per-token spend | Codex **on top-up** — always last within a class; Astra is the expensive premium Codex route |
