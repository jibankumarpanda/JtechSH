# JtechSH — Secure Intelligent Shell & Automation Platform

JtechSH is a custom shell environment for Ubuntu/Linux/WSL2 that starts as a
thin, friendly layer over Bash and grows — in disciplined stages — into a
full automation platform: Google Workspace automation (via `gogcli`), agent
orchestration (via OpenClaw), scheduling, security controls, auditing, and
plugins.

JtechSH is the main project. Everything else (`gogcli`, OpenClaw, Docker,
Firecracker, SQLite) is an **integration**, not a dependency. If any one of
them is removed, JtechSH still works as a normal shell.

## Status: v0.1.0 — Foundation

This is the first milestone: the shell itself. No automation, no Google
integration, no OpenClaw yet — those arrive in later versions (see
[docs/ROADMAP.md](docs/ROADMAP.md)).

What works today:

- Interactive shell with banner + `jtech>` prompt
- Builtins: `help`, `version`, `history`, `clear`, `exit` / `quit`
- Native Linux/Bash command passthrough (`ls`, `mkdir`, `cp`, `chmod`, pipes,
  redirects, globs, etc. all work as expected)
- In-process `cd` (directory changes persist across commands)
- Session + on-disk command history
- Config layering: repo defaults (`config/jtechsh.conf`) → user overrides
  (`~/.config/jtechsh/config`)
- Reserved (not-yet-implemented) top-level commands — `google`, `automation`,
  `agent`, `schedule`, `security`, `audit`, `sandbox`, `config`, `plugin`,
  `update`, `doctor`, `ai`, `run`, `script`, `process`, `service` — return a
  clear "planned but not yet implemented" message instead of falling through
  to Bash and erroring confusingly.

## Running it

```bash
./bin/jtechsh
```

```text
╭──────────────────────────────╮
│            JtechSH           │
│  Intelligent Linux Shell     │
│            v0.1.0            │
╰──────────────────────────────╯

Type 'help' for available commands, 'exit' to quit.
jtech> help
jtech> version
jtech> pwd
jtech> mkdir test
jtech> cd test
```

## Project layout

```text
JtechSH/
├── bin/jtechsh          Entry point
├── src/core/            Shell loop, dispatcher, builtins, config (v0.1)
├── src/commands/        Reserved for future built-in command modules
├── src/automation/      Reserved: automation engine            (v0.4)
├── src/google/          Reserved: gogcli adapter                (v0.3)
├── src/openclaw/        Reserved: OpenClaw agent adapter         (v0.5)
├── src/security/        Reserved: risk detection / approvals    (v0.7)
├── src/scheduler/       Reserved: cron/systemd integration      (v0.4)
├── src/audit/           Reserved: SQLite audit layer            (v0.2)
├── config/jtechsh.conf  Tracked defaults (no secrets, ever)
├── scripts/             Dev/maintenance scripts
├── tests/               Test suite
├── docs/                ROADMAP.md, ARCHITECTURE.md, etc.
└── plugins/             Reserved: plugin system                 (v0.9)
```

## Design principles

1. **JtechSH is not a wrapper around OpenClaw.** OpenClaw, `gogcli`, Docker,
   and Firecracker are integrations behind adapters. Remove any of them and
   the core shell still runs.
2. **One stage at a time.** Each version in the roadmap must fully work
   before the next one starts. See [docs/ROADMAP.md](docs/ROADMAP.md).
3. **No secrets in git.** API keys, OAuth tokens, and credentials never live
   in this repository, in `config/jtechsh.conf`, in scripts, or in logs —
   only in environment variables, the OS keyring, or encrypted storage under
   `~/.config/jtechsh/credentials` (added in a later version).
4. **Every mutation is auditable.** Once the audit layer lands (v0.2), any
   action that changes state (files, emails, scheduled jobs) produces an
   audit record.

## Configuration

- Repo defaults: `config/jtechsh.conf` (tracked, safe values only)
- User overrides: `~/.config/jtechsh/config` (created automatically on first
  run, gitignored, safe to edit)

## License

See [LICENSE](LICENSE).
