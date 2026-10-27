title: Which write call to use
---
An artifact has one URL for life. Every change after the first lands as a new version at that same URL.

Create:
- seed makes a text, markdown, HTML or SVG artifact. Pass the body as markdown, or as HTML when you fill a template (the pages topic). Pass visibility every time.
- Never seed again to change an artifact: a new seed is a new URL, and every link and grant stays on the old one. Change it with the calls below.
- promote and ingest make an artifact from a file or from base64 bytes, and are the route for images (see the media topic).

Change, smallest first:
- edit swaps one exact string for another. Use it for a sentence or a line; nothing else is resent.
- append adds to the end and never overwrites. Use it for logs, threads and running notes.
- write replaces the whole body, and only if base_version still matches the version your read returned. If someone wrote in between, it is refused; read again and retry.
- promote with uri replaces the whole body without a base_version, merged with concurrent writes. Use it for a full restyle when you do not hold the version.

Read and compare:
- read returns the body, version and hash.
- diff from a version returns the added and removed lines, and the decisions set or cleared since then.
- log lists every version, and is where undo starts (see the undo topic).

Metadata:
- set_title renames. It makes no new version.

When an edit misses, the error names the stored text nearest to yours, including an entity such as &mdash; where you typed a dash. Copy that text and retry once; do not retry blind.

A small change by full rewrite costs your context for nothing. Prefer edit or append whenever the change is a few lines.
