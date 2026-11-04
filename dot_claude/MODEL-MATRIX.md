<!-- verified: 2026-09-11 -->
<!-- OpenAI prices and model IDs verified: 2026-09-23; Codex ChatGPT access checked: 2026-09-23 -->
<!-- Claude candidate IDs and prices verified against vendor docs: 2026-09-23; account access unverified -->
<!-- GPT-6.1 Sol specs/prices and local catalog checked: 2026-10-01; CLI inference access unverified -->
<!-- Claude listed-row pricing and Gemini 3.8 Flash pricing/free-tier terms verified: 2026-10-12; full reliability audit not completed -->
<!-- Claude/Gemini listed pricing and vendor lifecycle review verified: 2026-10-19; no account/model benchmark claims refreshed -->
<!-- GPT-6.1 Terra API ID/pricing and installed Codex catalog verified: 2026-11-02; inference access and comparative reliability unverified -->
# Model Matrix

## Local policy: equal Codex and Claude entry points

Codex and Claude are equal primary agents. Continue implementation in the current
session with its selected model. Use the other agent for independent advice; never
self-delegate. The upstream routing tables below describe model choices and peer
fallbacks, not a requirement to switch from Claude to Codex.
Use `agent-route <class> --agent codex|claude` (or `AGENT_ROUTING_AGENT`);
session environment is detected when available. Claude helper calls use plan mode;
Codex helper calls default to read-only. Keep local Bash/Linux portability.
Upstream verification dates describe source evidence, not tests on this machine.



Shared by Claude Code and Codex. Pick the cheapest row that clears the task's reliability bar, then fall back down the chain when a quota is exhausted. Check with `agent-quota` first; pick with `agent-route <class>`.

## Classes

| Class | Use for | Primary | Fallback 1 | Fallback 2 |
|---|---|---|---|---|
| `cheap` | renames, formatting, boilerplate, log triage, bulk mechanical edits | **Claude Haiku 4.5** | Gemini 3.8 Flash | Codex gpt-6.1-sol |
| `code` | features, bugfixes, refactors — the default | **Codex gpt-6.1-sol** | Codex gpt-6-astra for high-value implementation/review | Claude Sonnet 5 |
| `review` | code/PR review, final review, regression checks | **Codex gpt-6.1-sol** | Codex gpt-6-astra when deeper analysis is needed | Claude Opus 5 |
| `hard` | architecture, tricky debugging, complex security analysis | **Codex gpt-6-astra** | Claude Opus 5 | Codex gpt-6.1-sol |
| `long` | long-running implementation, whole-repo sweeps, long-context reads | **Codex gpt-6.1-sol** | Claude Sonnet 5 | Claude Opus 5 |
| `orchestrate` | coordinating subagents, implementation/review loops, multi-agent decisions | **Codex gpt-6-astra** | Codex gpt-6.1-sol | Claude Opus 5 |

## Cost per 1M tokens (in/out; verification dates above)

| Model | In | Out | Context | Note |
|---|---|---|---|---|
| Codex gpt-6-luna | $0.10 | $0.50 | 1.05M | cheap/high-volume candidate; ChatGPT Codex account returns 400, so not routed |
| Gemini 3.8 Flash | $0.75 | $3.75 | 1M | Antigravity free-tier available; Flash intro pricing through 2026-12-31 |
| Claude Haiku 4.5 | $1.00 | $5.00 | 200K | only non-1M Claude |
| Codex gpt-6.1-terra | $1.00 | $5.00 | 500K local / 1.05M API | optional scoped-fix/visual-reasoning candidate; not automatically routed |
| Codex gpt-6-sol | $2.00 | $10.00 | 1.05M | optional coding candidate; ChatGPT Codex account returns 400, so not routed |
| Codex gpt-6.1-sol | $2.00 | $10.00 | 1.05M | default for implementation/long-running work; user-selected 2026-10-01; app configured |
| Gemini 3.1 Pro | $2.00 | $12.00 | 1M | best $/long-context |
| Claude Sonnet 5 | $2.00 | $10.00 | 1M | current standard price |
| Claude Opus 5.5 | $4.00 | $20.00 | 1M | optional coding/review candidate; account access unverified |
| Claude Opus 5 | $5.00 | $25.00 | 1M | coding/agentic default |
| Codex gpt-6-astra | $10.00 | $50.00 | 1.05M | premium Codex model; excellent for implementation, review, and subagent orchestration, but expensive |
| Claude Fable 5 | $10.00 | $50.00 | 1M | only when Opus 5 is not enough |
| Claude Fable 5.1 | $10.00 | $50.00 | 1M | optional demanding reasoning/long-agent candidate; account access unverified |

Claude Code and Codex CLI bill against subscription quota, not per-token — treat the prices above as a relative-cost ranking and quota-burn proxy.

## Pinned and banned

- **Codex: use `gpt-6.1-sol` for implementation, review, long-running work, and ordinary Codex fallbacks.** User-selected; older Codex fallback retired on 2026-10-12. Keep `gpt-6-astra` for premium hard work, orchestration, and review escalation.
- **Codex: avoid `gpt-5.6-*` for now.** Keep the existing instruction-following regression ban until a fix is verified.
- **Claude: `claude-opus-5` for hard work, `claude-sonnet-5` for volume, `claude-haiku-4-5` for cheap.** Never downgrade tier to save cost without the user asking.
- **Effort is the cheaper lever than model choice.** On Opus 5 / Sonnet 5, `effort: low` for subagents and simple tasks, `high` as the sweet spot, `max` only when correctness beats cost.

## Routing rules

Review default, user-selected 2026-10-09: use `agent-route review` and GPT-6.1 Sol with a read-only sandbox. Review alone does not imply the `hard` class; escalate to Astra for complex security analysis or when Sol misses a concrete check.

1. Run `agent-quota`, then `agent-route <class>`. EXHAUSTED is a cost signal, not a wall -- Codex has a top-up plan and usually still serves, and `agent-route` proves it with a cached `gpt-6.1-sol` one-word probe (15-min TTL).
1b. **Top-up costs real money; quota does not.** When Codex quota is spent, `agent-route` demotes Codex below already-paid options but keeps the selected class's Codex model. Inside quota, `code` and `long` use `gpt-6.1-sol`; `hard` and `orchestrate` intentionally use `gpt-6-astra`.
2. **Capability floor beats per-token price.** Downgrading only pays where the task is genuinely easy. Use Astra for hard implementation, review, and orchestration when one strong run is cheaper than multiple weaker retries.
3. Match the model to the goal, not the budget. Pick the class by what the task actually is; let the router handle cost inside that class. Downgrading the class itself to save money is how a 10-minute task becomes an afternoon.
4. Start at the right class, then escalate only when output fails a real check.
5. Prefer one well-scoped call at high effort over three retries at low effort; retries cost more than the tier upgrade.

Model IDs verified against installed Antigravity and the Gemini API helper on 2026-09-11: `gemini-3.8-flash-low`, `gemini-3.8-flash-medium`, `gemini-3.8-flash-high`, and API model `gemini-3.8-flash` work. the former 3.5 Flash low Antigravity slug is no longer recognized. Gemini remains a flash-tier peer for code/long second opinions; do not route to Gemini Pro until billing/allocation is explicitly confirmed.

OpenAI Standard short-context prices above are per 1M input/output tokens. GPT-6 Sol and Luna are listed in the local cache and official API catalog, but neither is usable through this machine's current ChatGPT-backed Codex CLI. The cache is not proof of account access.

## Optional candidates (not automatic routes)

| Exact model ID | Consider for | Local evidence (2026-09-23 unless noted) |
|---|---|---|
| `gpt-6.1-terra` | scoped fixes with runnable checks, visual reasoning, bounded computer use, writing | 2026-11-02: exact ID in installed Codex 0.162.1 catalog; 500K context, low default effort; inference access and comparative reliability unverified |
| `gpt-6-sol` | preferred alternative for implementation and long-running tasks | cached; CLI returned HTTP 400: unsupported with this ChatGPT account; enable only after access verification |
| `gpt-6-luna` | cheap mechanical work with deterministic validation | cached; same CLI account rejection |
| `claude-opus-5-5` | independent planning, coding, review | vendor-listed; exact ID not found in installed CLI binary; account access unverified |
| `claude-fable-5-1` | difficult reasoning or long-running work where existing choices fall short | exact ID present in installed CLI binary; account access unverified |

Choose a candidate only after an account-access check and a representative task check. Keep existing class routes until reliability is demonstrated; never silently replace the hard/orchestrate model with a cheaper candidate. User-reported Sol/Luna reliability concerns are a reason for caution, not a verified regression claim.

GPT-6.1 Terra, checked 2026-11-02: [vendor model docs](https://developers.openai.com/api/docs/models/gpt-6.1-terra) list Standard short-context prices per 1M tokens: $1 input, $0.05 cached input, $1.25 30-minute cache writes ($2.50 for 12 hours), $5 output. Above 272K input, full-request input/cache rates double and output is 1.5x. API context is 1.05M and max output 128K; the installed Codex catalog advertises 500K context. [Vendor selection guidance](https://developers.openai.com/api/docs/guides/model-selection) calls for matched-task comparisons with Sol. No evidence here establishes equal coding reliability, so Sol and Astra routes remain pinned.

GPT-6.1 Sol, checked 2026-10-01: Standard API prices per 1M tokens are $2 input, $0.10 cached input, $2.50 cache writes, $10 output for prompts up to 272K input tokens. Above 272K, the full request costs $4/$0.20/$5/$15 respectively. API context is 1.05M, max output 128K; API reasoning efforts are low/medium/high/xhigh/max (medium default; none/minimal unsupported). App-specific limits and efforts may differ. User selected this as the default on 2026-10-01 and reports GPT-6 works well; no controlled reliability benchmark or CLI inference test was run. The 5.6 ban remains unchanged. [Official GPT-6.1 Sol documentation](https://developers.openai.com/api/docs/models/gpt-6.1-sol).

Sources for newly checked IDs/prices: [OpenAI pricing](https://developers.openai.com/api/docs/pricing), [OpenAI models](https://developers.openai.com/api/docs/models), [Claude models](https://platform.claude.com/docs/en/models/overview), [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing). These are API prices, not measured subscription quota multipliers; older rows and reliability claims were not re-verified.

2026-10-12 refresh: existing Claude price rows are unchanged. [Google pricing](https://ai.google.dev/gemini-api/docs/pricing) confirms Gemini 3.8 Flash API free-tier input/output and paid $0.75/$3.75 through 2026-12-31, then $1.50/$7.50 from 2027-01-01. API free-tier content may be used to improve Google's products; do not assume Antigravity has identical terms or account limits. Account quotas, current regression reports, and end-to-end model reliability were not re-verified; retain current routes and the original full-verification datestamp.

## Cost tiers the router enforces

2026-10-19 lifecycle review: current routed Claude models remain active in the [vendor lifecycle table](https://platform.claude.com/docs/en/about-claude/model-deprecations); listed Claude and Gemini Flash prices are unchanged. [Google release notes](https://ai.google.dev/gemini-api/docs/changelog) state that deprecated Gemini 3.7 Flash requests now route to 3.8 Flash, so the helper no longer retries the same backend under that old ID. Gemini 4 Argon has no API free tier and is not adopted. No replacement earned a reliability promotion; current routes and bans stay in place. Independent regression coverage and representative local benchmarks remain unverified, so the original full-verification datestamp is retained.

| Tier | Meaning | Members |
|---|---|---|
| `paid-for` | subscription already bought; marginal cost zero until exhausted | Claude Code, Codex **inside quota**, Gemini |
| `COSTS $` | real per-token spend | Codex **on top-up** — always last within a class; Astra is the expensive premium Codex route |
