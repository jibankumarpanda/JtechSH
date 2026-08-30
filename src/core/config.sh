#!/usr/bin/env bash
#
# JtechSH Core - Configuration
#
# Responsible for:
#   - version metadata
#   - user config directory layout (~/.config/jtechsh)
#   - loading config/jtechsh.conf defaults, then user overrides
#   - exposing settings as JTECHSH_* environment variables

JTECHSH_VERSION="0.1.0"
JTECHSH_CODENAME="Foundation"

JTECHSH_USER_HOME_DIR="${JTECHSH_HOME:-$HOME/.config/jtechsh}"
JTECHSH_DATA_DIR="${JTECHSH_DATA_HOME:-$HOME/.jtechsh}"

# Default in-repo config (tracked in git, safe defaults only — no secrets)
JTECHSH_DEFAULT_CONF="$JTECHSH_ROOT/config/jtechsh.conf"

# User-level config (not tracked in git, created on first run)
JTECHSH_USER_CONF="$JTECHSH_USER_HOME_DIR/config"

# Default values (may be overridden by config files below)
JTECHSH_HISTORY_FILE="$JTECHSH_USER_HOME_DIR/history"
JTECHSH_HISTORY_SIZE=1000
JTECHSH_PROMPT_SYMBOL="jtech>"
JTECHSH_SHOW_BANNER=1

# jtechsh::config::init
# Ensures the required directories exist and config files are present.
jtechsh::config::init() {
    mkdir -p "$JTECHSH_USER_HOME_DIR" \
             "$JTECHSH_USER_HOME_DIR/automation" \
             "$JTECHSH_USER_HOME_DIR/agents" \
             "$JTECHSH_USER_HOME_DIR/logs" \
             "$JTECHSH_DATA_DIR/data" 2>/dev/null

    # Seed a user config from the repo default on first run.
    if [ ! -f "$JTECHSH_USER_CONF" ] && [ -f "$JTECHSH_DEFAULT_CONF" ]; then
        cp "$JTECHSH_DEFAULT_CONF" "$JTECHSH_USER_CONF" 2>/dev/null
    fi

    # Load defaults, then user overrides (user wins).
    # Config files are simple KEY=VALUE shell-sourceable files.
    [ -f "$JTECHSH_DEFAULT_CONF" ] && source "$JTECHSH_DEFAULT_CONF"
    [ -f "$JTECHSH_USER_CONF" ] && source "$JTECHSH_USER_CONF"

    touch "$JTECHSH_HISTORY_FILE" 2>/dev/null
}

jtechsh::config::init
