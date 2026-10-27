title: Images and files
refs: media/routes, media/workspace-bridge
---
Pick the route by the size of the source and where its bytes are now.

1. Small file: ingest or promote with base64 and content_type "binary". The type is sniffed from the bytes. The reply carries mime_type and download_url.
2. Too big for the web: add optimize "web", or max_width, quality, format or a target_kb budget. The server resizes and re-encodes in the same call. Do not shrink the file yourself first.
3. Large or raw source: the workspace bridge. The server reads the file from a synced workspace, so none of the bytes pass through your context. See media/workspace-bridge.

Base64 is bounded by your own context, not by tunnel. Above about 50 KB, use the bridge.

Put download_url in img src, never a data URI, unless the page must work as one downloaded file. The routes, and why some files download instead of showing, are in media/routes.

An image embedded in a public page must be public too (the visibility topic).

A broken image is refused at write, with the reason, and nothing changes.
