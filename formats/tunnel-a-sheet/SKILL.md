---
name: tunnel-a-sheet
description: The calm-sheet format for tunnel artifacts — one centred white sheet, system font, one ink pill, no colour and no boxes. The family's north star and the reference implementation of tunnel-a-base. Invoke when the job is ONE thing at a time via tunl `seed(type:"html")`: a dialog/sheet, a single decision or confirmation, a short note or receipt, a quiet announcement, a small form, an invite/share. "As calm as the front door." NOT for dense reports, running logs, or multi-section decks — those have their own tunnel-a-<format> skills. Answers "what makes an artifact simple" and ships a copy-paste template.
user-invocable: false
---

# tunnel-a-sheet — the calm-sheet format

## Inherits — tunnel-a-base

This format **is** the calm baseline — the reference the rest of the family calibrates against
(see the density ladder + format index in `tunnel-a-base`). It adds nothing: the tokens in
`template.html` are exactly `tunnel-a-base/tokens.css`, and the nine rules below are the base
restraint rules in their purest form. Every other `tunnel-a-<format>` is this sheet plus only
the structure its purpose earns.

**The template is `template.html` in this folder** — a complete, self-contained, seedable artifact. Adapt the body slot; keep the chrome. Ported verbatim from the Fellows modal system ("as calm as the front door") — the sign-in screen's restraint on a standalone page.

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

The tokens are `tunnel-a-base/tokens.css` — the sheet's `template.html` inlines exactly that block (light + `@media (prefers-color-scheme:dark)` + `:root[data-theme="dark"]`, so it is theme-aware in both auto and explicit-toggle themes). Copy them verbatim; do not invent tokens. The sheet uses the **neutrals only** — no data primary.

## Primitives

All in `template.html`, ready to drop into the `.m-body` slot: `.input`, `.named` (sigil + input), `.seg` (segmented toggle — grey track, raised thumb, never black), `.addrow` + `.tick` (loud only when ready), `.roster`/`.person`/`.ava` (filled person vs `.ava.agent` outlined). Two worked bodies are in the template comments: a **form** ("New channel") and a **share** (toggle + add + roster).

## Seeding it as a tunnel artifact

Pass the whole file as the HTML body to `seed(type:"html", …)`. It is already:
- **Self-contained / CSP-safe** — system font stack, no webfont round-trip, no external CSS/JS/images. Keep it that way; do not add a Google Font or a CDN.
- **Theme-aware** — light + dark tokens included.
- **Responsive** — the sheet is `min(432px,100%)` and centres on any width.

When adapting: change the title, the body slot, and the action label. Do not wrap the body in a card, do not add an accent colour, do not add a second primary button.

## Palette-law note

Fully compliant with the wildreason palette law (blue/yellow/red/black + greys, green banned): the calm sheet uses **no hue accent at all** — the single loud element is ink/near-black. The person/agent avatars carry a config/identity colour on the monogram (the shared Avatar-pill convention), which is data, not decorative UI chrome. Green never appears.
