---
name: tunnel-a-brief
description: The decision format for tunnel artifacts -- answer first, then why: one recommendation, three reasons, the options compared and the decision needed, on two screens. Invoke for a decision memo, a proposal, a one-pager, a go or no-go, or "recommend which option we take". Not for exploring options before choosing (tunnel-a-board), a status (tunnel-a-timeline) or a long story (tunnel-a-rendition). Inherits tunnel-a-base.
---

# tunnel-a-brief

**Job:** give the answer and get a decision.

Tunnel serves the template: `templates({action:"get", id:"brief"})` returns the
skeleton, what goes in each slot and the finish line. Seed it as HTML with
`template` set to that id, then run `templates({action:"check", uri})` before
you call it done. The page rules are `templates({action:"guide", topic:"pages"})`.

What the template cannot say:

- Fit it on two screens. Numbers right-aligned, negatives in parentheses.
- Don't bury the recommendation after the analysis, or decide between options
  nobody has seen: put them on a board first (tunnel-a-board).
