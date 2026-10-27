---
name: tunnel-a-notes
description: The notes format for tunnel artifacts -- many small pieces captured as tiles, filterable by tag, with the few that should change a decision pinned first. Invoke for meeting notes, call notes, interview notes, a research digest, or "write up what we found so we can find it again". Not for a decision (tunnel-a-brief), a status (tunnel-a-timeline) or a story (tunnel-a-story). Inherits tunnel-a-base.
---

# tunnel-a-notes

**Job:** capture many small pieces and find the important ones again.

Tunnel serves the template: `templates({action:"get", id:"notes"})` returns the
skeleton, what goes in each slot and the finish line. Seed it as HTML with
`template` set to that id, then run `templates({action:"check", uri})` before
you call it done. The page rules are `templates({action:"guide", topic:"pages"})`.

What the template cannot say:

- One tile is one idea, in one or two lines.
- Don't dump transcripts, nest tiles, or add a second accent.
