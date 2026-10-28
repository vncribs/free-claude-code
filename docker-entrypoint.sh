#!/bin/sh
set -eu

# Optional persistent storage support; inactive unless a custom path is configured.
if [ -n "${FCC_CONFIG_DIR:-}" ]; then
    mkdir -p "$FCC_CONFIG_DIR"
    if [ ! -e "$FCC_CONFIG_DIR/.env" ] && [ -d /root/.fcc ]; then
        cp -a /root/.fcc/. "$FCC_CONFIG_DIR/"
    fi
fi

if [ -n "${CLAUDE_WORKSPACE:-}" ]; then
    mkdir -p "$CLAUDE_WORKSPACE"
    if [ ! -e "$CLAUDE_WORKSPACE/plans" ] && [ -d /app/agent_workspace ] && [ "$CLAUDE_WORKSPACE" != "/app/agent_workspace" ]; then
        cp -an /app/agent_workspace/. "$CLAUDE_WORKSPACE/" 2>/dev/null || true
    fi
fi

exec "$@"
