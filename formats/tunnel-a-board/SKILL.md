---
name: tunnel-a-board
description: The options format for tunnel artifacts -- every option on one wall, clustered, with votes, a favourite and the dropped ideas, before anyone chooses. Invoke for an options wall, a brainstorm, comparing approaches, a path map, a storyboard or an affinity map. Not for making the decision (hand the favourite to tunnel-a-brief), a status (tunnel-a-timeline) or numbers (tunnel-a-numbers). Inherits tunnel-a-base.
---

# tunnel-a-board

**Job:** put every option on one wall so they can be compared before choosing.

Inherits **tunnel-a-base**. Template: `templates(name:"board")`.

## Shape

- Eyebrow: `Board · <variant>`. H1: the question the wall answers, as a finding.
- The kit's `board` block: a dotted canvas, clusters as columns (at most four),
  each headed by a sticky label.
- Option cards: a title, one line, vote dots with a count.
- Marks: the favourite gets the accent border; a dropped card is faded and
  struck through; dashed accent arrows join options that build on each other.
- One takeaway under the wall naming the favourite path.

## Filling the board block

```json
{"clusters":[
  {"name":"Approach one","items":[
    {"id":"a1","title":"Option title","body":"one line","votes":3,"fav":true},
    {"id":"a2","title":"Option title","body":"one line","votes":0,"drop":true}]}],
 "links":[["a1","b2"]]}
```

- `id`s are unique across the board; `links` pair them, or are `[]`.
- One `fav` per board.

## Variants

- **Options wall**: clusters are approaches.
- **Path map**: clusters are stages, left to right.
- **Storyboard**: clusters are frames, in order.
- **Affinity map**: clusters are themes.

## Do and don't

- Do: end with one takeaway naming the favourite.
- Don't: decide inside the board. The winner goes to a brief.
