---
name: tunnel-a-rendition
description: The long-form format for tunnel artifacts -- a fuller story told in chapters: headline and standfirst, contents, setup, three or more chapters with a pull quote, a figure and an aside, what it means, and sources. Invoke for a feature story, a deep dive, a case study, a narrative report, a retrospective, or "write up the full story". Not for one idea on one page (tunnel-a-story), a decision memo (tunnel-a-brief) or a status (tunnel-a-timeline). Inherits tunnel-a-base.
---

# tunnel-a-rendition

**Job:** carry the reader through the whole account, chapter by chapter, and leave them with what it means.

Tunnel serves the template: `templates({action:"get", id:"rendition"})` returns the
skeleton, what goes in each slot and the finish line. Seed it as HTML with
`template` set to that id, then run `templates({action:"check", uri})` before
you call it done. The page rules are `templates({action:"guide", topic:"pages"})`.

What the template cannot say:

- Give each chapter one finding, earned with scenes, numbers and quotes. One
  figure per chapter at most.
- Cite every number in Sources; mark anything illustrative.
- Don't pad to reach the word count. One idea is a story (tunnel-a-story).
