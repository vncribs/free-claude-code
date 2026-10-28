# Persistent storage for Hostless deployments

Free Claude Code normally stores managed settings, databases, authentication state, logs, and messaging state under `~/.fcc`; the agent workspace is separate. Container filesystems may be replaced during a rebuild or redeploy, so those directories must live on a persistent volume.

## Hostless setup

1. Create or attach a durable volume to the workload and mount it at `/data`. Do not deploy until the volume is attached.
2. Set these environment variables on the workload:

   - `FCC_CONFIG_DIR=/data/.fcc`
   - `CLAUDE_WORKSPACE=/data/agent_workspace`

3. Keep existing environment variables such as `IS_SANDBOX=1` and `NVIDIA_NIM_API_KEY` as they are. Do not copy Telegram tokens or other secrets into this document or source control.
4. Redeploy only after confirming the volume is attached at exactly `/data`.

On startup, the entrypoint copies files from the image's original `/root/.fcc` and `/app/agent_workspace` into the configured directories only when destination files do not already exist. Existing persistent data is not overwritten. With the variables unset, the entrypoint leaves the default paths unchanged.

## What this preserves

The FCC config directory includes the admin-managed `.env`, provider/model choices, Telegram platform/token/allowed user/directory settings, database, auth state, logs, and other FCC state stored there. The workspace directory preserves Maia's working files and plans.

## Important limitations

- A persistent volume is required. Environment variables alone cannot preserve files across replacement of an ephemeral container.
- This repository change does not attach a Hostless volume automatically; volume attachment is a platform setting.
- Keep the volume attached to the same workload and do not delete it. Confirm Hostless's volume billing and availability for your plan before enabling it.
- The entrypoint is migration-safe for existing files, but this setup must be validated on a staging or disposable deployment before switching the live Maia workload.
