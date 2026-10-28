# Persistent storage for Hostless deployments

FCC normally stores managed settings, databases, authentication state, logs, and messaging state under `~/.fcc`; the agent workspace is separate. A replacement container does not retain files on its root filesystem. Both directories must be on a durable volume.

## Required Hostless setup

1. In Hostless, create the app with a durable volume mounted at `/data` (the Storage step is documented in Hostless's app-creation flow). A workload supports one volume.
2. Set these environment variables on that app:
   - `FCC_CONFIG_DIR=/data/.fcc`
   - `CLAUDE_WORKSPACE=/data/agent_workspace`
3. Keep the existing required environment variables, including `IS_SANDBOX=1`, `NVIDIA_NIM_API_KEY`, and the admin password, configured as secrets/environment variables. Do not commit secrets to Git.
4. Verify the volume is attached at exactly `/data` before starting the app. The entrypoint intentionally exits if a configured `/data` path is not a mounted volume.
5. Set the app's branch to the reviewed persistence branch or use the merged commit containing these changes.

## Important: migration from an already-running app

The startup script can copy files present in the new image into the mounted volume when destination files are absent. **It cannot read the old running container's writable filesystem after that container has been replaced.** Therefore, this patch alone cannot migrate the currently running Maia's settings, Telegram token/user allowlist, provider settings, FCC database, or workspace history from an ephemeral container.

Before switching the live Maia workload, its current state must be backed up from the old runtime while it is still available, or the settings must be recreated in the new app. Do not redeploy the existing workload assuming the script will recover its runtime state. Hostless documents volume attachment in the app creation flow; if the current app has no volume, create a separate app with the volume first, validate it, and only then switch over. Keep the old app running until the replacement has been verified.

## What the volume preserves after setup

- `/data/.fcc`: managed admin settings, provider/model configuration, Telegram settings stored by FCC, database, auth state, logs, and other files under FCC's config directory.
- `/data/agent_workspace`: Maia's working files and plans.

Only files written inside the mounted path persist. Hostless bills durable volumes separately from compute; check the displayed capacity and price before creating one. Keep the volume attached and do not delete it.
