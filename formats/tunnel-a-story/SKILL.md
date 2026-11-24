---
name: tunnel-a-story
description: The one-idea format for tunnel artifacts -- make one idea land and stick: a visceral one-liner, the setup, the catch in three timed steps, the evidence, how far the fall goes, and what we know so far. Invoke for an explainer, a technical explainer, a narrated motion explainer, a launch post, a journalistic piece, or "make the case that this risk matters". Not for a long multi-chapter piece (tunnel-a-rendition), a status (tunnel-a-timeline) or a decision memo (tunnel-a-brief). Inherits tunnel-a-base.
---

# tunnel-a-story

**Job:** make one idea land and stick.

Tunnel serves the template: `templates({action:"get", id:"story"})` returns the
finish line and no skeleton: draw it; meet the finish line. Read the page rules
first, `templates({action:"guide", topic:"pages"})`, then seed it as HTML with
`template` set to that id and run `templates({action:"check", uri})` before you
call it done.

What the template cannot say:

- Pick an everyday scene with clear stakes and keep the same names throughout.
- Say which claims are proven and which are not yet run; never round a partial
  result up. No term the Setup didn't define.
- Technical variant: the ladder is the failure path through a system.

## Explainer variant: narrated and moving

For an explainer that moves and speaks, get
`templates({action:"get", id:"story/explainer"})`. Fill its engine slot with the
`kit-engine` script from artifact `bfemotIXDNvVAGpA` at version 1 (`read` with
`version`), copied verbatim and never edited. You write only the parts and the
beats.

- A part is a kit shape with `k:'<name>'`, one name per thing, so a review mark
  can sit on it.
- A beat is one spoken sentence and kit verbs only: `show`, `hide`, `draw`,
  `up`, `move`, `color`, `pulse`, `morph`. No timers or animation code of your
  own.
- Solid lines only: dashed means a region in review.
- The kit is 2D. A turn is a morph between two drawings, not a rotation; do not
  promise 3D.
- Say whether it has been played in Safari in the app.
