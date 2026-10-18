---
name: tunnel-a-story
description: The one-idea format for tunnel artifacts -- make one idea land and stick: a visceral one-liner, the setup, the catch in three timed steps, the evidence, how far the fall goes, and what we know so far. Invoke for an explainer, a technical explainer, a launch post, a journalistic piece, or "make the case that this risk matters". Not for a long multi-chapter piece (tunnel-a-rendition), a status (tunnel-a-timeline) or a decision memo (tunnel-a-brief). Inherits tunnel-a-base.
---

# tunnel-a-story

**Job:** make one idea land and stick.

Inherits **tunnel-a-base**. Template: `templates(name:"story")`.

## Shape

1. H1: a visceral one-liner ("Right when it decided. Wrong when it acted.").
   Lede: the scene in two sentences, with named characters.
2. **Setup**: every character, thing and number, defined.
3. **The catch**: three timestamped steps; the last is the consequence, its
   punch in `<b>`.
4. **Evidence**: a figure with a finding title, a source (or "illustrative"),
   and a takeaway. Any chart kind from tunnel-a-base.
5. **How far the fall goes**: a ladder of exactly five rising steps, each
   `<li class="rung"><span class="n">1</span><b>step</b><p>what happens</p><em>what it costs</em></li>`
   (the finish line counts `li.rung`).
   Later steps darken on their own.
6. **What we know so far**: claim / status dot / evidence rows, with the legend.

The section headings stay in that order: Setup, The catch, How far the fall
goes, What we know so far.

## Do and don't

- Do: pick an everyday scene with clear stakes and keep the same names
  throughout.
- Do: say which claims are proven and which are not yet run. Never round a
  partial result up.
- Don't: introduce a term the Setup didn't define.
- Technical variant: the ladder can be the failure path through a system,
  step by step.
