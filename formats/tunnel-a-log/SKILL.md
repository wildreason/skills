---
name: tunnel-a-log
description: >
  The running-log format for tunnel artifacts — a self-contained, EDITABLE-in-place log with
  filterable verdict entries, expand/collapse rows, and newest-on-top sections. Invoke to START
  a log or ADD an entry: weekly log, decision log, discovery log, incident log, release log,
  research log, "track this over time," "make a log for X," "add an entry to the log." One
  canonical URL forever — updates in place via tunnel edit/append, no re-upload. Inherits
  tunnel-a-base.
---

## Inherits — tunnel-a-base

Copy the token block from `tunnel-a-base` and follow its type / build / restraint rules.
Log's earned deltas from the calm baseline:

- **Filter chips + expandable rows + newest-on-top sections** — the structure a running record
  needs. Verdict tags use the data primaries (blue/yellow/red), never green.
- **Entry verdict/summary callouts are FILLED wash boxes** — `-wash` background, rounded, no
  border, no left-border stripe. The entry *cards* stay (structural); only the inner strip changes.
- **Edited in place** — one artifact id, append via tunnel edit; never re-seed.

Any inline palette below is **superseded by the token block**. Everything else base says
(self-contained, theme-aware, one-loud-thing, green-banned) holds.

# tunnel-a-log — the running-log format

A logging template you seed once as a tunnel HTML artifact, then **edit in place forever**. The
canonical example is openlap's market-discovery weekly log. This skill generalizes that template
to ANY recurring log.

**Why tunnel, not an openlap file upload:** the openlap `attach.files` route is content-addressed
(a re-upload mints a NEW id, so the old URL never updates) AND currently hits an HTML upload-render
bug. A tunnel `seed(type:"html")` doc renders cleanly at a stable URL and is editable in place via
`edit` / `append`. **One canonical URL for the life of the log.**

---

## The model

A log = **one artifact** with:
- a fixed **header** (eyebrow, title, lede, a `spec` block, a filter bar)
- a stack of **time sections** (newest on top — "Week of …", "Sprint 14", "2026-06", whatever cadence)
- inside each section, **entries** — an expandable row with a colored **verdict badge**, a title,
  a sub-line (meta + links), and a body that ends in a single **verdict line**.
- a **filter bar** that shows/hides entries by verdict.

The **verdict taxonomy is the one thing you configure per log.** Market-discovery uses
DROP / PARK / SPIKE / WATCH. An incident log might use OPEN / MITIGATED / RESOLVED. A release log
might use SHIPPED / ROLLED_BACK. Pick 2–5, give each a color, and the template does the rest.

---

## Step 1 — seed a new log (once)

Call the tunnel seed tool with `type: "html"`, a `title`, and the template below with the
`{{PLACEHOLDERS}}` filled in. It returns `{ id, url, uri }`.

```
seed({
  type: "html",
  title: "<Log Title> — <Cadence> Log",
  markdown: "<the filled template — full <!DOCTYPE html> … </html>>"
})
→ url:  https://artifacts.wildreason.ai/d/<id>
→ uri:  mcp://artifact/doc/<id>
```

Then post the `url` wherever the log lives (a channel), and — if there's a coordination room —
record the canonical URL + this update method to its memory so it survives turnover:
```
emit_channel_memory({ channel, event_type:"NOTE",
  event_body:"Canonical <name> log = <url> (tunnel doc, editable in place). Update: tunnel edit/append, prepend newest section on top. Never re-upload to the f_ file route." })
```

## Step 2 — log a new entry (every time after)

**Never re-seed** (that makes a new artifact). Edit the SAME doc by its `uri`.

- **New time section** (new week/sprint): `edit` — insert your new `<h2 class="week">…</h2>` +
  `week-rule` + entries ABOVE the current top section (right after the `<p class="hint">…</p>` line).
  Newest-on-top is the rule.
- **New entry into the existing top section:** `edit` — insert the `<div class="entry">…</div>`
  block after that section's `week-rule`.
- **Append-only fallback** (e.g. a footnote): `append`.

```
edit({ uri: "mcp://artifact/doc/<id>",
  old_string: "<p class=\"hint\">click a row to expand · click a filter to narrow by verdict</p>",
  new_string: "<p class=\"hint\">click a row to expand · click a filter to narrow by verdict</p>\n\n  <h2 class=\"week\">Week of <DATE> <span class=\"count\"><N> items</span></h2>\n  <div class=\"week-rule\"></div>\n\n  <!-- new entry blocks here -->" })
```

Bump the footer date the same way. Keep each entry's body terse; for anything long, link out to
a dedicated artifact and keep the log entry a 4-line summary + the link.

---

## The template

Fill the `{{PLACEHOLDERS}}`. The CSS is proven — leave it. Configure verdicts in the two marked
spots (the `:root` color tokens already include blue/green/yellow/red/violet to draw from; map
each verdict to a `.v-*` badge + a `.chip[data-f="*"]` and a `data-verdict="*"` on each entry).

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{LOG_TITLE}} — {{CADENCE}} Log</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
:root{
  --c-primary:var(--ink); --c-secondary:var(--ink-soft); --c-tertiary:var(--ink-faint); --c-quaternary:var(--ink-faint);
  --c-bg:var(--ground); --c-surface:var(--sheet); --c-fill:var(--hairline);
  --c-stroke:rgba(15,20,25,0.09); --c-stroke-soft:rgba(15,20,25,0.06); --c-stroke-3:rgba(15,20,25,0.22);
  --c-blue:#1d9bf0;  --c-blue-soft:rgba(29,155,240,0.12);
  --c-yellow:var(--yellow);--c-yellow-soft:rgba(255,173,31,0.14);
  --c-red:var(--red);   --c-red-soft:rgba(192,57,43,0.08);
  --c-violet:var(--blue);--c-violet-soft:rgba(124,58,237,0.10);
  --f-display:'Instrument Serif',serif;
  --f-body:'Inter',system-ui,-apple-system,sans-serif;
  --f-mono:'JetBrains Mono',ui-monospace,Menlo,monospace;
}
*{box-sizing:border-box}
html,body{margin:0;padding:0;background:var(--c-bg);color:var(--c-primary);
  font-family:var(--f-body);font-size:15px;line-height:1.6;-webkit-font-smoothing:antialiased}
.wrap{max-width:1100px;margin:0 auto;padding:56px 32px 130px}
.eyebrow{font-family:var(--f-mono);font-size:11px;letter-spacing:0.14em;
  text-transform:uppercase;color:var(--c-tertiary);margin:0 0 14px}
h1{font-family:var(--f-display);font-weight:400;font-size:58px;
  letter-spacing:-0.02em;line-height:1.03;margin:0 0 18px}
h1 em{font-style:italic;color:var(--c-secondary)}
.lede{color:var(--c-secondary);font-size:17px;max-width:740px;margin:0 0 28px}
.lede strong{color:var(--c-primary);font-weight:600}
.lede code{font-family:var(--f-mono);font-size:13px;background:rgba(0,0,0,0.04);padding:1px 5px;border-radius:4px}
pre.spec{font-family:var(--f-mono);font-size:11px;line-height:1.8;color:var(--c-tertiary);
  margin:22px 0 36px;border-left:2px solid rgba(15,20,25,0.08);padding:2px 0 2px 16px;
  max-width:740px;white-space:pre-wrap}
pre.spec strong{color:var(--c-primary);font-weight:500}
h2.week{font-family:var(--f-display);font-weight:400;font-size:32px;letter-spacing:-0.012em;
  margin:54px 0 6px;display:flex;align-items:baseline;gap:14px}
h2.week .count{font-family:var(--f-mono);font-size:11px;letter-spacing:0.08em;
  text-transform:uppercase;color:var(--c-tertiary)}
.week-rule{height:1px;background:var(--c-stroke);margin:0 0 20px}
.bar{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin:0 0 8px}
.bar .lbl{font-family:var(--f-mono);font-size:10px;letter-spacing:0.12em;
  text-transform:uppercase;color:var(--c-tertiary);margin-right:4px}
.chip{font-family:var(--f-mono);font-size:11px;font-weight:500;letter-spacing:0.04em;
  padding:5px 12px;border-radius:50px;border:1px solid var(--c-stroke);
  background:var(--c-surface);color:var(--c-secondary);cursor:pointer;
  user-select:none;transition:all .12s ease}
.chip:hover{border-color:var(--c-stroke-3)}
.chip.on{color:var(--c-primary);font-weight:600}
.chip[data-f="all"].on{background:var(--c-fill);border-color:var(--c-stroke-3)}
/* --- VERDICT CHIPS: one rule per verdict --- */
.chip[data-f="drop"].on{background:var(--c-red-soft);border-color:var(--c-red);color:var(--c-red)}
.chip[data-f="park"].on{background:var(--c-yellow-soft);border-color:var(--c-yellow);color:var(--yellow-ink)}
.chip[data-f="spike"].on{background:var(--c-blue-soft);border-color:var(--c-blue);color:#0b6fb0}
.chip[data-f="watch"].on{background:var(--c-violet-soft);border-color:var(--c-violet);color:var(--blue-ink)}
.hint{font-family:var(--f-mono);font-size:10px;color:var(--c-quaternary);margin:0 0 24px}
.entry{background:var(--c-surface);border:1px solid var(--c-stroke);border-radius:14px;
  margin:14px 0;overflow:hidden;
  box-shadow:0 1px 2px rgba(15,20,25,0.03),0 8px 24px -8px rgba(15,20,25,0.08)}
.entry.hide{display:none}
.entry-head{display:flex;align-items:flex-start;gap:16px;padding:20px 26px;cursor:pointer}
.entry-head:hover{background:rgba(15,20,25,0.012)}
.vbadge{flex:0 0 auto;font-family:var(--f-mono);font-size:10px;font-weight:600;
  letter-spacing:0.08em;text-transform:uppercase;padding:5px 11px;border-radius:6px;margin-top:2px}
/* --- VERDICT BADGES: one rule per verdict --- */
.v-drop {background:var(--c-red-soft);color:var(--c-red)}
.v-park {background:var(--c-yellow-soft);color:var(--yellow-ink)}
.v-spike{background:var(--c-blue-soft);color:#0b6fb0}
.v-watch{background:var(--c-violet-soft);color:var(--blue-ink)}
.entry-tt{flex:1 1 auto;min-width:0}
.entry-tt h3{font-size:18px;font-weight:600;margin:0 0 3px;letter-spacing:-0.01em}
.entry-tt .sub{font-family:var(--f-mono);font-size:11px;color:var(--c-tertiary);
  display:flex;flex-wrap:wrap;gap:6px 14px}
.entry-tt .sub a{color:var(--c-blue);text-decoration:none}
.entry-tt .sub a:hover{text-decoration:underline}
.caret{flex:0 0 auto;color:var(--c-quaternary);font-size:13px;margin-top:4px;
  transition:transform .15s ease}
.entry.open .caret{transform:rotate(90deg)}
.entry-body{display:none;padding:0 26px 24px 26px;border-top:1px solid var(--c-stroke-soft)}
.entry.open .entry-body{display:block}
.entry-body h4{font-size:11px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;
  color:var(--c-tertiary);margin:20px 0 6px}
.entry-body p{margin:0 0 10px;max-width:820px;color:var(--c-secondary)}
.entry-body p strong{color:var(--c-primary);font-weight:600}
.entry-body code{font-family:var(--f-mono);font-size:12.5px;background:rgba(0,0,0,0.04);
  padding:1px 5px;border-radius:4px}
.entry-body ul{margin:0 0 10px;padding-left:18px;max-width:820px;color:var(--c-secondary)}
.entry-body li{margin:0 0 6px}
.entry-body li strong{color:var(--c-primary);font-weight:600}
.verdict-line{background:linear-gradient(180deg,var(--c-yellow-soft),transparent);
  border-left:3px solid var(--c-yellow);padding:14px 20px;border-radius:0 10px 10px 0;margin:16px 0 4px}
.verdict-line.watch{background:linear-gradient(180deg,var(--c-violet-soft),transparent);border-left-color:var(--c-violet)}
.verdict-line strong{color:var(--c-primary);font-weight:600}
footer{margin-top:64px;padding-top:24px;border-top:1px solid var(--c-stroke);
  color:var(--c-tertiary);font-size:12px;font-family:var(--f-mono);
  display:flex;justify-content:space-between;flex-wrap:wrap;gap:10px}
</style>
</head>
<body>
<div class="wrap">
  <p class="eyebrow">{{EYEBROW}}</p>
  <h1>{{LOG_TITLE}}.<br><em>{{LOG_SUBTITLE}}.</em></h1>
  <p class="lede">{{LEDE — what this log tracks and the verdict rule, terse}}</p>

  <pre class="spec"><strong>cadence</strong>    — {{e.g. one section per week, newest on top}}
<strong>verdict</strong>    — {{VERDICT GLOSSARY: DROP (…) · PARK (…) · SPIKE (…) · WATCH (…)}}
<strong>flow</strong>       — {{how items reach the log}}
<strong>owner</strong>      — {{owner · who calls the verdict}}</pre>

  <div class="bar">
    <span class="lbl">Filter</span>
    <span class="chip on" data-f="all">All</span>
    <!-- one chip per verdict; data-f must match entry data-verdict -->
    <span class="chip" data-f="drop">Drop</span>
    <span class="chip" data-f="park">Park</span>
    <span class="chip" data-f="spike">Spike</span>
    <span class="chip" data-f="watch">Watch</span>
  </div>
  <p class="hint">click a row to expand · click a filter to narrow by verdict</p>

  <!-- ===== INSERT NEW SECTIONS ABOVE EVERYTHING ELSE (newest on top) ===== -->
  <h2 class="week">{{SECTION LABEL, e.g. Week of June 25, 2026}} <span class="count">{{N items}}</span></h2>
  <div class="week-rule"></div>

  <!-- ENTRY TEMPLATE (copy per item; set data-verdict + matching v-* badge) -->
  <div class="entry" data-verdict="watch">
    <div class="entry-head">
      <span class="vbadge v-watch">Watch</span>
      <div class="entry-tt">
        <h3>{{ENTRY TITLE}}</h3>
        <div class="sub">
          <span>{{meta — source, count, date}}</span>
          <a href="{{LINK}}" target="_blank">{{link label}} &#8599;</a>
        </div>
      </div>
      <span class="caret">&#9656;</span>
    </div>
    <div class="entry-body">
      <h4>{{section heading}}</h4>
      <p>{{terse body; link out for anything long}}</p>
      <div class="verdict-line watch"><strong>Verdict — WATCH.</strong> {{one-line reasoning}}</div>
    </div>
  </div>

  <footer>
    <span>{{log-name}} · maintained by {{owner}} · {{DATE}}</span>
    <span>{{tagline}}</span>
  </footer>
</div>

<script>
(function(){
  document.querySelectorAll('.entry-head').forEach(function(h){
    h.addEventListener('click',function(){ h.closest('.entry').classList.toggle('open'); });
  });
  var chips=document.querySelectorAll('.chip');
  chips.forEach(function(c){
    c.addEventListener('click',function(){
      chips.forEach(function(x){x.classList.remove('on')});
      c.classList.add('on');
      var f=c.getAttribute('data-f');
      document.querySelectorAll('.entry').forEach(function(e){
        var show = (f==='all' || e.getAttribute('data-verdict')===f);
        e.classList.toggle('hide', !show);
      });
    });
  });
})();
</script>
</body>
</html>
```

---

## Configuring verdicts (the one variable axis)

To change the verdict set, edit three coordinated places — same pattern as adding a feed family:
1. **Glossary** in the `spec` block (human-readable).
2. **One filter chip** `<span class="chip" data-f="KEY">Label</span>` in `.bar`.
3. **One badge color** `.v-KEY{…}` and **one chip color** `.chip[data-f="KEY"].on{…}` in CSS.
4. Each entry carries `data-verdict="KEY"`, a `<span class="vbadge v-KEY">Label</span>`, and a
   closing `<div class="verdict-line KEY">` (add a `.verdict-line.KEY` left-border color rule if
   you want it tinted; default is yellow).

Five tokens are pre-wired to colors (blue/green/yellow/red/violet). Map verdict → token by feel:
red = reject/critical, yellow = held/caution, blue = build/active, green = done/shipped,
violet = watch/standing.

---

## Adapting to other log types (examples)

- **Discovery / competitor log** (the original): DROP · PARK · SPIKE · WATCH, weekly sections.
- **Incident log:** OPEN(red) · MITIGATED(yellow) · RESOLVED(green), sections by month; entry body
  = symptom / cause / fix.
- **Release log:** SHIPPED(green) · ROLLED_BACK(red), sections by version line; entry body = scope /
  verify / receipt link.
- **Research log:** OPEN(blue) · ANSWERED(green) · PARKED(yellow), sections by topic; entry links to
  the full artifact, body = 4-line summary.

Keep the cadence-section + verdict-entry shape; only the words and the verdict palette change.

---

## Gotchas

- **Edit, never re-seed.** Re-seeding makes a new artifact at a new URL. The whole point is one
  stable URL. Use `edit` / `append` on the existing `uri`.
- **Newest on top.** New sections go directly after the `<p class="hint">` line, above all prior
  sections. New entries go right under their section's `week-rule`.
- **Terse entries, link out.** Each entry body is a 4-line summary; anything longer becomes its own
  tunnel artifact, linked from the entry sub-line. Logs stay glanceable.
- **Don't use the openlap file route.** `attach.files` HTML is content-addressed (no in-place update)
  and currently render-bugged. Tunnel `seed(type:"html")` is the rail.
- **Record the canonical URL** in the home channel's memory (`emit_channel_memory` NOTE) so the next
  agent updates the right doc instead of spawning a duplicate.
