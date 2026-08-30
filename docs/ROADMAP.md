# JtechSH Roadmap

Each version must fully work before development moves to the next one.

| Version | Focus | Adds |
|---|---|---|
| **0.1** ✅ | Shell foundation | prompt, builtins, history, Linux passthrough, help, version, config |
| 0.2 | Observability | SQLite audit db, command logging, `doctor`, better error handling |
| 0.3 | Google | `gogcli` integration, `google gmail/calendar/drive/...` |
| 0.4 | Automation | automation engine, cron/systemd integration, `automation status/history` |
| 0.5 | Agents | OpenClaw integration, `agent` management, workspace management, job execution |
| 0.6 | Triage | `triage` repository as source of truth, email + Twitter triage, expanded audit |
| 0.7 | AI | AI command generation, risk analysis, explicit approval flow |
| 0.8 | Sandbox | Docker execution, resource limits, security policies |
| 0.9 | Plugins | plugin system, Go components for performance-critical pieces |
| 1.0 | Platform | Linux shell + Google automation + AI + OpenClaw + scheduler + security + sandbox + audit + plugins, all working together |

## Non-negotiable design principle

OpenClaw, `gogcli`, Docker, and Firecracker are **integrations**, reached
through adapters in `src/google/`, `src/openclaw/`, and `src/security/`.
JtechSH's core (`src/core/`) never imports or depends on them directly. If
any integration is uninstalled, the core shell keeps working.

## Security invariants (apply from v0.6 onward)

- Security-classified email is **never** auto-archived.
- Human email is **never** auto-archived unless explicitly allowed by a rule.
- Unknown messages are observed, not acted on.
- Every mutating action produces an audit record (time, action, source,
  rule, target, verification result).
- Dangerous shell commands (e.g. `rm -rf /`, `mkfs`, `dd if=/dev/zero`,
  recursive `chmod 777` on `/`) require explicit confirmation once the
  security layer (v0.7+) lands.
