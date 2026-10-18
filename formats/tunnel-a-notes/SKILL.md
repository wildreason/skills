---
name: tunnel-a-notes
description: The notes format for tunnel artifacts -- many small pieces captured as tiles, filterable by tag, with the few that should change a decision pinned first. Invoke for meeting notes, call notes, interview notes, a research digest, or "write up what we found so we can find it again". Not for a decision (tunnel-a-brief), a status (tunnel-a-timeline) or a story (tunnel-a-story). Inherits tunnel-a-base.
---

# tunnel-a-notes

**Job:** capture many small pieces and find the important ones again.

Inherits **tunnel-a-base**: the kit, the palette, finding titles, one accent.
Template: `templates(name:"notes")`.

## Shape

- Eyebrow: `Notes · <scope>` (a week, a project, a set of calls).
- H1: the most important thing the notes say, as a finding.
- Lede: one line -- how many sources, and what "pinned" means here.
- Tiles, not paragraphs, drawn by the kit's `notes` block. One tile is one idea.
  A tag filter row with counts sits above them.

## Filling the notes block

```json
{"notes":[
  {"tag":"pricing","title":"Per-seat pricing blocks teams over 20",
   "body":"One or two lines.","quote":"optional, in their words",
   "who":"who said it","date":"when","pin":true}
]}
```

- `title` states the point as a finding, never a topic.
- 3 to 6 distinct tags, one word each.
- Pin only what should change a decision. Pinned tiles sort first and carry
  the accent.
- `quote` is optional; leave it out rather than invent one.

## Do and don't

- Do: keep each tile to one idea and one or two lines.
- Don't: dump transcripts, nest tiles, or add a second accent.
