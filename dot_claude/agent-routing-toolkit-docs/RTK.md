# RTK

Use RTK for shell commands when compact command output helps preserve context.

Preferred pattern:
- use normal shell commands if RTK hooks already rewrite them for the active agent
- otherwise call `rtk <command>` explicitly

Useful checks:
- `rtk --version`
- `rtk gain`
- `rtk telemetry status`

If output fidelity matters more than compression, use normal shell commands or `rtk proxy <command>`.
