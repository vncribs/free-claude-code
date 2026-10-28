#!/bin/sh
set -eu

# Copy existing state into a mounted persistent directory without overwriting
# anything already present there. These variables are opt-in, so local installs
# and existing deployments retain their current paths when unset.
if [ -n "${FCC_CONFIG_DIR:-}" ]; then
    mkdir -p "$FCC_CONFIG_DIR"
    if [ "$FCC_CONFIG_DIR" != "/root/.fcc" ] && [ -d /root/.fcc ]; then
        cp -an /root/.fcc/. "$FCC_CONFIG_DIR/" 2>/dev/null || true
    fi
fi

if [ -n "${CLAUDE_WORKSPACE:-}" ]; then
    mkdir -p "$CLAUDE_WORKSPACE"
    if [ "$CLAUDE_WORKSPACE" != "/app/agent_workspace" ] && [ -d /app/agent_workspace ]; then
        cp -an /app/agent_workspace/. "$CLAUDE_WORKSPACE/" 2>/dev/null || true
    fi
fi

exec "$@"
