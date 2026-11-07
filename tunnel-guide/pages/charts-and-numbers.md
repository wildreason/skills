title: Type, colour, charts and numbers
---
Type: the kit sets system fonts and loads no web font: the system sans for display text, big numbers and body, the system monospace for labels, data, eyebrows and sources. For a serif heading use Fraunces from tunnel (pages/draw-a-frame); add no other font.

Colour:
- One accent, var(--cu) (blue by default; a page may set its own), marks the one bar, line, number or card that carries the message, and the unfavourable variance. If everything is highlighted, nothing is.
- var(--org) is the secondary: in progress, plan, forecast.
- No red and green pairs. Never rely on colour alone; add a sign or a word.
- Use only the kit's colour tokens. The template check refuses colours outside them.

Charts:
- Bars start at zero.
- Label directly at the end of the bar or line. No legends on charts.
- One message per chart.
- Under every figure, a source line (class source) and a takeaway (class takeaway).
- Charts that are compared share one scale.

Numbers:
- Put the unit and period in the eyebrow or the caption.
- Show negatives in parentheses: (1.2), (13%).
- Use one rounding level per chart.
- Give a variance as both amount and percent.
- Mark estimates, simulations and illustrative numbers next to the number. Never round a partial result up.

Status is a word, never a dot: .dot draws nothing in kit v2. Write On track, At risk, Blocked or Not started, so it never rests on colour alone.

Before publishing: the shape fits the reader's job, the headings alone tell the story, Setup defines everything used later, there is one accent, every figure has a unit, a source and a takeaway, and the page reads at 400px wide and in dark mode.
