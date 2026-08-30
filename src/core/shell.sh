#!/usr/bin/env bash
#
# JtechSH Core - Interactive Shell Loop
#
# Displays the startup banner (once) and then reads, dispatches,
# and logs commands in a loop until the user exits.

jtechsh::shell::banner() {
    [ "${JTECHSH_SHOW_BANNER:-1}" = "1" ] || return 0
    local ver_line="v${JTECHSH_VERSION}"
    local width=30
    local pad=$(( (width - ${#ver_line}) / 2 ))
    local left right border
    left=$(printf '%*s' "$pad" '')
    right=$(printf '%*s' "$(( width - ${#ver_line} - pad ))" '')
    border="──────────────────────────────"

    printf '╭%s╮\n' "$border"
    printf '│%*s%s%*s│\n' 12 '' 'JtechSH' 11 ''
    printf '│  Intelligent Linux Shell%*s│\n' 5 ''
    printf '│%s%s%s│\n' "$left" "$ver_line" "$right"
    printf '╰%s╯\n' "$border"
    echo
    echo "Type 'help' for available commands, 'exit' to quit."
}

# jtechsh::shell::prompt
# Prints the prompt string, e.g. "jtech>" with a trailing space.
jtechsh::shell::prompt() {
    printf "%s " "${JTECHSH_PROMPT_SYMBOL:-jtech>}"
}

# jtechsh::shell::loop
# The main read-eval loop. Runs until stdin closes or the user exits.
jtechsh::shell::loop() {
    local line

    while true; do
        jtechsh::shell::prompt

        if ! IFS= read -r line; then
            # EOF (Ctrl-D) - exit cleanly like a normal shell would.
            echo
            break
        fi

        # Skip empty input
        [ -z "${line// /}" ] && continue

        # Record to in-memory + on-disk history before execution,
        # mirroring how Bash records history regardless of success.
        JTECHSH_HISTORY+=("$line")
        echo "$line" >> "$JTECHSH_HISTORY_FILE" 2>/dev/null

        jtechsh::dispatch "$line"
    done
}

# jtechsh::main <args>
# v0.1: no CLI flags/subcommands yet beyond launching the interactive
# shell; this function is the seam where --version, --run <script>,
# etc. will be added in later versions without touching bin/jtechsh.
jtechsh::main() {
    jtechsh::shell::banner
    jtechsh::shell::loop
}
