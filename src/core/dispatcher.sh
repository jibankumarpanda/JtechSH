#!/usr/bin/env bash
#
# JtechSH Core - Dispatcher
#
# v0.1 responsibilities:
#   1. Recognize JtechSH builtins and route to src/core/builtins.sh
#   2. Handle `cd` specially (must run in the shell's own process,
#      not a subshell, or directory changes wouldn't persist)
#   3. Pass everything else straight through to Bash/Linux
#
# Later versions will insert additional branches here for:
#   automation, google, agent, security, audit, config, plugin, ai, sandbox
# without changing this file's overall shape.

# jtechsh::dispatch <full command line>
jtechsh::dispatch() {
    local line="$1"
    [ -z "$line" ] && return 0

    # Split into command + args using bash's own word-splitting rules
    # so quoting behaves the way users expect from a normal shell.
    local -a parts
    eval "parts=($line)" 2>/dev/null || parts=("$line")

    local cmd="${parts[0]:-}"
    local args=("${parts[@]:1}")

    [ -z "$cmd" ] && return 0

    # 1. cd must be handled in-process to persist across commands
    if [ "$cmd" = "cd" ]; then
        jtechsh::dispatch::cd "${args[@]}"
        return $?
    fi

    # 2. JtechSH builtins
    if jtechsh::builtin::is_builtin "$cmd"; then
        jtechsh::builtin::dispatch "$cmd" "${args[@]}"
        return $?
    fi

    # 3. Reserved category keywords (stubs for future phases;
    #    present now so the top-level command surface is stable).
    case "$cmd" in
        google|automation|agent|schedule|security|audit|sandbox|config|plugin|update|doctor|ai|run|script|process|service|triage)
            echo "jtechsh: '$cmd' is planned but not yet implemented in v${JTECHSH_VERSION}." >&2
            echo "          See docs/ROADMAP.md for when it lands." >&2
            return 127
            ;;
    esac

    # 4. Fall through to native Linux/Bash execution
    jtechsh::dispatch::native "$line"
    return $?
}

# jtechsh::dispatch::cd [dir]
jtechsh::dispatch::cd() {
    local target="${1:-$HOME}"
    if ! cd "$target" 2>/tmp/jtechsh_cd_err; then
        cat /tmp/jtechsh_cd_err >&2
        rm -f /tmp/jtechsh_cd_err
        return 1
    fi
    rm -f /tmp/jtechsh_cd_err
    return 0
}

# jtechsh::dispatch::native <full command line>
# Executes the raw line through bash -c so pipes, redirects, globs,
# and normal Linux utilities behave exactly as they would in a
# standard shell session.
jtechsh::dispatch::native() {
    local line="$1"
    bash -c "$line"
    return $?
}
