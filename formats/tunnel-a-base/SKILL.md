---
name: tunnel-a-base
description: THE ENTRY POINT for the tunnel-artifact house style, and the shared foundation every tunnel-a-<format> inherits — the token set, the type + build rules, and the restraint discipline that makes the family read as one system. Start here when you are hand-authoring an HTML body for `seed(type:"html")` and the SHAPE is not yet decided: this skill names the seven shapes and routes you to the one your purpose earns (tunnel-a-sheet / -doc / -report / -log / -brief / -essay / -deck). It answers "where do I start", never "what shape is this" — once the shape is known, go to that format, which pulls these tokens in. Also read it to author a new format.
user-invocable: false
---

# tunnel-a-base — the tunnel-artifact design foundation

Every hand-authored tunnel artifact (seeded via tunl `seed(type:"html")`) belongs to **one family** with **one token system** and **one set of rules**. The formats differ only in the structure their purpose demands. This skill is that shared foundation; the calm sheet (`tunnel-a-sheet`) is its north star.

Naming law: every format is `tunnel-a-<purpose>` and is invoked when that purpose is the job. Names describe *what it's for*, never how it was built.

## Pick the format by purpose

| Format | Invoke when you need… |
|---|---|
| **tunnel-a-sheet** | one thing at a time — a dialog, a single decision/confirmation, a short note or receipt, a small form, a share/invite. The calm north-star. |
| **tunnel-a-doc** | to render markdown as a clean, readable document — reading-first, no data, no persuasion. |
| **tunnel-a-report** | a publish-ready results report — benchmark/findings/leaderboard. Data-dense: tables, metrics, verdict chips. |
| **tunnel-a-log** | an editable, appendable, filterable log — weekly / decision / incident / release, newest-on-top, edited in place. |
| **tunnel-a-brief** | a branded launch note — feature announcement, ship note, status one-pager; can capture a decision. |
| **tunnel-an-essay** | editorial long-form — narrative, memo, manifesto, retro. Reading-first, display-serif voice. |
| **tunnel-a-deck** | a multi-section persuasive deck — cover → numbered sections → at most one diagram. Pitch / strategy. |

Mechanics of creating/editing/granting artifacts (not a format) live in `tunnel-an-artifact`.

Wrong-format smell test: must the reader **compare or absorb structured data**? → report/log. **Read one thing, maybe press one button**? → sheet. **Read a made argument top to bottom**? → essay/deck/brief. **Just read a document**? → doc.

## The inheritance contract (what "one family" means)

Every format skill opens with an **Inherits — tunnel-a-base** block and then documents *only its deltas*. The shared parts:

1. **Tokens.** Copy the token block at the bottom of this skill verbatim into the artifact's `<style>`. Neutrals are always on; the data primaries (`--blue/--yellow/--red`) are opt-in and for **meaning only**. Do not invent tokens or hardcode hex — if a value isn't in the token block, it doesn't ship.
2. **Type.** System sans (`--font`) for body; `--mono` for sigils and data only. A display **serif** (`--serif`) is a *named exception*, allowed only in the headings of `tunnel-an-essay`, `tunnel-a-deck`, and `tunnel-a-brief` — never in body, never in sheet/doc/report/log.
3. **Build.** Self-contained and CSP-safe: no webfonts, no CDN, no external CSS/JS/images (inline or data-URI). Theme-aware (ship the light + dark + `data-theme` token blocks). Responsive (relative units; content column caps; wide blocks scroll inside their own `overflow-x:auto`).
4. **Restraint** (the discipline that keeps the family calm):
   - **One loud thing** per view — or per section. Exactly one ink element; everything else recedes.
   - **Colour is meaning, not decoration.** Neutral by default. A data primary appears only where it encodes a verdict/status/emphasis a reader must decode. **Green is banned.**
   - **Distinguish by form before hue** — filled vs outlined, weight, position.
   - **Structure by whitespace + hairlines before boxes.** Reach for a bordered card/table only when the data demands it (report/log), never to decorate prose.
   - **Accent by fill, not by stripe.** A callout, verdict, scope note, or pull-quote is a soft *filled wash box* — a `-wash` background behind `-ink` text, rounded 12–14px, **no border and no gradient**. Never a left-border accent stripe (`border-left: Npx solid`) or an inset side-rule; a stripe reads as decoration and fights the calm. One wash box per section, at most — and `tunnel-a-doc` is the cleanliness bar: most sections need no box at all.
   - **Sentence case.** No decorative uppercase-mono eyebrows — except a format's own section numbering (report/deck/essay).
   - **Say less.** No subtitle/helper/lede unless it carries what the UI can't.
   - **One soft shadow, consistent radii** (12 / 20 / 999), generous padding. No stacked shadows or gradient rules.
   - **Minimal motion.** At most one entrance transition, reduced-motion-guarded. No scroll-reveal chains, no decorative SVG art (a single explanatory diagram is the deck's one allowance).

## Density ladder

The formats sit on one axis from calm to dense. Each is allowed exactly the decoration its purpose earns — and no more:

`sheet` (nothing) · `doc` (reading measure) · `brief` (brand mark + one accent) · `essay` (serif voice) · `deck` (sections + one diagram) · `log` (filter + expand rows) · `report` (tables + verdict colour)

If an artifact carries more chrome than its rung allows, it has drifted up the ladder — drop to the format its content actually needs.

## Authoring a new format

Add `tunnel-a-<purpose>/SKILL.md`, open with the Inherits block, declare deltas, and add its row to the table above. Keep the old-name alias symlink if you rename an existing one.

## The token block

This is the token set. There is no separate `tokens.css` file — this block IS the
source, so it travels wherever this skill travels. Copy it verbatim; do not edit it
here and do not maintain a second copy elsewhere.

```css
/* ============================================================================
   tunnel-a-base — the shared token foundation for every tunnel-a-<format>.
   Copy this block verbatim into any tunnel artifact. Do not invent tokens.

   NEUTRALS are always on. The ink pill is the only "loud" element.
   DATA PRIMARIES are opt-in and for MEANING ONLY (report verdicts, deck
   emphasis, log status) — never decoration. Green is banned as a UI signal.
   Ported from the Fellows modal system ("as calm as the front door").
   ========================================================================== */
:root{
  /* surfaces + ink ramp — the whole neutral system */
  --ground:#ffffff; --sheet:#ffffff; --thumb:#ffffff;
  --ink:#12151a; --ink-soft:#5b6470; --ink-faint:#9aa1ab;
  --hairline:#e9ebed; --field:#f5f6f8;
  /* the ONE loud element */
  --btn-bg:#12151a; --btn-fg:#ffffff; --ring:rgba(18,21,26,.10);
  --sheet-border:transparent;
  --shadow:0 1px 2px rgba(18,21,26,.05), 0 26px 64px -14px rgba(18,21,26,.22);
  /* type: system stack for body, mono for sigils/data. A DISPLAY SERIF is a
     named exception, allowed ONLY in essay/deck/brief headings (see --serif). */
  --font:ui-sans-serif,-apple-system,"SF Pro Display","SF Pro Text","Segoe UI",Roboto,Helvetica,Arial,sans-serif;
  --mono:ui-monospace,"SF Mono",Menlo,Consolas,monospace;
  --serif:"Charter","Iowan Old Style","Palatino Linotype","Georgia","Times New Roman",serif;
  /* DATA PRIMARIES — opt-in, meaning only. wildreason law: blue/yellow/red + black. NO green. */
  --blue:#1d9bf0; --blue-ink:#0b6fb0; --blue-wash:#e8f5fd;
  --yellow:#c6901a; --yellow-ink:#7a5a00; --yellow-wash:#fdf4e3;
  --red:#c2566a; --red-ink:#9a2a2a; --red-wash:#fdecef;
}
@media (prefers-color-scheme:dark){
  :root{
    --ground:#0b0c0e; --sheet:#191b1f; --thumb:#2c3038;
    --ink:#f4f5f6; --ink-soft:#9ba2ac; --ink-faint:#6b7280;
    --hairline:#262930; --field:#202329;
    --btn-bg:#f4f5f6; --btn-fg:#16181c; --ring:rgba(244,245,246,.14);
    --sheet-border:#262930;
    --shadow:0 1px 2px rgba(0,0,0,.4), 0 26px 64px -14px rgba(0,0,0,.6);
    --blue:#7cc0f5; --blue-ink:#9dc9f7; --blue-wash:#172a38;
    --yellow:#e0b657; --yellow-ink:#e6c884; --yellow-wash:#2a2214;
    --red:#e0879a; --red-ink:#e8a3b0; --red-wash:#2c1a1f;
  }
}
:root[data-theme="dark"]{
  --ground:#0b0c0e; --sheet:#191b1f; --thumb:#2c3038;
  --ink:#f4f5f6; --ink-soft:#9ba2ac; --ink-faint:#6b7280;
  --hairline:#262930; --field:#202329;
  --btn-bg:#f4f5f6; --btn-fg:#16181c; --ring:rgba(244,245,246,.14);
  --sheet-border:#262930;
  --shadow:0 1px 2px rgba(0,0,0,.4), 0 26px 64px -14px rgba(0,0,0,.6);
  --blue:#7cc0f5; --blue-ink:#9dc9f7; --blue-wash:#172a38;
  --yellow:#e0b657; --yellow-ink:#e6c884; --yellow-wash:#2a2214;
  --red:#e0879a; --red-ink:#e8a3b0; --red-wash:#2c1a1f;
}
:root[data-theme="light"]{ color-scheme:light; }
```
