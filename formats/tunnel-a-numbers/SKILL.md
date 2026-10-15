---
name: tunnel-a-numbers
description: The figures format for tunnel artifacts -- what the money or metrics say, consulting style: a finding with its key number, up to four KPI tiles, one chart per finding, and the line items. Invoke for a cost review, budget vs actual, a spend review, runway, a KPI review, a variance analysis or a financial update. Not for a story (tunnel-a-story) or a decision with few numbers (tunnel-a-brief). Inherits tunnel-a-base.
---

# tunnel-a-numbers

**Job:** say what the money or metrics mean.

Inherits **tunnel-a-base**. Template: `templates(name:"numbers")`.

## Shape

- Eyebrow: `Numbers · <period> · <unit>`. H1: the finding with the key number.
- KPI tiles, four at most: `<div class="kpi"><b>value</b><span>label</span></div>`.
  The one that matters is `class="kpi a"`.
- One chart per finding. Each: a finding title (`.finding`), the chart, a source
  line with unit and period, a takeaway.
- **Line items**: the kit's `lineitems` table with sparklines.

## Which chart

| Question | Kind |
|---|---|
| How did we get from A to B (plan to actual, last year to this)? | `waterfall`, `costs:true` for spend |
| Which lines are over or under plan? | `variance` |
| Which item is biggest, or the problem? | `bars`, one `hi:true` |
| How is it trending against plan? | `line`, actual solid, plan `dashed:true` |
| When does cash run out? | `line` with a `threshold` floor |
| Many metrics at once | `lineitems` (sparklines per row) |

JSON for each kind is in tunnel-a-base. For example:

```json
{"data":[{"label":"Plan","value":100,"total":true},{"label":"Line A","value":-12},
         {"label":"Line B","value":7},{"label":"Actual","value":95,"total":true}],
 "costs":true}
```

```json
{"lines":[{"label":"Line A","plan":40,"actual":44,"trend":[38,40,43,44]}],"costs":true}
```

## Numbers rules

Units always. Negatives in parentheses; percent as (13%). One rounding level.
Shared scales across charts that are compared. Variance as amount and percent.
Bars from zero. Mark estimates and forecasts next to the number.
