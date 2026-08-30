# JtechSH — Architecture

## Overview

JtechSH is a custom interactive shell and automation platform built in Bash 5+,
designed to run on Ubuntu / WSL2. It starts as a thin, friendly layer over Bash
and grows — in disciplined stages — into a full automation platform.

## Core Philosophy

**JtechSH is not a wrapper.** `gog` (gogcli), OpenClaw, Docker, SQLite, and
Firecracker are *integrations* reached through adapter modules. Remove any of
them and the core shell keeps working perfectly.

## Directory Structure

```
JtechSH/
├── bin/
│   └── jtechsh               ← entry point (executable)
├── src/
│   ├── core/
│   │   ├── config.sh         ← version metadata, dir setup, config loading
│   │   ├── builtins.sh       ← shell built-ins: help, version, history, clear, exit
│   │   ├── dispatcher.sh     ← routes every typed command
│   │   └── shell.sh          ← banner + interactive read-eval loop
│   ├── commands/             ← future command modules (v0.2+)
│   ├── audit/                ← SQLite audit layer        (v0.2)
│   ├── google/               ← gog/gogcli adapter        (v0.3)
│   ├── automation/           ← automation engine         (v0.4)
│   ├── scheduler/            ← cron/systemd integration  (v0.4)
│   ├── openclaw/             ← OpenClaw agent adapter    (v0.5)
│   ├── triage/               ← conference/email triage   (v0.6)
│   ├── ai/                   ← AI command generation     (v0.7)
│   └── security/             ← risk detection, approvals (v0.8)
├── config/
│   └── jtechsh.conf          ← tracked safe defaults (NO secrets EVER)
├── docs/
│   ├── ROADMAP.md
│   └── ARCHITECTURE.md       ← this file
├── plugins/                  ← plugin system             (v0.9)
├── scripts/                  ← dev/maintenance scripts
├── tests/                    ← test suite
├── .gitignore
└── README.md
```

## Source Layering

```
bin/jtechsh
  └─ src/core/config.sh       (version, dirs, config load)
  └─ src/core/builtins.sh     (help, version, history, clear, exit)
  └─ src/core/dispatcher.sh   (routing logic)
  └─ src/core/shell.sh        (banner, REPL loop, main entry)
```

Each file is sourced in order. Later adapters (google, openclaw, etc.) will be
sourced by `bin/jtechsh` only when their version is active — never by
`src/core/`.

## Dispatch Priority

Every line typed at the prompt flows through `jtechsh::dispatch` in this order:

1. **`cd`** — must run in-process so directory changes persist.
2. **JtechSH builtins** — `help`, `version`, `history`, `clear`, `exit`, `quit`.
3. **Reserved category keywords** — print a friendly stub message, return 127.
   Currently reserved: `google`, `automation`, `agent`, `schedule`, `security`,
   `audit`, `sandbox`, `config`, `plugin`, `update`, `doctor`, `ai`, `run`,
   `script`, `process`, `service`, `triage`.
4. **Linux passthrough** — `bash -c "$line"`: pipes, globs, redirects all work.

## Configuration Layering

```
config/jtechsh.conf           (tracked repo defaults — no secrets)
      ↓  overridden by
~/.config/jtechsh/config      (user overrides — gitignored, auto-created)
```

## Function Naming Convention

All shell functions use the namespace pattern:

```
jtechsh::<module>::<action>
```

Examples:
- `jtechsh::builtin::help`
- `jtechsh::dispatch::native`
- `jtechsh::google::gmail::search`   (future v0.3)
- `jtechsh::triage::run`             (future v0.6)

## Secrets Policy

No secrets ever go in git. Secrets live only in:
- Environment variables
- The OS keyring
- `~/.config/jtechsh/credentials` (encrypted, added in a later version)

## Audit Policy (v0.2+)

Every action that mutates state (files, emails, calendar, scheduled jobs)
produces a record in the SQLite audit DB at `~/.jtechsh/data/audit.db`:

| Field       | Description                          |
|-------------|--------------------------------------|
| timestamp   | ISO-8601 UTC time                    |
| action      | verb (create, update, delete, run…)  |
| source      | which module triggered the action    |
| rule        | automation rule name (if applicable) |
| target      | file path, email thread ID, etc.     |
| result      | success / failure + detail           |

## Security Invariants (v0.6+)

- Security-classified email is **never** auto-archived.
- Human email is **never** auto-archived unless an explicit rule allows it.
- Unknown messages = observe only, never act.
- Dangerous shell commands (`rm -rf /`, `mkfs`, `dd if=/dev/zero`,
  `chmod 777 /` recursively) require explicit `--force` confirmation (v0.8).
