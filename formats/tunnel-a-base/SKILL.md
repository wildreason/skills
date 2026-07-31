---
name: tunnel-a-base
description: The shared design foundation every tunnel-a-<format> inherits — the token set (tokens.css), the type + build rules, and the restraint discipline that makes the tunnel-artifact family read as one system. Not usually invoked alone; a format skill (tunnel-a-sheet / -doc / -report / -log / -brief / -essay / -deck) pulls it in. Read it to pick the right format for a purpose, or to author a new one.
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

1. **Tokens.** Copy `tunnel-a-base/tokens.css` verbatim into the artifact's `<style>`. Neutrals are always on; the data primaries (`--blue/--yellow/--red`) are opt-in and for **meaning only**. Do not invent tokens or hardcode hex — if a value isn't in tokens.css, it doesn't ship.
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
