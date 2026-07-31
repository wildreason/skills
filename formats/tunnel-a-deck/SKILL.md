---
name: tunnel-a-deck
description: The persuasive-deck format for tunnel artifacts — a multi-section pitch, strategy, or recommendation read top to bottom: cover → numbered sections → a one-line close. Serif display headings, structural cards/tiles, at most one explanatory diagram, one accent. Invoke for a pitch deck, a capital/allocation or strategy memo, a "make the case for X" one-pager-that-scrolls, or a board/investor narrative. NOT a report (that's data → tunnel-a-report) and NOT a single note (→ tunnel-a-sheet/-brief). Inherits tunnel-a-base.
user-invocable: false
---

# tunnel-a-deck — the persuasive-deck format

A made argument, delivered section by section. The densest *prose* format (report is the densest data format). Formalizes the shape that used to be authored ad-hoc — now on the family tokens.

## Inherits — tunnel-a-base

Copy the tokens from `tunnel-a-base/tokens.css` and follow its type / build / restraint rules.
Deck's earned deltas from the calm baseline:

- **Serif display headings** — `--serif` for the cover `h1` and section `h2`s; body stays system sans; `--mono` for eyebrows/labels/meta.
- **Structural cards, tiles, and 2-col grids are allowed** — a deck argues in chunks, so hairline-bordered containers earn their place *for structure*, not decoration. Keep borders on `--hairline`, radii 12–14.
- **One accent** — `--blue` by default. A **second** hue (`--yellow`) only for a genuine two-way contrast (now vs later, pre vs post); `--red` only for a named risk. Never green, never a third.
- **One diagram** — at most one inline-SVG explanatory diagram (stroke `currentColor` / tokens), never decorative art.
- **One motion** — a single scroll-reveal fade is permitted (reduced-motion-guarded); no chains, no parallax.

One-loud-thing still holds **per section**: each section has a single emphasis, not five. Any inline palette below is **superseded by tokens.css** (migrate off-palette hex like `var(--blue)`/`var(--yellow)` to `--blue`/`--yellow`). Everything else base says holds.

## Structure

```
cover      eyebrow (mono) · serif H1 · lede · short accent rule · mono meta row
section*   eyebrow "NN · topic" (mono, blue number) · serif H2 · lede · content
           content = prose, or ONE of: tiles / cards grid / the single diagram
close      one serif line — the whole argument in a sentence
footer     mono meta (author · date · one-line thesis)
```

Sections are separated by a `border-top:1px solid var(--hairline)`; the first has none. Number them; the reader is walking an argument.

## Skeleton

```html
<!-- paste tunnel-a-base/tokens.css here, then: -->
<style>
  body{margin:0;background:var(--ground);color:var(--ink);font-family:var(--font);line-height:1.6}
  .wrap{max-width:64rem;margin:0 auto;padding:0 clamp(1.25rem,5vw,3rem)}
  section{padding:clamp(3.5rem,9vh,7rem) 0;border-top:1px solid var(--hairline)}
  section:first-of-type{border-top:none}
  .eyebrow{font-family:var(--mono);font-size:.72rem;letter-spacing:.14em;text-transform:uppercase;color:var(--ink-faint);display:flex;gap:.9rem}
  .eyebrow .num{color:var(--blue);font-weight:600}
  h1{font-family:var(--serif);font-weight:600;letter-spacing:-.02em;font-size:clamp(2.6rem,7vw,4.6rem);margin:.4em 0 0;text-wrap:balance}
  h2{font-family:var(--serif);font-weight:600;letter-spacing:-.012em;font-size:clamp(1.9rem,4.4vw,3rem);margin:.6rem 0 0;text-wrap:balance}
  .lede{font-size:clamp(1.05rem,1.7vw,1.2rem);color:var(--ink-soft);max-width:60ch;margin:1.2rem 0 0}
  .rule{height:2px;width:5rem;background:var(--blue);border-radius:2px;margin-top:1.6rem}
  .cards{display:grid;gap:1px;background:var(--hairline);border:1px solid var(--hairline);border-radius:14px;overflow:hidden;grid-template-columns:repeat(auto-fit,minmax(16rem,1fr));margin-top:2.4rem}
  .card{background:var(--sheet);padding:1.4rem}
  .rv{opacity:0;transform:translateY(12px);transition:opacity .6s,transform .6s}
  .rv.in{opacity:1;transform:none}
  @media (prefers-reduced-motion:reduce){.rv{opacity:1;transform:none;transition:none}}
</style>
<section class="cover"><div class="wrap">
  <p class="eyebrow rv"><span>Context · scope</span></p>
  <h1 class="rv">The one big claim.</h1>
  <p class="lede rv">The thesis in two sentences — honest, not hopeful.</p>
  <div class="rule rv"></div>
</div></section>
<section><div class="wrap">
  <p class="eyebrow rv"><span class="num">01</span><span>The situation</span></p>
  <h2 class="rv">What's true today.</h2>
  <p class="lede rv">One claim per section; support it, then move on.</p>
</div></section>
<script>
  var els=document.querySelectorAll('.rv');
  if(!('IntersectionObserver'in window)){els.forEach(e=>e.classList.add('in'))}
  else{var io=new IntersectionObserver(es=>es.forEach(en=>{if(en.isIntersecting){en.target.classList.add('in');io.unobserve(en.target)}}),{threshold:.12,rootMargin:'0px 0px -8% 0px'});els.forEach(e=>io.observe(e))}
</script>
```

## The line that separates deck from report

A deck **argues**; a report **records**. If the reader is meant to be *persuaded* section by section, it's a deck. If they're meant to *look up a number or a verdict*, it's `tunnel-a-report`. When in doubt, a deck has a cover and a one-line close; a report has a table and an index.
