---
name: tunnel-a-rendition
description: The long-form format for tunnel artifacts -- a fuller story told in chapters: headline and standfirst, contents, setup, three or more chapters with a pull quote, a figure and an aside, what it means, and sources. Invoke for a feature story, a deep dive, a case study, a narrative report, a retrospective, or "write up the full story". Not for one idea on one page (tunnel-a-story), a decision memo (tunnel-a-brief) or a status (tunnel-a-timeline). Inherits tunnel-a-base.
---

# tunnel-a-rendition

**Job:** carry the reader through the whole account, chapter by chapter, and
leave them with what it means.

Inherits **tunnel-a-base**. Template: `templates(name:"rendition")`.

## Shape

1. Kicker (eyebrow), H1 as the story's claim, a standfirst of two or three
   sentences, and a byline: author, date, reading time.
2. **In this piece**: one `<li>` per chapter, matching the chapter titles.
3. **Setup**: every actor, thing and number the chapters use.
4. **Chapters**, three or more, each `<section class="chapter">` with
   `<span class="num">Chapter N</span>` and a finding as its title. The first
   paragraph gets a drop cap on its own.
   - One pull quote (`blockquote.pull` with a `cite`) where a line deserves it.
   - A figure where a number carries the argument: finding, chart, source,
     takeaway.
   - An aside (`aside.aside`) for a definition or a side note the main line
     can do without.
5. **What it means**: the coda, one bold line and why.
6. **Sources**: one `<li>` each.

The finish line wants at least 1200 words and at least three chapters. The
section headings stay in order: In this piece, Setup, What it means, Sources.

## Do and don't

- Do: give each chapter one finding and earn it with scenes, numbers and
  quotes. Short sentences still win in long form.
- Do: cite every number in Sources; mark anything illustrative.
- Don't: pad to reach the word count. If the story is one idea, it is a
  tunnel-a-story.
- Don't: stack figures; one per chapter at most.
