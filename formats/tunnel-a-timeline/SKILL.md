---
name: tunnel-a-timeline
description: The status format for tunnel artifacts -- what happens when and what is stuck: a status finding, status counts, a week-by-week plan with today marked, and a newest-first log. Invoke for a status update, a project plan, a roadmap, a release log, a weekly status, a postmortem or an incident timeline. Not for a single decision (tunnel-a-brief) or money and metrics (tunnel-a-numbers). Inherits tunnel-a-base.
---

# tunnel-a-timeline

**Job:** show what happens when, and what is stuck.

Tunnel serves the template: `templates({action:"get", id:"timeline"})` returns the
skeleton, what goes in each slot and the finish line. Seed it as HTML with
`template` set to that id, then run `templates({action:"check", uri})` before
you call it done. The page rules are `templates({action:"guide", topic:"pages"})`.

What the template cannot say:

- `gantt`: `today` is a fractional week index. A bar with no `kind` is normal,
  `p` is planned, `a` is at risk; use `a` only for what is at risk. An item
  with `at` is a milestone.
- `log` entries: time, what happened, a chip word (`done`, `risk`, `note`), and
  `n`, `p` or `a`.
- Postmortem: the log is the incident timeline, newest first; the takeaway says
  the cause and the impact; the H1 is a finding about what failed.
