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

Everything below was verified live against tunnel-prod this session (ART-047 through ART-051,
v1.22.0–v1.26.0) — not documentation guesses. Where a behavior traces to a specific fix, the lap
is named so a future reader can pull the receipt instead of taking it on faith.

## The content lifecycle

One canonical URL per artifact, edited in place forever:

- **`seed`** — create. Pass `markdown` (text/markdown/html/svg/skill/lap/diagram — the `content`
  param belongs to `ingest`/`promote`, not `seed`; using `content` on `seed` silently creates an
  empty doc). Returns the `mcp://artifact/doc/<id>` URI and the public URL. **Never re-seed an
  existing artifact** — that mints a new URL. Optional `visibility: "private"` at creation time
  (default `"public"`, see Visibility below).
- **`edit`** — surgical CRDT replace (`old_string`→`new_string`). The cheap, fast, default choice
  for a small change — no full-body resend. Requires an *exact* match; see Gotchas.
- **`append`** — safe-extend, never overwrites. Right tool for log-style/growing artifacts (see
  the `tunnel-a-log` skill for the full weekly-log pattern built on this).
- **`write`** — full-body replace via compare-and-swap (`base_version` from a prior `read`). Use
  when the whole document needs replacing and you have the version in hand.
- **`promote`** — full-body replace without needing `base_version` (CRDT-merged), OR the
  workspace-bridge write path (`workspace`+`path`, re-reads a file from a synced workspace and
  pushes fresh bytes). Also the tool for **binary optimize** — see below.
- **`read`** — full current content + version + hash + `who`-adjacent metadata.
- **`diff`** — added/removed lines + `decisions {set, cleared}` since a version, for
  interactive/decision-carrying artifacts.
- **`set_title`** — rename (pure metadata, no version bump).
- **`close`** — owner-only, locks the artifact (no more writes; history stays forever).

**Choosing edit vs. promote vs. append:** one or two sentences changing → `edit`. Restyling or
rewriting the whole document → `promote` (inline) or `write`. Growing a log/thread → `append`.

## Binary and image handling

Three tiers, pick by source size and where the bytes currently live:

1. **Small inline binary** (roughly under the size you could paste as text) — `ingest`/`promote`
   with `base64` + `content_type:"binary"`. Mime is sniffed automatically (`ART-047`); the result
   carries `mime_type` and `download_url` directly.
2. **One-call server-side optimize** — add `optimize: "web"` (or explicit `max_width`, `quality`,
   `format`, or a size budget via `target_kb`) to either inline or workspace-bridge mode. The
   server runs the resize→re-encode ladder itself — this is what replaces manually shelling out to
   an image tool and hand-tuning compression rounds (`ART-048`). Verified: a 15,491 B JPEG →
   6,097 B at `target_kb:6`, auto-resized and re-encoded, in one call.
3. **Raw/large source files** — `workspace`+`path` bridge. Copy the file into a
   sky-synced workspace (`workspace_init` + local copy + `workspace_sync`), then
   `ingest({workspace, path, optimize:"web", ...})` — the server reads bytes from disk on its own
   side; **none of them transit the calling agent's context**. Self-healing since `ART-051`: a
   *missing* server-side workspace directory triggers one bounded pull-and-retry automatically —
   no manual `sky workspace pull` needed for a first-time sync (this does not cover a re-sync of a
   changed file — see Gotchas). Verified end to end: an untouched 8,566,411 B PNG →
   121,255 B hosted JPEG, one `ingest` call, zero context bytes.

**Serving routes**, once an artifact holds binary content:
- `/d/{id}/download` — raw bytes, correct `content-type`. **This is the URL to put in `<img src>`**
  or any embed. Disposition is `inline` for WebKit-renderable image types (png/jpeg/gif/webp/svg/
  bmp) — for everything else (tar.gz, dmg, ...) it's deliberately `attachment`, so don't expect a
  release binary to render inline in a browser tab; it will download instead, correctly.
- `/d/{id}/raw` — same guarantee as `/download` for binary docs.
- `/d/{id}` (bare) — the doc-viewer page; for images this now renders an actual inline `<img>`
  (mojibake-as-text is gone as of `ART-047`).

Do not inline a data-URI as a workaround unless the artifact truly needs to be self-contained
(e.g. a single-file deliverable someone downloads) — host the image separately and reference it by
`download_url` instead. That was the original pain this whole capability arc fixed.

## Grants and administrative privileges

- **`grant_deployer`** — preferred. Shares with a human deployer by handle; all of that person's
  agents inherit access via sibling rules. Rename-aware.
- **`grant_agent`** — narrow, single-agent share (audit-scoped/delegated access), doesn't touch
  the whole fleet.
- **`grant`** — legacy (agent-identity grant), prefer `grant_deployer`/`grant_agent` instead.
- **`revoke`** — remove an identity's access.
- **`who`** — list `owner`, `visibility`, and every `{identity, permission}` grant on an artifact.
  Check this before sharing a link if the content might be sensitive.

## Visibility (private/public)

- Default is **public** (link-share model) — anyone with the URL can read, no auth. This is by
  design, not a bug; most artifacts (reports, dashboards, logs) want this.
- **`seed({visibility:"private"})`** creates a private artifact from the start (`ART-050`).
- **`set_visibility`** flips an existing artifact private↔public. Owner-only (reuses the same
  ownership check as `grant`/`revoke`/`close`) — a write-grantee can edit content but cannot
  change exposure. Leak-safe: a non-reader hitting a private doc gets a plain 404, never a
  refusal that confirms the doc exists.
- Private docs 404 on **all three** routes (`/d`, `/raw`, `/download`) for anonymous requests;
  the owning session still reads normally.
- If you just called `set_visibility` (or any newly-shipped tool) and it isn't showing up in your
  own tool registry, that's a client-side `tools/list` cache — a fresh MCP session picks it up
  immediately. Don't assume a capability is missing just because your current session can't see it.

## MCP-down disclosure discipline — non-negotiable

If the tunnel MCP connection is unavailable, not logged in, or a call fails for a connectivity
reason (not a content/permission error): **stop and tell the user first.** State plainly that
tunnel is unreachable and ask how they want to proceed.

**First, try the one-step recovery before you disclose a hard block or fall back (`ART-061`).**
The most common cause of a mid-session "tunnel MCP is down" is *not* a server outage — it's a
**wedged session**: the tunnel MCP access token is short-lived (~3 days), and a session authed
before the refresh grant shipped (v1.35.0) holds no `refresh_token`, so on expiry it dead-ends
until re-authenticated. **Attempt one `/mcp` re-auth (reconnect) first** — that migrates the
session to silent refresh-renewal and usually clears the wedge outright. Only if re-auth also
fails do you disclose a genuine outage. Triaging server-vs-session: prod healthy (`/version`,
`/health`, `/oauth/register`→201) + you can reach it from another session = a per-session wedge,
not a server break — so the fix is a reconnect, not a fallback. A private Smart Doc fallback is
correct *only* after re-auth fails, never as the first move when one reconnect would have worked.

**Never silently fall back** to a different mechanism to route around it — in particular:
- Do not fall back to the openlap `attach.files`/`/uploads/<sha>.ext` route. It's
  content-addressed (a re-upload mints a new URL, breaking the "one stable link" guarantee) and
  has a known render-bug history for HTML uploads.
- Do not inline huge base64 blobs through your own context "just to get it done" if the real
  reason is that tunnel wasn't reachable — that's a workaround for a different failure, not a
  legitimate design choice, and it should be visible to the user as a fallback, not silent.

A disclosed blocker is a five-second read for the user. A silent fallback that quietly produces a
worse artifact (broken link stability, no version history, no grant system) is a trap someone
finds later, at a worse time.

## Gotchas

- **`edit` needs an exact string match.** Since `ART-049`, a miss caused by an HTML-entity vs.
  unicode mismatch (typed `—`, doc has `&mdash;`) now names the actual stored text so you can
  copy-paste retry immediately; a genuine miss gets a closest-match hint. Read the error, don't
  just retry blind.
- **Inline `base64` is bounded by your own context size** — that ceiling is a transport constant,
  not a tunnel limitation, and no server-side fix moves it. If a source is large, use the
  workspace-bridge path instead of pre-shrinking the file yourself.
- **An already-pulled workspace doesn't auto-refresh on `ingest`** if you re-sync a changed file
  from your machine (`ART-051` known edge). If you need the update to land, use a fresh workspace
  name or trigger a new hosted-agent spawn.
- **`x-artifact-shape: doc`** currently shows on every binary artifact's header regardless of
  content — a deliberate mapping (`ART-042`), not a bug; a third shape value is an open question
  pending Tunnel App input, not something to work around.
- Prefer `edit`/`append` over `promote`/`write` whenever the change is small — full-body rewrites
  cost more context per call for no benefit on a one-line fix.
