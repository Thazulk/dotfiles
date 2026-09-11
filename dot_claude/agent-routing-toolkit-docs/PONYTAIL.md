# Ponytail

Use Ponytail to reduce over-engineering and keep code changes minimal.

Use it when:
- the task is overbuilt or drifting into unnecessary abstraction
- a stdlib, native, or already-installed solution likely exists
- brevity in generated code matters

Do not overuse it:
- not always-on
- not a reason to skip explicit product requirements
- not a reason to argue that the requested feature should not exist
- not enough on its own for auth, security, data integrity, or other correctness-sensitive work

Guardrails:
- treat Ponytail as a simplification lens, not as the final judge
- if the user asked for a concrete behavior, implement that behavior first
- if Ponytail suggests skipping the request, only do that when the requirement is clearly speculative and not explicitly required
- always verify the final code still type-checks and matches the asked behavior
- if the area is sensitive, prefer a correct boring solution over a clever small one

Working rule:
- use Ponytail for code shape, not for requirement negotiation
- use minimal code, but do not simplify away correctness

Reference:
- https://github.com/DietrichGebert/ponytail
