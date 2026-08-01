---
name: tunnel-a-sheet
description: The calm-sheet format for tunnel artifacts — one centred white sheet, system font, one ink pill, no colour and no boxes. The family's north star and the reference implementation of tunnel-a-base. Invoke when the job is ONE thing at a time via tunl `seed(type:"html")`: a dialog/sheet, a single decision or confirmation, a short note or receipt, a quiet announcement, a small form, an invite/share. "As calm as the front door." NOT for dense reports, running logs, or multi-section decks — those have their own tunnel-a-<format> skills. Answers "what makes an artifact simple" and ships a copy-paste template.
user-invocable: false
---

# tunnel-a-sheet — the calm-sheet format

## Inherits — tunnel-a-base

This format **is** the calm baseline — the reference the rest of the family calibrates against
(see the density ladder + format index in `tunnel-a-base`). It adds nothing: the tokens in
the template are exactly tunnel-a-base's token block, and the nine rules below are the base
restraint rules in their purest form. Every other `tunnel-a-<format>` is this sheet plus only
the structure its purpose earns.

**The template is at the bottom of this skill** — a complete, self-contained, seedable artifact. Adapt the body slot; keep the chrome. Ported verbatim from the Fellows modal system ("as calm as the front door") — the sign-in screen's restraint on a standalone page.

## When to use — and when a busier sibling is correct

Reach for the calm sheet when the content is **one thing at a time**: a confirmation, a single decision or choice, a short note or receipt ("done — here's what shipped"), a quiet announcement, a small form (new X, rename, invite), a share/grant sheet. A few lines of body and at most one primary action.

Do NOT force these into it — the busier format carries structure the sheet would strip (full index in `tunnel-a-base`):
- **Dense data / results / metrics / a findings log** → `tunnel-a-report` (tables + verdict colour earn their keep).
- **A running, appendable record** → `tunnel-a-log`.
- **A branded launch / feature announcement** → `tunnel-a-brief`.
- **A long-form, multi-section pitch or strategy** → `tunnel-a-deck` (cover, numbered sections, at most one diagram).
- **Editorial / narrative / manifesto voice** → `tunnel-an-essay` (display serif + mono).
- **A plain readable document** → `tunnel-a-doc`.

The test: if the reader must **compare, scan, or absorb structured data**, it is not a calm sheet. If they must **read one thing and maybe press one button**, it is.

## What makes it simple — the nine rules (the discipline)

This is the answer to "what makes the template simple," written as rules. Each names what the busy siblings do instead (the retrospective report and the capital-allocation deck are the reference "against" cases).

1. **One typeface. No display face.** System sans only (`ui-sans-serif, -apple-system, …`); mono appears only as a sigil (`#`, `@`). Size and weight do all the work. *Busy deck: adds a serif for headings — three families.*
2. **One loud thing per sheet.** Exactly one ink (near-black) element — the primary pill. Everything else is grey and recedes. *Busy report: four semantic accents (green/red/amber/blue) all shouting at once.*
3. **No colour as decoration.** The palette is ~6 greys + white + one ink. No accent hue is used to style UI. *Busy deck: blue/amber/red each with -soft/-ink variants, gradients, color-mix borders.*
4. **Distinction by form, not hue.** Person vs agent = filled pill vs outlined pill, never a colour code. *Busy report: colour-codes verdicts, quadrants, pills.*
5. **Structure by whitespace + hairlines, not boxes.** Content is separated by space and 1px rules — not bordered/rounded cards, tiles, tables, or banners. There is exactly one container: the sheet. *Busy deck: every item is a bordered card / tile / matrix cell.*
6. **Sentence case. No uppercase micro-labels, no mono labels.** Titles read like a sentence; the channel name is coloured, not set in mono. *Busy siblings: mono `text-transform:uppercase; letter-spacing:.12em` eyebrows and tags everywhere.*
7. **Say less.** No subtitle or helper text unless it carries something the title and body cannot. Obvious needs no caption. *Busy deck: a lede under every heading.*
8. **One soft shadow, consistent radii, generous padding.** A single shadow token; radii 12 / 20 / 999; ~30px sheet padding. No stacked shadows, insets, or gradient rules. *Busy deck: inset shadows, gradient rules, layered borders.*
9. **No motion beyond a single rise; no diagrams.** One entrance transition (reduced-motion-guarded). No scroll-reveal, no SVG illustration, no metaphor art. *Busy deck: IntersectionObserver fade-ins + hand-drawn SVG diagrams.*

The through-line: **subtract until only the message and one action remain.** If you are adding a colour, a border, or a label, ask what it carries that space couldn't — usually nothing.

## Contrast at a glance

| Axis | Calm sheet (this) | Busy report / deck (not this) |
|---|---|---|
| Font families | 1 (system sans) | 2–3 (+ serif display, + mono labels) |
| Accent colours | 0 (ink is the only "loud") | 4 semantic hues + soft/ink variants |
| Containers | 1 sheet | cards, tiles, tables, banners, matrices |
| Labels | sentence case, no eyebrows | uppercase mono eyebrows + tags |
| Motion / art | one rise, no art | scroll-reveal, SVG diagrams |
| Right when | one thing + one action | structured data / a long argument |

## Tokens

The tokens are tunnel-a-base's token block — the template below inlines exactly that block (light + `@media (prefers-color-scheme:dark)` + `:root[data-theme="dark"]`, so it is theme-aware in both auto and explicit-toggle themes). Copy them verbatim; do not invent tokens. The sheet uses the **neutrals only** — no data primary.

## Primitives

All in the template below, ready to drop into the `.m-body` slot: `.input`, `.named` (sigil + input), `.seg` (segmented toggle — grey track, raised thumb, never black), `.addrow` + `.tick` (loud only when ready), `.roster`/`.person`/`.ava` (filled person vs `.ava.agent` outlined). Two worked bodies are in the template comments: a **form** ("New channel") and a **share** (toggle + add + roster).

## Seeding it as a tunnel artifact

Pass the whole file as the HTML body to `seed(type:"html", …)`. It is already:
- **Self-contained / CSP-safe** — system font stack, no webfont round-trip, no external CSS/JS/images. Keep it that way; do not add a Google Font or a CDN.
- **Theme-aware** — light + dark tokens included.
- **Responsive** — the sheet is `min(432px,100%)` and centres on any width.

When adapting: change the title, the body slot, and the action label. Do not wrap the body in a card, do not add an accent colour, do not add a second primary button.

## Palette-law note

Fully compliant with the wildreason palette law (blue/yellow/red/black + greys, green banned): the calm sheet uses **no hue accent at all** — the single loud element is ink/near-black. The person/agent avatars carry a config/identity colour on the monogram (the shared Avatar-pill convention), which is data, not decorative UI chrome. Green never appears.

## The template

Complete and seedable as-is. There is no separate `template.html` file — this block IS
the template, so it travels wherever this skill travels. Adapt the body slot; keep the
chrome.

```html
<!--
  minimal-sheet — the calm-sheet tunnel-artifact template.
  Self-contained: system fonts only (no webfont round-trip), no external CSS/JS,
  light + dark tokens, one centred sheet on a quiet ground. Seed the whole file as
  the HTML body of a tunnel artifact. Adapt ONLY the body slot; keep the chrome.
  Every value below is ported verbatim from the Fellows modal system.
-->
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
  :root{
    --ground:#ffffff; --sheet:#ffffff; --thumb:#ffffff;
    --ink:#12151a; --ink-soft:#5b6470; --ink-faint:#9aa1ab;
    --hairline:#e9ebed; --field:#f5f6f8;
    --btn-bg:#12151a; --btn-fg:#ffffff; --ring:rgba(18,21,26,.10);
    --sheet-border:transparent;
    --shadow:0 1px 2px rgba(18,21,26,.05), 0 26px 64px -14px rgba(18,21,26,.22);
    --font:ui-sans-serif,-apple-system,"SF Pro Display","SF Pro Text","Segoe UI",Roboto,Helvetica,Arial,sans-serif;
    --mono:ui-monospace,"SF Mono",Menlo,Consolas,monospace;
  }
  @media (prefers-color-scheme:dark){
    :root{
      --ground:#0b0c0e; --sheet:#191b1f; --thumb:#2c3038;
      --ink:#f4f5f6; --ink-soft:#9ba2ac; --ink-faint:#6b7280;
      --hairline:#262930; --field:#202329;
      --btn-bg:#f4f5f6; --btn-fg:#16181c; --ring:rgba(244,245,246,.14);
      --sheet-border:#262930;
      --shadow:0 1px 2px rgba(0,0,0,.4), 0 26px 64px -14px rgba(0,0,0,.6);
    }
  }
  :root[data-theme="dark"]{
    --ground:#0b0c0e; --sheet:#191b1f; --thumb:#2c3038;
    --ink:#f4f5f6; --ink-soft:#9ba2ac; --ink-faint:#6b7280;
    --hairline:#262930; --field:#202329;
    --btn-bg:#f4f5f6; --btn-fg:#16181c; --ring:rgba(244,245,246,.14);
    --sheet-border:#262930;
    --shadow:0 1px 2px rgba(0,0,0,.4), 0 26px 64px -14px rgba(0,0,0,.6);
  }

  *{box-sizing:border-box}
  body{margin:0;min-height:100vh;background:var(--ground);color:var(--ink);
    font-family:var(--font);line-height:1.5;letter-spacing:-.006em;
    -webkit-font-smoothing:antialiased;
    display:flex;align-items:center;justify-content:center;padding:40px 20px}

  /* THE SHELL — the only chrome. New bodies, never new chrome. */
  .sheet{width:min(432px,100%);background:var(--sheet);border:1px solid var(--sheet-border);
    border-radius:20px;box-shadow:var(--shadow);padding:30px 30px 26px;
    animation:rise .5s cubic-bezier(.2,.7,.2,1) both}
  @keyframes rise{from{opacity:0;transform:translateY(10px) scale(.985)}to{opacity:1;transform:none}}
  @media (prefers-reduced-motion:reduce){.sheet{animation:none}}

  .m-title{font-size:22px;font-weight:600;letter-spacing:-.022em;line-height:1.18;margin:0;color:var(--ink)}
  .m-title .hash{color:var(--ink-soft);font-weight:500}      /* # channel-name, in the title, coloured not mono */
  .m-sub{font-size:14.5px;color:var(--ink-soft);margin:8px 0 0;line-height:1.5;max-width:40ch} /* only if it EARNS its place */
  .m-body{margin-top:22px;display:flex;flex-direction:column;gap:12px;font-size:15px;color:var(--ink-soft)}
  .m-body p{margin:0}

  /* ACTIONS — one loud thing, the rest quiet. */
  .actions{margin-top:26px;display:flex;justify-content:flex-end;align-items:center;gap:6px}
  .btn{font-family:var(--font);font-size:14.5px;font-weight:600;letter-spacing:-.01em;
    border:none;border-radius:999px;cursor:pointer;transition:background .12s,transform .06s,filter .12s}
  .btn:focus-visible{outline:2px solid var(--ink);outline-offset:2px}
  .btn-quiet{background:transparent;color:var(--ink-soft);padding:11px 15px;font-weight:500}
  .btn-quiet:hover{background:var(--field);color:var(--ink)}
  .btn-primary{background:var(--btn-bg);color:var(--btn-fg);padding:11px 22px}
  .btn-primary:hover{filter:brightness(1.08)}
  .btn-primary:active{transform:translateY(1px)}

  /* ---- OPTIONAL BODY PRIMITIVES — drop into .m-body as needed, delete the rest ---- */

  /* plain text input */
  .input{width:100%;background:var(--field);border:1px solid transparent;border-radius:12px;
    padding:13px 14px;font-family:var(--font);font-size:15px;color:var(--ink);line-height:1.3;
    letter-spacing:-.006em;transition:border-color .12s,background .12s,box-shadow .12s}
  .input::placeholder{color:var(--ink-faint)}
  .input:focus{outline:none;background:var(--sheet);border-color:var(--ink);box-shadow:0 0 0 3px var(--ring)}

  /* named input: a leading sigil (#, @) the placeholder can't carry */
  .named{display:flex;align-items:center;background:var(--field);border:1px solid transparent;
    border-radius:12px;padding:0 14px;transition:border-color .12s,background .12s,box-shadow .12s}
  .named:focus-within{background:var(--sheet);border-color:var(--ink);box-shadow:0 0 0 3px var(--ring)}
  .named .sigil{font-family:var(--mono);font-size:15px;color:var(--ink-faint);padding-right:8px}
  .named .input{background:none;border:none;padding:13px 0;box-shadow:none!important}

  /* segmented toggle: grey track, raised thumb — never black */
  .seg{display:inline-flex;background:var(--field);border-radius:999px;padding:3px;align-self:flex-start}
  .seg button{font-family:var(--font);font-size:13px;font-weight:500;border:none;background:none;
    color:var(--ink-faint);padding:7px 15px;border-radius:999px;cursor:pointer;letter-spacing:-.005em}
  .seg button[aria-pressed="true"]{background:var(--thumb);color:var(--ink);font-weight:600;
    box-shadow:0 1px 2px rgba(18,21,26,.14)}

  /* add row: input + a compact tick (not a pill); tick goes loud only when ready */
  .addrow{display:flex;gap:8px;align-items:center}
  .addrow .input{flex:1}
  .tick{flex:none;width:42px;height:42px;border-radius:12px;background:var(--field);
    color:var(--ink-faint);border:none;display:grid;place-items:center;cursor:pointer;
    transition:background .12s,color .12s}
  .tick:hover{color:var(--ink)}
  .tick.ready{background:var(--btn-bg);color:var(--btn-fg)}
  .tick svg{width:17px;height:17px;fill:none;stroke:currentColor;stroke-width:1.9;
    stroke-linecap:round;stroke-linejoin:round}

  /* roster: recessive rows; person = filled pill, agent = outlined pill (distinction by FORM, not hue) */
  .roster{margin-top:6px;display:flex;flex-direction:column}
  .person{display:flex;align-items:center;gap:11px;padding:8px 2px}
  .person + .person{border-top:1px solid var(--hairline)}
  .ava{display:inline-flex;align-items:center;justify-content:center;height:24px;min-width:36px;
    padding:0 9px;border-radius:999px;font-size:11px;font-weight:700;color:var(--sheet);flex:none;text-transform:uppercase}
  .ava.agent{background:transparent!important;color:var(--ink-soft);border:1.5px solid var(--ink-faint)}
  .pname{font-size:14.5px;color:var(--ink)}
  .prole{font-size:12.5px;color:var(--ink-faint);margin-left:auto}
  .pdrop{color:var(--ink-faint);cursor:pointer;line-height:1;font-size:15px;width:24px;height:24px;
    display:grid;place-items:center;border-radius:8px}
  .pdrop:hover{background:var(--field);color:var(--ink)}
</style>

<div class="sheet" role="dialog" aria-labelledby="sheet-title">

  <!-- TITLE: sentence case. Optional coloured #chip. No uppercase micro-label above it. -->
  <h1 class="m-title" id="sheet-title">Title goes here</h1>

  <!-- SUBTITLE: include ONLY if it carries something the title + body can't. Usually delete it. -->
  <!-- <p class="m-sub">One quiet line, only when it earns its place.</p> -->

  <!-- BODY: the only part that changes. Swap in ONE of the patterns below. -->
  <div class="m-body">
    <p>Say the one thing this sheet is for. A sentence or two, not a wall.</p>

    <!-- FORM pattern (e.g. "New channel"):
    <div class="named"><span class="sigil">#</span>
      <input class="input" placeholder="channel-name" aria-label="Name" spellcheck="false"></div>
    <input class="input" placeholder="Add a topic — optional" aria-label="Topic">
    -->

    <!-- SHARE pattern (segmented toggle + add row + roster):
    <div class="seg" role="group" aria-label="Kind">
      <button aria-pressed="true">Person</button><button aria-pressed="false">Agent</button></div>
    <div class="addrow">
      <input class="input" placeholder="name" aria-label="Name" spellcheck="false">
      <button class="tick ready" aria-label="Add"><svg viewBox="0 0 16 16"><path d="M3.5 8.5l3 3 6-7"/></svg></button></div>
    <div class="roster" aria-label="People with access">
      <div class="person"><span class="ava" style="background:var(--ink-soft)">MA</span>
        <span class="pname">maya</span><span class="prole">person</span><span class="pdrop" title="Remove">&times;</span></div>
      <div class="person"><span class="ava agent">PR</span>
        <span class="pname">pr-reviewer</span><span class="prole">agent</span><span class="pdrop" title="Remove">&times;</span></div>
    </div>
    -->
  </div>

  <!-- ACTIONS: exactly one primary (ink pill). Quiet Cancel/Done to its left, or drop it entirely. -->
  <div class="actions">
    <button class="btn btn-quiet">Cancel</button>
    <button class="btn btn-primary">Confirm</button>
  </div>

</div>
```
