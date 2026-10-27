---
name: tunnel-a-story
description: The one-idea format for tunnel artifacts -- make one idea land and stick: a visceral one-liner, the setup, the catch in three timed steps, the evidence, how far the fall goes, and what we know so far. Invoke for an explainer, a technical explainer, a launch post, a journalistic piece, or "make the case that this risk matters". Not for a long multi-chapter piece (tunnel-a-rendition), a status (tunnel-a-timeline) or a decision memo (tunnel-a-brief). Inherits tunnel-a-base.
---

# tunnel-a-story

**Job:** make one idea land and stick.

Tunnel serves the template: `templates({action:"get", id:"story"})` returns the
skeleton, what goes in each slot and the finish line. Seed it as HTML with
`template` set to that id, then run `templates({action:"check", uri})` before
you call it done. The page rules are `templates({action:"guide", topic:"pages"})`.

What the template cannot say:

- Pick an everyday scene with clear stakes and keep the same names throughout.
- Say which claims are proven and which are not yet run; never round a partial
  result up. No term the Setup didn't define.
- Technical variant: the ladder is the failure path through a system.
