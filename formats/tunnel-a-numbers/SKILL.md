---
name: tunnel-a-numbers
description: The figures format for tunnel artifacts -- what the money or metrics say, consulting style: a finding with its key number, up to four KPI tiles, one chart per finding, and the line items. Invoke for a cost review, budget vs actual, a spend review, runway, a KPI review, a variance analysis or a financial update. Not for a story (tunnel-a-story) or a decision with few numbers (tunnel-a-brief). Inherits tunnel-a-base.
---

# tunnel-a-numbers

**Job:** say what the money or metrics mean.

Tunnel serves the template: `templates({action:"get", id:"numbers"})` returns the
skeleton, what goes in each slot and the finish line. Seed it as HTML with
`template` set to that id, then run `templates({action:"check", uri})` before
you call it done. The page rules are `templates({action:"guide", topic:"pages"})`.

What the template cannot say:

- Which chart: plan to actual is a `waterfall` (`costs:true` for spend); lines
  over or under plan, `variance`; the biggest item, `bars` with one `hi:true`;
  a trend against plan, `line` with plan `dashed:true`; when cash runs out,
  `line` with a `threshold`; many metrics, `lineitems`.
- Four KPI tiles at most, and one chart per finding.
