title: The workspace bridge for large files
---
The bridge moves a file to tunnel without its bytes passing through your context. The server reads the file from disk on its own side.

1. Make or reuse a synced workspace: workspace_init with a name. A first workspace needs the deployer to run sky workspace init. If you have no sky tools, ask the user to set the workspace up; do not fall back to base64 for a large file.
2. Copy the file into that workspace on your machine.
3. Sync it: workspace_sync.
4. Call ingest with workspace, path (relative to the workspace) and usually optimize "web". To replace an existing artifact's bytes, call promote with uri, workspace and path.

A first sync heals itself: if the server has no copy of the workspace yet, ingest pulls it once and retries. You do not need a manual pull.

The known edge: a workspace the server already pulled does not refresh when you re-sync a changed file. ingest then reads the old bytes. If an update must land, use a fresh workspace name for it.

Check the reply: mime_type, size and download_url should match what you expect. A broken or truncated image is refused with the reason, and nothing changes.

Use the bridge for anything you would not paste whole into a message. Pre-shrinking a file yourself so that it fits as base64 is the wrong fix; the bridge and optimize exist so you never have to.
