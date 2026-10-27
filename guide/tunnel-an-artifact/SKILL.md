---
name: tunnel-an-artifact
description: >
  Operating manual for tunnel artifacts (mcp://artifact/doc/<id>, rendered at
  artifacts.wildreason.ai/d/<id>): sharing and access, versioning and undo, closing,
  binary and image handling with server-side optimize, and the MCP-down disclosure
  discipline. Use when GRANTING or REVOKING access, changing visibility, inserting or
  optimizing media, reverting to an earlier version, closing an artifact, or diagnosing
  an artifact that would not save. NOT for choosing how a document should look — that is the format
  skills (sheet, doc, brief, essay, deck, log, report), which is a different decision
  made at a different moment.
---

# Tunnel an artifact

Tunnel serves this manual itself, so the copy you read is never stale. Read a
topic before you act on it: `templates({action:"guide", topic:"<topic>"})`, or
the resource `tunnel://guide/<topic>`. `templates({action:"guide"})` lists them.

Four rules hold before you read anything:

1. Never seed an artifact again once it exists; that mints a new URL. Change it
   with `edit` (small), `append` (grow) or `write` (whole body).
2. Private is the default. Pass `visibility:"public"` when anyone signed out
   will open the link, or they get 404.
3. If tunnel is unreachable, reconnect once, then tell the user it is down and
   ask. Never fall back silently to another mechanism.
4. When a tool error names a guide topic, read that topic before you retry.

| Topic | Read it |
|---|---|
| `lifecycle` | when choosing between seed, edit, append, write and promote |
| `sharing` | before you grant, revoke or send a link |
| `visibility` | before you make an artifact public or private |
| `media` | when you add an image or a file |
| `undo` | when you need an earlier version back |
| `close` | before you freeze an artifact for good |
| `tunnel-down` | when a tunnel call fails to connect or sign in |
| `pages` | before you make a page someone will read (or start at tunnel-a-base) |
