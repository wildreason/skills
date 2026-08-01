---
name: tunnel-an-essay
description: The editorial long-form format for tunnel artifacts — a narrative, memo, manifesto, retro, or design pitch meant to be read top to bottom. Reading-first with a display-serif voice (the Instrument Serif + JetBrains Mono editorial system). Invoke when the job is a made argument or a considered piece of writing, not data (report), a record (log), or a decision (sheet). Also covers hand-authoring the HTML body for `seed(type:"html")` / `seed_interactive`. Inherits tunnel-a-base.
user-invocable: false
---

## Inherits — tunnel-a-base

Copy the token block from `tunnel-a-base` and follow its type / build / restraint rules.
Essay is the family's **voiced reading rung**; its earned deltas from the calm baseline:

- **A display serif in headings** — the one format built around serif. Prefer the system
  `--serif` stack; the Instrument Serif webfont is allowed *as a declared delta* where the
  artifact host permits it (self-contained still holds — embed or accept the system fallback).
- **Mono for asides, labels, and captions** (`--mono`) — the editorial texture.
- **Generous measure.** A pull-quote is a flat filled wash box (`--blue-wash` behind `--ink`, rounded, no border) — or plain indented emphasis. **Never a left-border stripe, never a gradient.** Match the calm of `tunnel-a-doc`; no tables, no verdict colour.

`seed_interactive` mechanics (the `[data-decide]` bridge) still apply. Any inline palette below
is **superseded by the token block**. Everything else base says (theme-aware, green-banned) holds.

# tunnel-an-essay — the editorial long-form format

The `seed_interactive` server template (`tunnel-mcp/seedinteractive.go`) ships only minimal `-apple-system` scaffolding for `[data-decide]` buttons + the iframe<->host bridge. Everything visual — fonts, palette, layout, type scale, cards, accent stripes — is **agent-authored**. This skill is the source of truth for that authoring so artifacts stay consistent across sessions and authors.

Apply when: writing the `markdown:` arg to `seed(type:"html", ...)`, writing a local `.html` spike that previews artifact content, or extending the inline `<style>` of a `seed_interactive` template.

## When to use which tool

- `seed_interactive` — server assembles the HTML from `{title, question, key, options[]}`. You don't write HTML. Use when content **is** a decision capture.
- `seed(type:"html", markdown:"<full html>")` — you author the full document. Use for editorial / longform / rich layouts (briefs, status reports, design specs, dashboards).
- Local `.html` in repo root — design spike that may later become a `seed(type:"html")` body. Same tokens, same structure.

## The token system (copy verbatim into `<style>`)

```css
:root {
  /* INK — black-vs-gray carries primary hierarchy */
  --c-primary:    var(--ink);                    /* fg, ink, active */
  --c-secondary:  var(--ink-soft);                    /* fg-2, lede prose */
  --c-tertiary:   var(--ink-faint);                    /* fg-3, captions, inert */
  --c-quaternary: var(--ink-faint);                    /* fg-4, meta */

  /* SURFACE */
  --c-bg:         var(--ground);                    /* parchment, never pure white */
  --c-surface:    var(--sheet);                    /* cards on parchment */
  --c-fill:       var(--hairline);                    /* table headers, soft chips */
  --c-stroke:     rgba(18,21,26,0.09);
  --c-stroke-soft:rgba(18,21,26,0.06);
  --c-stroke-3:   rgba(18,21,26,0.22);

  /* ACCENTS — semantic only, never decorative */
  --c-blue:       #1d9bf0;  --c-blue-soft:   rgba(29,155,240,0.12);
  --c-yellow:     var(--yellow);  --c-yellow-soft: rgba(198,144,26,0.14);
  --c-red:        var(--red);  --c-red-soft:    rgba(194,86,106,0.08);
  --c-violet:     var(--blue);  --c-violet-soft: rgba(29,155,240,0.10);

  /* TYPE */
  --f-display: 'Instrument Serif', serif;
  --f-body:    'Inter', system-ui, -apple-system, sans-serif;
  --f-mono:    'JetBrains Mono', ui-monospace, Menlo, monospace;
}
```

Always preconnect + load fonts:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

## Server contract — no width cap

**The server (`tunnel-mcp/render.go`, `tunnel-mcp/seedinteractive.go`) applies no `max-width` to the body.** Artifacts render full-viewport by default. As of TMC-022, wrapping content with `.wrap { max-width: 1100px; margin: 0 auto }` is the **only path to a narrow column** — there is no `layout` flag, no `?layout=full` query, no media-query escape. Tunnel is macOS-desktop only, so there is no mobile branch to fall back on either.

Pick the shape per artifact:

- **Prose / editorial / decision capture** — wrap in `.wrap` (the page skeleton below already does this). Keeps line length readable.
- **Scenes / dashboards / comparison grids / wide tables** — drop `.wrap`, let the body fill the viewport. Use the layout grids further down to organize internal width.

## The page skeleton

```html
<body>
<div class="wrap">
  <p class="eyebrow">CONTEXT · SECTION · DATE</p>
  <h1>One sentence.<br><em>Italic accent.</em></h1>
  <p class="lede">One paragraph that frames the rest, max-width ~720px, in <strong>--c-secondary</strong> with <strong>strong</strong> bumping back to primary ink.</p>

  <pre class="spec">
<strong>label</strong>   — terse value
<strong>label</strong>   — terse value</pre>

  <h2>Section</h2>
  <!-- cards, tables, decision blocks -->

  <footer>
    <span>artifact-id · author · date</span>
    <span>tagline</span>
  </footer>
</div>
</body>
```

Base styles for the skeleton:

```css
*{box-sizing:border-box}
html,body{margin:0;padding:0;background:var(--c-bg);color:var(--c-primary);
  font-family:var(--f-body);font-size:15px;line-height:1.6;-webkit-font-smoothing:antialiased}
.wrap{max-width:1100px;margin:0 auto;padding:56px 32px 130px}

.eyebrow{font-family:var(--f-mono);font-size:11px;letter-spacing:0.14em;
  text-transform:uppercase;color:var(--c-tertiary);margin:0 0 14px}
h1{font-family:var(--f-display);font-weight:400;font-size:58px;
  letter-spacing:-0.02em;line-height:1.03;margin:0 0 18px}
h1 em{font-style:italic;color:var(--c-secondary)}
.lede{color:var(--c-secondary);font-size:17px;max-width:740px;margin:0 0 30px}
.lede strong{color:var(--c-primary);font-weight:600}
.lede code{font-family:var(--f-mono);font-size:13px;
  background:var(--field);padding:1px 5px;border-radius:4px}
h2{font-family:var(--f-display);font-weight:400;font-size:32px;
  letter-spacing:-0.012em;margin:60px 0 14px}
h3{font-size:18px;font-weight:600;margin:22px 0 8px}
h4{font-size:11px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;
  color:var(--c-tertiary);margin:16px 0 6px}
p{margin:0 0 12px;max-width:820px}
code{font-family:var(--f-mono);font-size:13px;
  background:var(--field);padding:1px 5px;border-radius:4px}

pre.spec{font-family:var(--f-mono);font-size:11px;line-height:1.8;
  color:var(--c-tertiary);margin:24px 0 48px;
  border-left:2px solid rgba(18,21,26,0.08);
  padding:2px 0 2px 16px;max-width:740px;white-space:pre-wrap}
pre.spec strong{color:var(--c-primary);font-weight:500}

footer{margin-top:64px;padding-top:24px;border-top:1px solid var(--c-stroke);
  color:var(--c-tertiary);font-size:12px;font-family:var(--f-mono);
  display:flex;justify-content:space-between;flex-wrap:wrap;gap:10px}
```

## Component recipes

### Card (white surface on parchment)

```css
.card{background:var(--c-surface);border:1px solid var(--c-stroke);
  border-radius:14px;padding:22px 28px;margin:14px 0;
  box-shadow:0 1px 2px rgba(18,21,26,0.03), 0 8px 24px -8px rgba(18,21,26,0.08)}
```

### Accent-stripe card (semantic top border)

```css
.card-accent{position:relative;overflow:hidden}
.card-accent::before{content:"";position:absolute;top:0;left:0;right:0;height:3px;
  background:linear-gradient(90deg,var(--c-yellow),var(--c-red))}
.card-accent.cons::before{background:linear-gradient(90deg,var(--c-red),var(--c-blue))}
.card-accent.sep::before {background:linear-gradient(90deg,var(--c-blue),var(--c-violet))}
```

Use yellow→red for **questions / open ambiguities**, blue→ink for **consolidation / convergence**, ink→blue for **separation / divergence**. One stripe ≠ "decorative color"; stripes carry the rhetorical role.

### Thesis callout (left-bar quote)

```css
.thesis{background:linear-gradient(180deg,var(--c-blue-soft),transparent);
  border-left:3px solid var(--c-blue);padding:18px 24px;
  border-radius:0 10px 10px 0;margin:20px 0 30px}
.thesis strong{color:var(--c-primary);font-weight:600}
```

### Table (editorial, not data-grid)

```css
.stack{width:100%;border:1px solid var(--c-stroke);border-radius:12px;
  border-collapse:separate;border-spacing:0;overflow:hidden;
  margin:14px 0 32px;background:var(--c-surface);font-size:13px}
.stack th,.stack td{text-align:left;padding:12px 16px;
  border-bottom:1px solid var(--c-stroke);vertical-align:top}
.stack tr:last-child td{border-bottom:none}
.stack th{background:var(--c-fill);font-weight:600;font-size:11px;
  text-transform:uppercase;letter-spacing:0.06em;color:var(--c-secondary)}
```

### Code block (dark, syntax-highlighted by hand)

```css
pre{font-family:var(--f-mono);font-size:12.5px;background:var(--ink);color:var(--hairline);
  padding:14px 18px;border-radius:8px;overflow-x:auto;line-height:1.58;margin:8px 0 18px}
pre code{background:transparent;padding:0;color:inherit}
pre .c{color:var(--ink-faint)}              /* comment */
pre .k{color:var(--yellow)}              /* keyword */
pre .s{color:var(--blue-ink)}       /* string */
pre .b{color:var(--hairline);font-weight:600} /* bold */
pre .p{color:var(--blue)}              /* property */
```

Wrap tokens in `<span class="k|s|c|b|p">` manually inside `<pre>`. No JS highlighter — keep artifacts self-contained.

## Layout grids

```css
.row-2{display:grid;grid-template-columns:1fr 1fr;gap:40px;align-items:start}
.row-3{display:grid;grid-template-columns:repeat(3,1fr);gap:28px;align-items:start}
.row-4{display:grid;grid-template-columns:repeat(4,1fr);gap:24px;align-items:start}
@media (max-width:1000px){.row-3,.row-4{grid-template-columns:1fr 1fr}}
@media (max-width:640px){.row-2,.row-3,.row-4{grid-template-columns:1fr}}
```

## Hard rules

1. **Background is `var(--ground)` parchment, never pure white.** White is reserved for cards.
2. **Ink hierarchy is black → gray-secondary → gray-tertiary → gray-quaternary.** No mid-tone "almost-black".
3. **Color is semantic, not decorative.** Blue = stable / thesis. Ink = consolidation / done. Yellow = open question. Red = problem / blocker. Ink-soft = separation / new branch. Don't reach for accents to "make it pretty".
4. **Italic `em` inside `h1`** is the signature display move. Use it for the "answer half" of a two-part headline (`Four states. <em>One ink.</em>`).
5. **Eyebrow is mono uppercase** with `letter-spacing: 0.14em`. Never sentence-case.
6. **Max content width caps**: `.lede` 740, `p` 820, `pre.spec` 740, footer 1100. Don't run prose to viewport edge.
7. **Soft shadow only on cards**: `0 1px 2px rgba(18,21,26,0.03), 0 8px 24px -8px rgba(18,21,26,0.08)`. No hard drop-shadows.
8. **Radius scale**: 4 (chips/code), 8 (pre), 10-14 (cards), 16 (sidebars), 50% (avatars). No arbitrary values.
9. **Footer is mono** with id + tagline split between two flex children.
10. **Banned vocabulary in body copy**: "doc", "document", "living document". Use **artifact**. (Mirrors ART-033 four-rule contract.)
11. **Server applies no `max-width` (TMC-022).** Wrap prose in `.wrap { max-width: 1100px; margin: 0 auto }` for a reading column; omit `.wrap` for full-viewport content (scenes, dashboards, wide tables). No `layout` flag exists — author choice is binary at the wrapper.

## Don't

- Don't import a CSS framework. Tokens are inline in `<style>`. Self-contained, ~3-5KB.
- Don't use `Inter` for display headings — Instrument Serif carries them. Don't use Instrument Serif for body — Inter does.
- Don't introduce new accent colors. Three accents (blue, yellow, red) plus the ink neutrals cover every semantic role we've needed. Green is banned as a UI signal and violet has no token.
- Don't add JS unless you're inside `seed_interactive` and need the bridge. Editorial artifacts are static HTML.
- Don't use emoji glyphs for state. Pseudo-element rings/discs (see sidebar-compact.html `.lead-*` family) carry state without color.

## Reference exemplars

- `~/wildreason/openlap/sidebar-compact.html` — atom-system spike; ink-only; `.lead-*` glyph family with breathe animation.
- `mcp://artifact/doc/QXajFuYQJZlajw7-` (ART-033 v2) — long-form editorial; PRE-RECONCILE EXAMPLE — it predates the token law and used green and violet for `.decision.cons` / `.decision.sep`. Read it for structure, not for colour; both roles now map to blue and ink.

When in doubt, open one of those and copy structure. The system is small enough to hold in head; the exemplars are the canonical reference.

## Future mechanization

Once `tunnel-mcp/docs/design-language.css` ships (ART-031 follow-up lap), the server will inject this token system into the `seed_interactive` template by default and this skill will collapse to: "use the design-language.css tokens; don't reintroduce them inline." Until then, copy the `<style>` block above into every authored artifact.
