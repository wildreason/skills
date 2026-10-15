---
name: tunnel-a-brief
description: The decision format for tunnel artifacts -- answer first, then why: one recommendation, three reasons, the options compared and the decision needed, on two screens. Invoke for a decision memo, a proposal, a one-pager, a go or no-go, or "recommend which option we take". Not for exploring options before choosing (tunnel-a-board), a status (tunnel-a-timeline) or a long story (tunnel-a-rendition). Inherits tunnel-a-base.
---

# tunnel-a-brief

**Job:** give the answer and get a decision.

Inherits **tunnel-a-base**. Template: `templates(name:"brief")`.

## Shape (answer first)

1. Eyebrow carries the decision deadline. H1 is the recommendation as a full
   sentence.
2. **The answer** box: one bold line, then one line of why.
3. **Setup**: 3 to 5 definitions the reader needs, as `<dt>Term</dt><dd>...</dd>`.
4. **Three reasons**: numbered cards, each a finding plus one supporting fact.
   Exactly three -- the finish line counts them.
5. **Options compared**: a table. The recommended row in `<b>`, its key number
   in `<td class="num a">`, the verdict as a status dot plus a word
   (`<span class="dot p"></span> recommended`). A takeaway under it.
6. **Decision needed**: Decide / By / Owner, then a source line.

The section headings stay as the template has them, in that order: Setup, Three
reasons, Options compared, Decision needed.

## Do and don't

- Do: fit on two screens. Numbers in the table right-aligned (`class="num"`),
  negatives in parentheses.
- Don't: bury the recommendation after the analysis, or decide between options
  nobody has seen -- put them on a board first.
