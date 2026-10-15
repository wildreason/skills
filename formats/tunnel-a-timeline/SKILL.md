---
name: tunnel-a-timeline
description: The status format for tunnel artifacts -- what happens when and what is stuck: a status finding, status counts, a week-by-week plan with today marked, and a newest-first log. Invoke for a status update, a project plan, a roadmap, a release log, a weekly status, a postmortem or an incident timeline. Not for a single decision (tunnel-a-brief) or money and metrics (tunnel-a-numbers). Inherits tunnel-a-base.
---

# tunnel-a-timeline

**Job:** show what happens when, and what is stuck.

Inherits **tunnel-a-base**. Template: `templates(name:"timeline")`.

## Shape

- Eyebrow: `Timeline · status at <date>`. H1: the status as a finding ("The
  data migration is the one stream at risk; the launch date holds").
- KPI row: counts on track / at risk / not started, and days to the next
  milestone. The at-risk tile carries the accent.
- **Plan**: the kit's `gantt` block. Rows are workstreams with a status dot;
  columns are weeks. A takeaway under it saying what must change.
- **Log**: the kit's `log` block, newest first. The legend under it.

## Filling the blocks

```json
{"weeks":["Week 1","Week 2","Week 3"],"today":1.4,
 "rows":[{"name":"Stream A","st":"h",
          "items":[{"from":0,"to":2,"label":"build","kind":"a"},
                   {"at":2.5,"label":"milestone"}]}]}
```

- `today` is a fractional week index; the kit draws it as the accent line.
- `st`: `p` on track, `h` at risk, `f` blocked, `n` not started.
- Bars: no `kind` is normal (sand), `p` is prep or planned (orange), `a` is at
  risk (accent). Use `a` only for what is at risk -- don't colour every bar.
- An item with `at` is a milestone diamond.

```json
{"entries":[["Day 5 10:40","What happened, in one line","risk","a"]]}
```

Each entry: time, what happened, a chip word (`done`, `risk`, `note`), and its
kind: `n` neutral (sand), `p` in progress or planned (orange), `a` a risk
(the accent).

## Postmortem variant

Use the log as the incident timeline, newest first, and say the cause and the
impact in the takeaway. Keep the H1 a finding about what failed.
