#!/usr/bin/env bash
#
# JtechSH Core - Builtins
#
# v0.1 builtins: help, version, exit, clear, history
# Future phases add: doctor, config, audit, google, automation, agent, ...
# (see src/commands/ for where those will live once implemented)

declare -a JTECHSH_HISTORY=()

# jtechsh::builtin::is_builtin <cmd>
# Returns 0 (true) if <cmd> is a recognized JtechSH builtin.
jtechsh::builtin::is_builtin() {
    case "$1" in
        help|version|exit|quit|clear|history) return 0 ;;
        *) return 1 ;;
    esac
}

# jtechsh::builtin::dispatch <cmd> [args...]
jtechsh::builtin::dispatch() {
    local cmd="$1"; shift || true
    case "$cmd" in
        help)    jtechsh::builtin::help "$@" ;;
        version) jtechsh::builtin::version ;;
        exit|quit) jtechsh::builtin::exit_shell ;;
        clear)   clear ;;
        history) jtechsh::builtin::history "$@" ;;
        *)
            echo "jtechsh: unknown builtin: $cmd" >&2
            return 1
            ;;
    esac
}

jtechsh::builtin::version() {
    cat <<EOF
JtechSH ${JTECHSH_VERSION} (${JTECHSH_CODENAME})
Shell: Bash ${BASH_VERSION%%[^0-9.]*}
Platform: $(uname -s) $(uname -r)
EOF
}

jtechsh::builtin::help() {
    cat <<'EOF'
JtechSH - Secure Intelligent Shell & Automation Platform

Built-in commands:
  help              Show this help message
  version           Show JtechSH version and platform info
  history           Show command history for this session
  clear             Clear the terminal screen
  exit, quit        Exit JtechSH

Linux commands:
  Any standard Linux/Bash command is passed through as-is, e.g.
    ls, cd, pwd, mkdir, rm, cp, mv, cat, chmod, ...

Coming in later versions (see docs/ROADMAP.md):
  doctor            Check environment / dependencies      (v0.2)
  audit             View local command/action audit log   (v0.2)
  google            Gmail / Calendar / Drive via gogcli    (v0.3)
  automation        Run and schedule automations           (v0.4)
  agent             Manage OpenClaw-backed agents           (v0.5)
  security, sandbox Risk detection, approvals, isolation    (v0.7-0.8)
  plugin            Manage installed plugins                (v0.9)
EOF
}

jtechsh::builtin::history() {
    local i=1
    for entry in "${JTECHSH_HISTORY[@]}"; do
        printf "%5d  %s\n" "$i" "$entry"
        i=$((i + 1))
    done
}

jtechsh::builtin::exit_shell() {
    echo "Goodbye."
    exit 0
}
