---
name: tunnel-a-base
description: THE ENTRY POINT for tunnel artifact pages, and the shared kit every tunnel-a-<format> inherits -- the copper palette, the three fonts, the page rules (finding titles, answer first, Setup, one accent, a takeaway and a source under every figure) and the chart blocks. Start here when the SHAPE is not yet decided: this skill names the seven shapes and routes you to the one the reader's job earns (tunnel-a-notes / -brief / -timeline / -board / -numbers / -story / -rendition). It answers WHICH shape; the format skill you land on answers how to fill it. Also read it to author a new format.
user-invocable: false
---

# tunnel-a-base -- the shared kit

Every tunnel artifact page belongs to one family: one palette, one set of fonts,
one set of rules, one kit. The seven formats differ only in the layout the
reader's job needs.

## Pick the shape from the reader's job, not the topic

| Format | The reader needs to... | Also covers |
|---|---|---|
| **tunnel-a-notes** | capture many small things and find the important ones again | meeting notes, call notes, research digest |
| **tunnel-a-brief** | get the answer and make a decision | decision memo, proposal, one-pager |
| **tunnel-a-timeline** | see what happens when, and what is stuck | status update, plan, log, postmortem |
| **tunnel-a-board** | see every option at once before choosing | options wall, path map, storyboard, affinity map |
| **tunnel-a-numbers** | understand what the money or metrics say | cost review, budget vs actual, runway, KPIs |
| **tunnel-a-story** | care about one idea and remember it | explainer, launch post, journalistic piece |
| **tunnel-a-rendition** | read a fuller story, chapter by chapter | feature, deep dive, case study, retrospective |

If two fit, ask what the reader is doing: deciding (brief), exploring (board),
tracking (timeline), checking figures (numbers), looking something up (notes),
being persuaded by one idea (story), or reading the whole account (rendition).

Mechanics of creating, editing and sharing artifacts (not a format) live in
`tunnel-an-artifact`.

## Every shape has a template on tunnel

Each format has a template tunnel serves through its `templates` tool:
`templates(name:"<shape>")` returns the skeleton, its slots and the finish line
the page is checked against. Fill the slots, keep the structure, seed it as
HTML. The format skill says what goes in each slot.

## The kit

The look lives in one place, the kit, served at a fixed versioned URL:

```html
<link rel="stylesheet" href="https://artifacts.wildreason.ai/kit/v1/kit.css">
<script src="https://artifacts.wildreason.ai/kit/v1/kit.js"></script>
```

Every template already links both. When tunnel serves an HTML body it swaps
those exact two tags for the kit inline, so the page works where outside
stylesheets and scripts are blocked. Do not edit the tags, do not copy the kit
into a page, and do not add other stylesheets, scripts or fonts: the finish line
refuses anything external except the kit.

**v1 never changes once published.** A new look is `v2`, at a new URL, and old
pages keep `v1`. The CSS below IS `kit.css`; `tools/check-kit.py` holds it equal
to `kit/v1/kit.css` byte for byte.

### Blocks the kit draws

A block is a `div` with `data-vt="KIND"` holding one JSON script. The kit draws
it on load; bad JSON or an unknown kind shows a visible error note.

```html
<div data-vt="bars"><script type="application/json">{"data":[...]}</script></div>
```

Inside JSON, write `</` as `<\/` so the script never closes early.

Every item the kit draws carries `data-vt-key`: `"#"+id` when the item's data
has an `id`, else its index path (`"2"`, `"1.0"`). Give items an `id` when a
review mark should follow them through a reorder; an index key follows its place.

| Kind | JSON |
|---|---|
| `bars` | `{"data":[{"label","value","hi"}],"unit"}` -- one `hi:true` bar is the accent |
| `waterfall` | `{"data":[{"label","value","total"}],"costs"}` -- totals from zero, steps float |
| `variance` | `{"data":[{"label","actual","plan"}],"costs"}` |
| `line` | `{"labels":[],"series":[{"name","values","hi","dashed"}],"threshold":{"value","label"}}` |
| `spark` | `{"values":[],"hi"}` |
| `notes` | `{"notes":[{"tag","title","body","quote","who","date","pin"}]}` |
| `gantt` | `{"weeks":[],"today":1.4,"rows":[{"name","st","items":[{"from","to","label","kind"},{"at","label"}]}]}` |
| `log` | `{"entries":[["time","what happened","done/risk/note","n/p/a"]]}` |
| `board` | `{"clusters":[{"name","items":[{"id","title","body","votes","fav","drop"}]}],"links":[["fromId","toId"]]}` |
| `lineitems` | `{"lines":[{"label","plan","actual","trend":[]}],"costs","unit"}` |

`costs:true` means over plan is bad (spend); `false` means under plan is bad
(revenue). Status letters: `p` proven / on track, `h` partial / at risk, `f`
failing / blocked, `n` not started.

## The rules every page keeps

**Titles state the finding.** Every heading is a sentence that says what the
section shows: "Spend came in under plan, but one line runs hot", not "Spend".
Write the titles first; read top to bottom, they alone tell the story.

**Answer first.** The conclusion, then the three reasons, then the detail.

**Setup before story.** When the page introduces a situation, open with a Setup
list that defines every actor, thing, number and rule before it is used. One
word per thing, used the same way everywhere on the page.

**One accent.** `--cu` marks the one bar, line, number or card that carries the
message, and the unfavourable variance. If everything is highlighted, nothing
is. `--org` is the secondary: in progress, plan, forecast. No red and green
pairs; never rely on colour alone -- add a sign or a word.

**Type.** Bricolage Grotesque for display and big numbers, IBM Plex Sans for
body, IBM Plex Mono for labels, data, eyebrows and sources.

**Charts.** Bars start at zero. Label directly at the bar or line end; no
legends. One message per chart. Under every figure: a source line (`.source`)
and a takeaway (`.takeaway`).

**Numbers.** Unit and period in the eyebrow or caption. Negatives in
parentheses: (1.2), (13%). One rounding level per chart; shared scales across
charts that are compared. Variance as amount and percent.

**Status.** Dots: `.dot.p` proven, `.dot.h` partial, `.dot.f` failing,
`.dot.n` not yet. Always show the legend.

**Honesty.** Mark estimates, simulations and illustrative numbers next to the
number. Never round a partial result up.

**Plain language.** Short sentences, active voice. If a sentence makes the
reader stop, rewrite it. No emoji.

**Generic.** A template is a shape, not an example: fill it with the reader's
material, never with sample content carried over from somewhere else.

Before publishing: the shape matches the reader's job; the titles alone tell
the story; Setup defines everything used later; one accent; every figure has a
unit, a source and a takeaway; it reads at 400px wide and in dark mode.

## Authoring a new format

The vocabulary is capped at seven (`tools/check-names.py`). A new word replaces
an old one on purpose, in one commit: its `formats/tunnel-a-<word>/SKILL.md`,
its `templates/<word>/`, its row above, and tunnel's shape list.

**Never keep an old-name alias symlink when you rename.** The harness
de-duplicates symlinked skill dirs and keeps the ALPHABETICALLY FIRST name, so
an alias can silently replace the canonical name on the dispatch surface (the
ART-071 defect: eight aliases had replaced five of seven names). Retire the old
name in the same commit; a rename that leaves the old word reachable has not
renamed anything.

## kit.css

This block is the kit's CSS and the family's colour allowlist
(`tools/check-tokens.sh`). Change it only by publishing a new kit version.

```css
/* tunnel kit v1 -- the copper visual system for tunnel templates.
   Source of truth: wildreason/skills formats/tunnel-a-base. Tunnel serves it at
   https://artifacts.wildreason.ai/kit/v1/kit.css and inlines it when it serves an
   HTML body, so a page works where outside stylesheets are blocked.
   v1 never changes once published; a new look is v2. */
@font-face { font-family: 'Bricolage Grotesque'; font-style: normal; font-weight: 500; font-stretch: 100%; font-display: swap; src: url(https://fonts.gstatic.com/s/bricolagegrotesque/v9/3y9K6as8bTXq_nANBjzKo3IeZx8z6up5BeSl9D4dj_x9PpZBMlGIInHWVyNJ.woff2) format('woff2'); unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD; }
@font-face { font-family: 'Bricolage Grotesque'; font-style: normal; font-weight: 700; font-stretch: 100%; font-display: swap; src: url(https://fonts.gstatic.com/s/bricolagegrotesque/v9/3y9K6as8bTXq_nANBjzKo3IeZx8z6up5BeSl9D4dj_x9PpZBMlGIInHWVyNJ.woff2) format('woff2'); unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD; }
@font-face { font-family: 'IBM Plex Mono'; font-style: normal; font-weight: 400; font-display: swap; src: url(https://fonts.gstatic.com/s/ibmplexmono/v20/-F63fjptAgt5VM-kVkqdyU8n1i8q131nj-o.woff2) format('woff2'); unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD; }
@font-face { font-family: 'IBM Plex Mono'; font-style: normal; font-weight: 500; font-display: swap; src: url(https://fonts.gstatic.com/s/ibmplexmono/v20/-F6qfjptAgt5VM-kVkqdyU8n3twJwlBFgsAXHNk.woff2) format('woff2'); unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD; }
@font-face { font-family: 'IBM Plex Sans'; font-style: normal; font-weight: 400; font-stretch: 100%; font-display: swap; src: url(https://fonts.gstatic.com/s/ibmplexsans/v23/zYXzKVElMYYaJe8bpLHnCwDKr932-G7dytD-Dmu1syxeKYbSB4Zh.woff2) format('woff2'); unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD; }
@font-face { font-family: 'IBM Plex Sans'; font-style: normal; font-weight: 500; font-stretch: 100%; font-display: swap; src: url(https://fonts.gstatic.com/s/ibmplexsans/v23/zYXzKVElMYYaJe8bpLHnCwDKr932-G7dytD-Dmu1syxeKYbSB4Zh.woff2) format('woff2'); unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD; }
@font-face { font-family: 'IBM Plex Sans'; font-style: normal; font-weight: 600; font-stretch: 100%; font-display: swap; src: url(https://fonts.gstatic.com/s/ibmplexsans/v23/zYXzKVElMYYaJe8bpLHnCwDKr932-G7dytD-Dmu1syxeKYbSB4Zh.woff2) format('woff2'); unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD; }
:root{
  --bg:#FFFFFF;      /* page */
  --ink:#3B2416;     /* text, structure */
  --mute:#8A6E5C;    /* secondary text, axes, sources */
  --sand:#E6D2BC;    /* neutral fills: normal bars, cards */
  --line:#EFE3D6;    /* rules, light fills */
  --org:#E8893A;     /* secondary: in progress, plan, forecast */
  --cu:#C2511A;      /* THE accent: the finding, the failure, the bar that matters */
  --display:'Bricolage Grotesque',ui-sans-serif,system-ui,sans-serif;
  --body:'IBM Plex Sans',system-ui,-apple-system,sans-serif;
  --mono:'IBM Plex Mono',ui-monospace,Menlo,monospace;
}
@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){--bg:#17110C;--ink:#F2E6D8;--mute:#B39C88;--sand:#4B3626;--line:#2E2219;--org:#F0A35E;--cu:#E36F33;color-scheme:dark}}
:root[data-theme="dark"]{--bg:#17110C;--ink:#F2E6D8;--mute:#B39C88;--sand:#4B3626;--line:#2E2219;--org:#F0A35E;--cu:#E36F33;color-scheme:dark}

body{background:var(--bg);color:var(--ink);font:400 16px/1.55 var(--body);margin:0}
.wrap{max-width:1040px;margin:0 auto;padding-block:40px 64px;padding-left:max(16px,env(safe-area-inset-left,0px));padding-right:max(16px,env(safe-area-inset-right,0px));display:grid;grid-template-columns:minmax(0,1fr);gap:40px}
section{display:grid;grid-template-columns:minmax(0,1fr);gap:16px}
.eyebrow{font:500 12px/1 var(--mono);letter-spacing:.08em;text-transform:uppercase;color:var(--cu)}
h1{font:700 clamp(30px,5vw,50px)/1.05 var(--display);letter-spacing:-.02em;margin:0;text-wrap:balance}
h2{font:700 24px/1.15 var(--display);margin:0;text-wrap:balance}
h3{font:700 16px/1.25 var(--display);margin:0}
p{margin:0}
.lede{color:var(--mute);font-size:17px;max-width:64ch}
.note{color:var(--mute);font-size:13px}
.head{display:grid;gap:8px;max-width:720px}

/* Action title: the heading states the finding */
.finding{font:700 22px/1.2 var(--display);max-width:40ch}

/* Takeaway line under every figure */
.takeaway{font:500 15px/1.45 var(--body);padding-left:12px;border-left:3px solid var(--cu)}
.source{font:400 12px/1.4 var(--mono);color:var(--mute)}

/* Setup (the GIVEN) */
.setup{display:grid;grid-template-columns:130px 1fr;gap:10px 16px;margin:0}
.setup dt{font:500 12px/1.7 var(--mono);letter-spacing:.05em;text-transform:uppercase;color:var(--cu)}
.setup dd{margin:0}

/* Chips */
.chip{display:inline-block;font:500 10.5px/1 var(--mono);padding:4px 7px;border-radius:4px;letter-spacing:.02em;white-space:nowrap;background:var(--line);color:var(--ink)}
.chip.n{background:var(--sand)}.chip.p{background:var(--org);color:#fff}.chip.a{background:var(--cu);color:#fff}.chip.o{background:none;border:1px solid var(--sand);color:var(--mute)}

/* Status dots: proven / partial / failing / not yet */
.dot{display:inline-block;width:11px;height:11px;border-radius:50%;vertical-align:middle}
.dot.p{background:var(--cu)}.dot.h{background:linear-gradient(90deg,var(--cu) 50%,transparent 50%);box-shadow:inset 0 0 0 2px var(--cu)}.dot.f{background:var(--ink)}.dot.n{box-shadow:inset 0 0 0 2px var(--mute)}

/* Cards and tiles */
.card{background:var(--line);border-radius:8px;padding:14px;display:grid;gap:6px;align-content:start;min-width:0}
.card.hot{background:var(--sand)}

/* KPI tiles */
.kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px}
.kpi{display:grid;gap:2px}.kpi b{font:700 30px/1 var(--display);font-variant-numeric:tabular-nums}.kpi span{font:400 12px/1.35 var(--mono);color:var(--mute)}.kpi.a b{color:var(--cu)}

/* Tables */
.tw{overflow-x:auto}
table{border-collapse:collapse;width:100%;font-size:14.5px;font-variant-numeric:tabular-nums}
th{text-align:left;font:500 11px/1.2 var(--mono);letter-spacing:.05em;text-transform:uppercase;color:var(--mute);padding:8px 10px;border-bottom:1.5px solid var(--sand)}
td{padding:9px 10px;border-bottom:1px solid var(--line);vertical-align:top}
td.num,th.num{text-align:right;font-family:var(--mono)}
td.a{color:var(--cu);font-weight:600}

/* Story steps */
.story{list-style:none;margin:0;padding:0;display:grid;gap:8px}
.story li{display:grid;grid-template-columns:80px 1fr;gap:12px;padding:10px 12px;border-radius:6px;background:var(--line)}
.story li:last-child{background:var(--sand)}
.story .tm{font:500 13px/1.5 var(--mono);color:var(--cu)}

/* Figures */
figure{margin:0;display:grid;gap:8px;min-width:0}
figure svg,figure canvas{width:100%;height:auto;display:block}
.fig{border:1.5px solid var(--line);border-radius:10px;padding:14px}

.grid2{display:grid;grid-template-columns:1fr 1fr;gap:20px}
.grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
button{font:500 13px/1 var(--mono);background:none;color:var(--ink);border:1.5px solid var(--sand);border-radius:999px;padding:8px 13px;cursor:pointer}
button[aria-pressed="true"]{background:var(--ink);color:var(--bg);border-color:var(--ink)}
button:focus-visible,a:focus-visible{outline:2px solid var(--cu);outline-offset:2px}
a{color:var(--cu)}
@media (max-width:760px){.grid2,.grid3{grid-template-columns:1fr}.setup{grid-template-columns:1fr}}

/* notes */
.filters{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:14px}
.tiles{columns:3 260px;column-gap:14px}
.tile{break-inside:avoid;margin:0 0 14px;background:var(--line);border-radius:8px;padding:14px;display:grid;gap:8px}
.tile.pin{background:var(--sand)}
.tile h3{font-size:15.5px}
.tile p{font-size:14.5px}
.tile .meta{font:400 11.5px/1.3 var(--mono);color:var(--mute);display:flex;justify-content:space-between;gap:8px}
.tile .meta>span:last-child{white-space:nowrap}
.tile .q{font-style:italic;padding-left:10px;border-left:2px solid var(--cu)}
.pinmark{font:500 10.5px var(--mono);color:var(--cu)}

/* brief */
.answer{background:var(--sand);border-radius:10px;padding:18px 20px;display:grid;gap:8px}
.answer b{font:700 22px/1.25 var(--display)}
.reasons{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}
.reason .n{font:700 28px/1 var(--display);color:var(--cu)}
.ask{display:grid;grid-template-columns:auto 1fr;gap:6px 16px;padding:14px 16px;border:1.5px solid var(--cu);border-radius:10px}
.ask dt{font:500 12px/1.7 var(--mono);text-transform:uppercase;letter-spacing:.05em;color:var(--cu)}.ask dd{margin:0}
@media (max-width:760px){.reasons{grid-template-columns:1fr}}

/* timeline */
.gantt{--Q:12;display:grid;grid-template-columns:minmax(110px,200px) minmax(0,1fr);min-width:720px}
.gantt .wks{position:relative;display:grid;grid-template-columns:repeat(var(--n),minmax(0,1fr));border-bottom:1.5px solid var(--sand)}
.gantt .wk{font:500 11px/1 var(--mono);color:var(--mute);text-align:center;padding:16px 0 6px}
.gantt .now{position:absolute;top:0;transform:translateX(-50%);font:500 10.5px/1 var(--mono);color:var(--cu);white-space:nowrap}
.gantt .row{position:sticky;left:0;z-index:2;background:var(--bg);font:500 13.5px/1.25 var(--body);display:flex;align-items:center;gap:8px;padding:8px 12px 8px 0;border-bottom:1px solid var(--line)}
.gantt .row .dot{flex:none}
.gantt .trk{position:relative;display:grid;align-content:center;gap:4px;padding:8px 0;border-bottom:1px solid var(--line);background:linear-gradient(to right,var(--line) 1px,transparent 1px) 0 0/calc(100% / var(--n)) 100%}
.gantt .lane{position:relative;z-index:1;display:grid;grid-template-columns:repeat(calc(var(--n) * var(--Q)),minmax(0,1fr));gap:4px 0}
.gantt .bar{min-height:26px;border-radius:5px;background:var(--sand);font:500 11px/1.3 var(--mono);padding:6px 8px;margin-right:2px;overflow-wrap:break-word;hyphens:auto;min-width:0;display:flex;align-items:center}
.gantt .bar.p{background:var(--org);color:#fff}
.gantt .bar.a{background:var(--cu);color:#fff}
.gantt .msi{display:flex;align-items:center;gap:7px;min-width:0;font:500 10.5px/1.3 var(--mono);color:var(--ink)}
.gantt .msi .ms{flex:none;margin-left:-6px}
.gantt .msi.late{flex-direction:row-reverse}
.gantt .msi.late .ms{margin:0 -6px 0 0}
.gantt .ms{display:inline-block;width:11px;height:11px;background:var(--ink);transform:rotate(45deg)}
.gantt .today{position:absolute;top:0;bottom:0;width:2px;margin-left:-1px;background:var(--cu);opacity:.85;z-index:0}
@media (max-width:560px){.gantt{grid-template-columns:118px minmax(0,1fr)}.gantt .row{font-size:12.5px}}
.log{list-style:none;margin:0;padding:0;display:grid;gap:0}
.log li{display:grid;grid-template-columns:92px minmax(0,1fr) auto;gap:12px;padding:10px 0;border-bottom:1px solid var(--line);align-items:baseline}
.log .t{font:400 12px var(--mono);color:var(--mute)}
.log .chip{white-space:normal;overflow-wrap:anywhere;max-width:22ch;justify-self:end}
.votes .mark{white-space:nowrap}
@media (max-width:560px){.log li{grid-template-columns:minmax(0,1fr) auto;gap:4px 12px}.log .t{grid-column:1/-1}}

/* board */
.boardwrap{position:relative;border:1.5px solid var(--line);border-radius:12px;padding:18px;background:
  radial-gradient(circle,var(--line) 1px,transparent 1.2px) 0 0/18px 18px}
.clusters{display:grid;grid-template-columns:repeat(var(--cols,4),minmax(0,1fr));gap:28px;position:relative;z-index:1}
.cluster{display:grid;gap:12px;align-content:start}
.sticky{font:600 13px/1.2 var(--mono);text-transform:uppercase;letter-spacing:.05em;color:var(--cu);padding-bottom:6px;border-bottom:2px solid var(--cu)}
.opt{background:var(--bg);border:1.5px solid var(--sand);border-radius:8px;padding:12px;display:grid;gap:6px;box-shadow:0 1px 0 var(--sand)}
.opt.fav{border-color:var(--cu);border-width:2px}
.opt.drop>*{opacity:.5}.opt.drop h3{text-decoration:line-through}
.opt h3{font-size:14.5px}.opt p{font-size:13.5px;color:var(--mute)}
.votes{display:flex;flex-wrap:wrap;gap:4px;align-items:center;font:500 11px var(--mono);color:var(--mute)}
.votes i{width:9px;height:9px;border-radius:50%;background:var(--org)}
.mark{font:500 10.5px var(--mono);color:var(--cu)}
svg.links{position:absolute;inset:0;width:100%;height:100%;pointer-events:none;z-index:0}
@media (max-width:860px){.clusters{grid-template-columns:repeat(var(--cols2,2),minmax(0,1fr))}}@media (max-width:520px){.clusters{grid-template-columns:minmax(0,1fr)}}

/* numbers */
.spk{display:inline-block;vertical-align:middle}

/* story */
.ladder{list-style:none;margin:0;padding:0;display:grid;grid-template-columns:repeat(5,1fr);gap:10px}
.ladder li{display:grid;gap:6px;padding:12px;border-radius:8px;background:var(--line);align-content:start}
.ladder li:nth-child(n+4){background:var(--sand)}
.ladder .n{font:700 26px/1 var(--display);color:var(--cu)}.ladder b{font:700 14.5px/1.2 var(--display)}.ladder p{font-size:13.5px}
.ladder em{font:500 11.5px/1.35 var(--mono);font-style:normal;color:var(--cu)}
@media (max-width:860px){.ladder{grid-template-columns:1fr 1fr}}

/* rendition */
.rendition{max-width:760px}
.rendition .head{max-width:none}
.standfirst{font:500 20px/1.45 var(--body);max-width:62ch}
.byline{font:400 12px/1.4 var(--mono);color:var(--mute);display:flex;flex-wrap:wrap;gap:6px 16px}
.toc{list-style:none;margin:0;padding:0;display:grid;gap:6px;counter-reset:ch}
.toc li{counter-increment:ch;display:grid;grid-template-columns:32px 1fr;gap:8px;font-size:15px}
.toc li::before{content:counter(ch,decimal-leading-zero);font:500 12px/1.7 var(--mono);color:var(--cu)}
.chapter{display:grid;grid-template-columns:minmax(0,1fr);gap:14px}
.chapter .num{font:500 12px/1 var(--mono);letter-spacing:.08em;text-transform:uppercase;color:var(--cu)}
.chapter p{max-width:68ch}
.chapter>p:first-of-type::first-letter{font:700 3.1em/.9 var(--display);float:left;margin:4px 8px 0 0;color:var(--cu)}
.pull{margin:8px 0;padding:6px 0 6px 18px;border-left:3px solid var(--cu);font:700 24px/1.3 var(--display);max-width:32ch}
.pull cite{display:block;margin-top:8px;font:400 12px/1.4 var(--mono);font-style:normal;color:var(--mute)}
.aside{background:var(--line);border-radius:8px;padding:14px 16px;display:grid;gap:6px;font-size:14.5px}
.aside .eyebrow{color:var(--mute)}
.coda{background:var(--sand);border-radius:10px;padding:18px 20px;display:grid;gap:8px}
.coda b{font:700 20px/1.3 var(--display)}
.sources{font:400 12.5px/1.5 var(--mono);color:var(--mute);padding-left:18px;margin:0;display:grid;gap:4px}
```
