---
name: tunnel-a-brief
description: >
  The branded-note format for tunnel artifacts — a launch note, feature announcement,
  ship note, or status one-pager, optionally capturing a decision (`seed_interactive`
  buttons). One warm on-brand page, not a deck. Invoke for "write the release brief /
  launch note / announcement," a status one-pager, or "make a beautiful artifact
  explaining X." Inherits tunnel-a-base. Reference exemplar:
  artifacts.wildreason.ai/d/802sMJtgyVOCf0kZ (tunl v1.15.0 brief).
---

## Inherits — tunnel-a-base

Copy the tokens from `tunnel-a-base/tokens.css` and follow its type / build / restraint
rules. Brief's earned deltas from the calm baseline:

- **A display serif** (`--serif`) allowed in the headline only; body stays system sans.
- **One accent** — a single `--blue` element (the CTA / the one number that matters). One
  loud thing per page still holds; do not add a second accent hue.
- **Decision capture** — optional `[data-decide]` buttons via `seed_interactive`.

It is a *note*, not a report or a deck: no tables, at most one section rule, no diagram.
Any inline "primaries palette" below is **superseded by tokens.css**. Everything else base
says (self-contained, theme-aware, green-banned) holds.

# Release Brief

Produce a striking, single-page release/launch brief as a **tunnel artifact**.
The output is a server-versioned doc, renders at a public URL, and pins into a
channel with native preview chrome. Three build routes; pick by interaction need.

## When to use

- "Write up the vX.Y.Z release" / "announce this feature" / "status one-pager."
- "Make a beautiful artifact explaining what we built."
- Any time a Markdown post is too flat and you want a designed page with a URL.

## House rules (non-negotiable)

- **No emojis.** Use ASCII/typographic marks only (`*`, `+`, `-`, `>`, `&darr;`,
  `&mdash;`, `!`). The brand voice is crisp, not decorated.
- **Primaries palette only:** blue, yellow, red, black, on white. No gradients,
  no extra hues. Color carries meaning (see palette).
- **Concise.** One screen of ideas. Lead with the human outcome, not the
  mechanism. Every section earns its place.
- **Self-contained HTML.** Inline `<style>`, no external fonts/JS/CDN. The
  renderer serves your HTML verbatim for `type:"html"` (X-Artifact-Shape: full).

## Route A — static beautiful brief (default)

Hand-author the HTML, then seed it:

```
seed({
  type: "html",
  title: "tunnel-live-docs-v1.15.0-release",   // becomes the filename; kebab-case
  markdown: "<!DOCTYPE html> ... </html>"        // the full page (param is named `markdown`)
})
```

Returns `{ id, url, uri }`. `url` = `https://artifacts.wildreason.ai/d/{id}`.

Then **verify against the real system** before sharing:

```
curl -sS -i https://artifacts.wildreason.ai/d/{id}   # expect 200, x-content-type: html, x-artifact-shape: full
```

Then **pin to the channel** with native preview (never paste the raw mcp:// URL
in the body — attach it):

```
post_channel({ channel, body: "## ...short status...\n\nhttps://artifacts.wildreason.ai/d/{id}",
               attach: { artifacts: ["{id}"] } })
```

Iterate with `edit`/`write` on the same `uri` — never re-`seed` (that makes a new
doc at a new URL).

## The design system (paste this `<style>` verbatim)

This is the locked look. Copy the block as-is; only add classes, don't restyle.

```css
/* Paste tunnel-a-base/tokens.css first -- it defines --blue/--yellow/--red/--ink
   and the neutral ramp. Do NOT redefine those names here: a second :root under the
   same names silently overrides the family for anyone who copies this block.
   Below are brief's OWN aliases only, pointing at base. */
:root{
  --blue-soft:var(--blue-wash);     /* links, hot path wash */
  --yellow-soft:var(--yellow-wash); /* highlight, "now"/pull-quote */
  --red-soft:var(--red-wash);       /* caught issues, errors, alerts */
  --mut:var(--ink-soft); --line:var(--hairline); --bg:var(--sheet);
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);
  font:16px/1.6 -apple-system,BlinkMacSystemFont,"Segoe UI",Inter,Helvetica,Arial,sans-serif;
  -webkit-font-smoothing:antialiased}
.wrap{max-width:820px;margin:0 auto;padding:56px 24px 96px}
.kicker{font-size:13px;letter-spacing:.14em;text-transform:uppercase;color:var(--blue);font-weight:700}
h1{font-size:40px;line-height:1.12;margin:10px 0 8px;letter-spacing:-.02em}
h2{font-size:22px;margin:48px 0 14px;padding-top:18px;border-top:3px solid var(--ink);display:inline-block}
h3{font-size:16px;margin:22px 0 6px}
p{color:var(--ink)}
.lede{font-size:19px;color:var(--mut);margin:6px 0 0}
.badges{margin:22px 0 0;display:flex;gap:8px;flex-wrap:wrap}
.badge{font-size:12.5px;font-weight:700;padding:5px 11px;border-radius:999px}
.b-blue{background:var(--blue);color:var(--sheet)}
.b-yellow{background:var(--yellow);color:var(--yellow-ink)}
.b-line{background:var(--sheet);color:var(--ink);border:1.5px solid var(--line)}
.pull{background:var(--yellow-soft);border-left:5px solid var(--yellow);
  padding:16px 18px;border-radius:0 10px 10px 0;margin:18px 0}
.pull b{color:var(--yellow-ink)}
.flow{display:flex;flex-direction:column;margin:22px 0;border:1px solid var(--line);border-radius:14px;overflow:hidden}
.node{padding:14px 18px;display:flex;align-items:baseline;gap:12px;background:var(--sheet)}
.node + .node{border-top:1px solid var(--line)}
.node .n{font-size:12px;font-weight:800;color:var(--sheet);background:var(--ink);border-radius:6px;padding:2px 8px;min-width:24px;text-align:center}
.node .t{font-weight:700}
.node .d{color:var(--mut);font-size:14.5px}
.node.hot{background:var(--blue-soft)}          /* highlight the load-bearing step */
.node.hot .n{background:var(--blue)}
.arrow{color:var(--mut);font-size:13px;padding:2px 0 2px 30px}
table{width:100%;border-collapse:collapse;margin:16px 0;font-size:14.5px}
th,td{text-align:left;padding:10px 12px;border-bottom:1px solid var(--line);vertical-align:top}
th{font-size:12px;text-transform:uppercase;letter-spacing:.08em;color:var(--mut)}
.chip{font-size:11.5px;font-weight:800;padding:3px 9px;border-radius:999px;white-space:nowrap}
.c-done{background:var(--blue);color:var(--sheet)}       /* shipped */
.c-now{background:var(--yellow);color:var(--yellow-ink)}   /* in flight */
.c-next{background:var(--sheet);color:var(--mut);border:1.5px solid var(--line)}  /* planned */
code{font:13.5px/1.5 "SF Mono",ui-monospace,Menlo,Consolas,monospace;background:var(--field);padding:1.5px 6px;border-radius:5px;color:var(--ink)}
.caught{display:flex;gap:14px;margin:14px 0;padding:14px 16px;border:1px solid var(--red-soft);background:var(--red-soft);border-radius:10px}
.caught .x{color:var(--red);font-weight:900;font-size:18px;line-height:1.3}
.caught .body{font-size:14.5px}
.caught .body b{color:var(--red-ink)}
.foot{margin-top:56px;padding-top:18px;border-top:1px solid var(--line);color:var(--mut);font-size:13px}
```

### Color semantics (use color to mean something)

| Token | Hex | Use for |
|---|---|---|
| blue | `var(--blue)` | primary accent, kicker, links, shipped chip, the hot/load-bearing node |
| yellow | `var(--yellow)` | pull-quote highlight, "in flight" status, the one thing to notice |
| red | `var(--red)` | caught issues, errors, false-greens, anything that almost went wrong |
| black/ink | `var(--ink)` | body text, section rules (h2 top-border), node numbers |
| soft tints | `*-soft` | backgrounds for pull/caught/hot — never as text color |

## Component reference

- **Kicker + H1 + lede** — top of page. Kicker = small blue uppercase tag
  (`<div class="kicker">Release Brief / OLP-663</div>`). H1 = the human outcome
  in plain words. Lede = one sentence expanding it.
- **Badges** (`.badge .b-blue|.b-yellow|.b-line`) — version + state pills under
  the lede. e.g. `v1.15.0 — shipped`, `cutover — in flight`, `commit abc1234`.
- **H2 sections** — each has a black top-border (`border-top:3px solid ink`).
  Keep to 5-7 sections.
- **Pull quote** (`.pull`) — the single most important takeaway, on yellow.
  "The problem it kills: ..."
- **Flow** (`.flow` > `.node` [+ `.node.hot`] + `.arrow`) — numbered vertical
  pipeline for architecture. Mark the load-bearing step `.hot` (blue).
- **Before/After table** — two columns showing the change in plain language.
- **Caught cards** (`.caught` with a red `!`) — what almost went wrong and how
  it was caught. This is a signature move: show the discipline, not just the win.
- **Status table with chips** (`.c-done`/`.c-now`/`.c-next`) — the roadmap.
- **Foot** (`.foot`) — product line + canonical surface + who prepared it.

### Recommended section flow

1. Kicker / H1 (outcome) / lede / badges
2. **What we are building** (the endeavour, plain language)
3. **What shipped** (this release; before/after table; one pull-quote)
4. **How it fits together** (the `.flow` diagram)
5. **The discipline behind it** (`.caught` cards — optional but powerful)
6. **What is coming** (status table with chips)
7. **What you will come to see** (the closer — the human payoff)
8. Foot

## Skeleton (adapt, don't restyle)

```html
<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{Product} — {version}</title>
<style>/* paste the design-system block above */</style></head>
<body><div class="wrap">
  <div class="kicker">Release Brief / {tag}</div>
  <h1>{the outcome, in human words}</h1>
  <p class="lede">{one expanding sentence}</p>
  <div class="badges">
    <span class="badge b-blue">{name} {version} &mdash; shipped</span>
    <span class="badge b-yellow">{next thing} &mdash; in flight</span>
    <span class="badge b-line">commit {sha}</span>
  </div>
  <h2>What we are building</h2> <p>...</p>
  <h2>What shipped</h2>
    <div class="pull"><b>The problem it kills:</b> ...</div>
    <table><tr><th>Before</th><th>After</th></tr><tr><td>...</td><td>...</td></tr></table>
  <h2>How it fits together</h2>
    <div class="flow">
      <div class="node"><span class="n">1</span><span class="t">...</span><span class="d">...</span></div>
      <div class="arrow">&darr;</div>
      <div class="node hot"><span class="n">2</span><span class="t">...</span><span class="d">...</span></div>
    </div>
  <h2>What is coming</h2>
    <table><tr><th>Step</th><th>Status</th></tr>
      <tr><td>...</td><td><span class="chip c-done">DONE</span></td></tr>
      <tr><td>...</td><td><span class="chip c-now">IN FLIGHT</span></td></tr>
      <tr><td>...</td><td><span class="chip c-next">PLANNED</span></td></tr></table>
  <h2>What you will come to see</h2> <p>{the payoff}</p>
  <div class="foot">{Product} &middot; {name} <code>{version}</code> &middot; {surface}<br>Prepared by {agent} for {audience}</div>
</div></body></html>
```

## Route B — interactive decision capture (`seed_interactive`)

When the brief needs the **reader to pick** (approve a release, choose a date,
vote a direction), use the server-assembled decision template — you do **not**
hand-write this HTML:

```
seed_interactive({
  title:    "Ship v1.15.0 to GA?",
  question: "Reviewed the brief — clear to promote to GA?",
  key:      "ga_decision",                 // Y.Map('decisions') key
  options:  [ {id:"ship", label:"Ship it", desc:"promote to GA now"},
              {id:"hold", label:"Hold",    desc:"one more bake cycle"} ]
})
```

Read picks back with `diff({ uri, since_version }).decisions.set` (entries carry
`{key, option, by, ts}`). 2..8 options; `id` is `[A-Za-z0-9_-]`. The look is the
tested template — clean but not custom-branded.

## Route C — hybrid (beautiful HTML + decision buttons)

Best of both: author a Route-A branded page AND embed decision buttons wired to
the same bridge. In your `seed(type:"html")` body, add:

```html
<button data-decide="ga_decision" data-option="ship">Ship it</button>
<button data-decide="ga_decision" data-option="hold">Hold</button>
```

The host page at artifacts.wildreason.ai listens for the iframe's
`{type:'tunl-decide', key, option}` postMessage, forwards it to
`POST /api/docs/{id}/decisions`, then broadcasts `{type:'tunl-decisions', decisions}`
back. Hydrate/highlight the chosen option in the iframe:

```html
<script>
window.addEventListener('message', function(e){
  if(e.data && e.data.type==='tunl-decisions'){ /* style the picked button */ }
});
</script>
```

Style the buttons with `.badge`/`.b-blue` conventions so they match the system.
Observe picks the same way: `diff({uri, since_version}).decisions.set`.

## Definition of done

1. Artifact seeded (`type:"html"` for A/C, `seed_interactive` for B).
2. Render verified live: `curl` → 200, `x-content-type: html`, expected copy present.
3. Pinned to the target channel via `post_channel` `attach.artifacts` (not a raw
   URL in the body), with a short status headline above the link.
4. No emojis; primaries palette only; one screen of ideas.
