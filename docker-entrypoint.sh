#!/bin/sh
set -eu

# A configured /data path must really be backed by a mounted volume; otherwise
# the app could appear healthy while silently writing state to ephemeral disk.
uses_data_path=0
case "${FCC_CONFIG_DIR:-}" in /data|/data/*) uses_data_path=1 ;; esac
case "${CLAUDE_WORKSPACE:-}" in /data|/data/*) uses_data_path=1 ;; esac
if [ "$uses_data_path" -eq 1 ]; then
    if ! awk '$2 == "/data" { found=1 } END { exit !found }' /proc/mounts; then
        echo "ERROR: /data is not a mounted volume. Attach a persistent Hostless volume at /data before starting FCC." >&2
        exit 78
    fi
fi

# Copy prior image defaults into persistent storage only when destination files
# are absent. Never overwrite data already present on the volume.
if [ -n "${FCC_CONFIG_DIR:-}" ]; then
    mkdir -p "$FCC_CONFIG_DIR"
    if [ "$FCC_CONFIG_DIR" != "/root/.fcc" ] && [ -d /root/.fcc ]; then
        cp -an /root/.fcc/. "$FCC_CONFIG_DIR/"
    fi
fi

if [ -n "${CLAUDE_WORKSPACE:-}" ]; then
    mkdir -p "$CLAUDE_WORKSPACE"
    if [ "$CLAUDE_WORKSPACE" != "/app/agent_workspace" ] && [ -d /app/agent_workspace ]; then
        cp -an /app/agent_workspace/. "$CLAUDE_WORKSPACE/"
    fi
fi

exec "$@"
