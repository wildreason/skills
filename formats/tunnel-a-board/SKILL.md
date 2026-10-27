---
name: tunnel-a-board
description: The options format for tunnel artifacts -- every option on one wall, clustered, with votes, a favourite and the dropped ideas, before anyone chooses. Invoke for an options wall, a brainstorm, comparing approaches, a path map, a storyboard or an affinity map. Not for making the decision (hand the favourite to tunnel-a-brief), a status (tunnel-a-timeline) or numbers (tunnel-a-numbers). Inherits tunnel-a-base.
---

# tunnel-a-board

**Job:** put every option on one wall so they can be compared before choosing.

Tunnel serves the template: `templates({action:"get", id:"board"})` returns the
skeleton, what goes in each slot and the finish line. Seed it as HTML with
`template` set to that id, then run `templates({action:"check", uri})` before
you call it done. The page rules are `templates({action:"guide", topic:"pages"})`.

What the template cannot say:

- Variants, by what a cluster is: options wall (approaches), path map (stages,
  left to right), storyboard (frames, in order), affinity map (themes).
- `id`s are unique across the board, `links` pair them, and there is one `fav`.
- End with one takeaway naming the favourite. Don't decide inside the board:
  the winner goes to a brief (tunnel-a-brief).
