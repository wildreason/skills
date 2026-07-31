---
name: tunnel-a-doc
description: The plain-document format for tunnel artifacts — render markdown as a clean, readable page. Reading-first, no data and no persuasion: a doc, a reference, a readme, a how-to, "just make this readable." The closest format to tunnel-a-sheet, only longer. Invoke when the job is to present prose/markdown legibly with nothing to decode or decide. Inherits tunnel-a-base.
user-invocable: false
---

## Inherits — tunnel-a-base

Copy the tokens from `tunnel-a-base/tokens.css` and follow its type / build / restraint rules.
Doc is the **calmest reading rung** — nearly the sheet, only longer. Its only deltas:

- **A reading measure** — body capped ~62–68ch for line length.
- **Blue links** — links use `--blue`; that is the *only* colour on the page.
- Hairline rules between sections; **no cards, no tables, no data colour, no serif.**

The "six colors" the legacy body describes below map to base neutrals + the one `--blue` link;
treat any inline hex as **superseded by tokens.css**. Everything else base says holds.

# tunnel-a-doc — the plain-document format

Build HTML documents that look like Apple support pages. Black text, white background, blue links, system fonts. The absence of design decisions is the design decision.

## The Palette

Six colors. Each has exactly one job.

```css
:root {
  --text:        var(--ink);  /* primary text — one black, not three */
  --secondary:   var(--ink-soft);  /* secondary text, labels, captions */
  --tertiary:    var(--ink-faint);  /* placeholders, disabled, hints */
  --surface:     var(--field);  /* backgrounds, code blocks, hover */
  --border:      var(--hairline);  /* borders, dividers, rules */
  --border-light:var(--hairline);  /* subtle separators between items */
  --link:        var(--blue);     /* links, interactive elements only */
  --highlight:   var(--yellow);  /* search highlight */
}
```

Rules:
- Link blue (`var(--blue)`) is for interactive elements only. Never headings, never decorative.
- Functional colors survive: diff red/green, error states, success states. Brand colors do not.
- Never more than one shade of any gray for text. `--secondary` and `--tertiary` are the only grays.

## Typography

System fonts. Zero network requests.

```css
body {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display',
               'Helvetica Neue', Helvetica, Arial, sans-serif;
  font-size: 17px;
  line-height: 1.47059;
  font-weight: 400;
  color: var(--ink);
  -webkit-font-smoothing: antialiased;
}
```

Monospace:
```css
code, pre, .mono {
  font-family: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, monospace;
}
```

The values `17px` and `1.47059` are Apple's production numbers. Not rounded. Measured.

Never load Google Fonts. The fastest font is the one already on the machine.

## Heading Scale

```css
h1, h2, h3 {
  font-weight: 700;
  color: var(--ink);
  letter-spacing: -0.005em;
}

h1 { font-size: 40px; line-height: 1.1;     margin: 2.5rem 0 0.25rem; }
h2 { font-size: 32px; line-height: 1.125;   margin: 2.5rem 0 0.15rem; }
h3 { font-size: 24px; line-height: 1.16667; margin: 2rem  0 0.1rem;  }
```

Spacing principle (Gestalt proximity): large top margin separates from previous section, tiny bottom margin binds heading to its content. A heading belongs to what follows, not what precedes.

```css
p { margin: 1em 0; }
```

Use `1em`, not `0.4rem`. Paragraphs need air.

## Code Blocks

Borderless gray pills. No language header. Copy button on hover.

```css
.code-block {
  margin: 1.5rem 0;
  border: none;
  border-radius: 12px;     /* pill shape, not sharp box */
  background: var(--field);
  position: relative;
  overflow-x: auto;
}

.code-block pre {
  margin: 0;
  padding: 1.25rem 1.5rem;  /* generous interior */
  overflow-x: auto;
  font-family: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, monospace;
}

.code-block code {
  font-family: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, monospace;
  font-size: 14px;
}
```

Copy button — text, not icon:
```css
.copy-btn {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  background: var(--sheet);
  color: var(--ink);
  border: none;
  border-radius: 6px;
  padding: 0.35rem 0.75rem;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  opacity: 0;
  transition: opacity 0.15s;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}
.code-block:hover .copy-btn { opacity: 1; }
.copy-btn:hover { background: var(--hairline); }
```

The copy button says "Copy" and "Copied", not a unicode glyph. Plain text > clever icons.

Hide the language label entirely:
```css
.code-lang { display: none; }
```

## Inline Code

```css
code.inline {
  font-family: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, monospace;
  color: var(--ink);
  background: var(--field);
  border: none;              /* no border on inline code */
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  font-size: 0.875em;
}
```

## Links

```css
a { color: var(--blue); text-decoration: none; }
a:hover { text-decoration: underline; }
```

No underline by default. Underline on hover. Blue is enough signal.

Tooltips for external links:
```css
a[target="_blank"]:hover::after {
  content: attr(title);
  position: absolute;
  bottom: 100%;
  left: 0;
  background: var(--ink);
  color: var(--sheet);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 12px;
  white-space: nowrap;
  box-shadow: 0 2px 8px rgba(0,0,0,0.12);
}
```

## Tables

```css
.table-scroll {
  overflow-x: auto;
  margin: 1.5rem 0;
  border: 1px solid var(--hairline);
  border-radius: 6px;
}

table { border-collapse: collapse; width: 100%; min-width: 100%; }

th, td {
  border: 1px solid var(--hairline);
  padding: 0.4rem 0.75rem;
  text-align: left;
}

th {
  background: var(--field);
  color: var(--ink);
  font-weight: 600;
  font-size: 13px;
}
```

Sort indicator uses link blue:
```css
.sortable-th:hover { background: var(--hairline); }
.sort-icon { color: var(--hairline); }
.sortable-th.asc .sort-icon,
.sortable-th.desc .sort-icon { color: var(--blue); }
```

## Layout

```css
.container {
  max-width: 740px;
  margin: 0 auto;
  padding: 3rem 1.5rem;
}
```

740px for prose. Not 960, not 1200. Prose has an optimal line length (~65-75 characters at 17px).

## TOC Sidebar

Borderless. Active state is bold black + dark left bar, not colored highlight.

```css
.toc {
  position: fixed;
  top: 0; left: 0;
  width: 280px;
  height: 100vh;
  background: var(--sheet);
  border-right: none;        /* no border separating TOC */
  padding: 2.5rem 0;
  overflow-y: auto;
}

.toc-link {
  display: block;
  padding: 0.4rem 1.5rem;
  color: var(--ink-faint);            /* tertiary until active */
  text-decoration: none;
  font-size: 15px;
  border-left: 3px solid transparent;
  transition: all 0.15s;
  line-height: 1.4;
}
.toc-link:hover { color: var(--ink); }
.toc-link.active {
  color: var(--ink);
  font-weight: 600;
  border-left-color: var(--ink);  /* black bar, not blue */
}
```

Layout when TOC is present — nudge content, don't push it:
```css
.container.has-toc {
  max-width: 740px;
  margin: 0 auto;
  transform: translateX(140px);   /* nudge right */
  transition: transform 0.2s;
}

/* TOC collapsed: content returns to center */
.toc.collapsed ~ main.has-toc { transform: none; }
```

`transform` instead of `margin-left` = smooth centering transition when TOC closes.

## Images

```css
.img-wrapper { margin: 1.5rem 0; }
.img-wrapper img {
  max-width: 100%;
  border-radius: 6px;
  border: 1px solid var(--hairline);
  cursor: pointer;
  transition: max-width 0.2s;
}
.img-caption {
  color: var(--ink-soft);
  font-size: 12px;
  margin-top: 0.3rem;
}
```

## Search Overlay

```css
.search-overlay {
  background: rgba(0,0,0,0.1);  /* barely visible backdrop */
}

.search-box {
  background: var(--sheet);
  border: 1px solid var(--hairline);
  border-radius: 8px;
}

.search-box input {
  color: var(--ink);
  font-size: 17px;
  border: none;
  background: transparent;
}
.search-box input::placeholder { color: var(--ink-faint); }

/* Highlight matches in yellow, not brand blue */
mark, .search-highlight {
  background: var(--yellow);
  color: var(--ink);
  border-radius: 2px;
}
```

## Lists

```css
.list-item { padding-left: 1.5rem; margin: 0.5em 0; }
.bullet { color: var(--ink); }   /* black bullets, not blue */
.list-num { color: var(--ink); font-weight: 600; }
```

## Horizontal Rules

```css
hr {
  border: none;
  border-top: 1px solid var(--hairline);
  margin: 2rem 0;
}
```

## Strong and Emphasis

```css
strong { color: var(--ink); font-weight: 600; }
em { font-weight: 600; font-style: normal; }  /* semibold, not italic */
```

Apple uses semibold for emphasis, not italic. Italic breaks the visual rhythm of system fonts.

## The Seven Principles

1. **System fonts, zero requests.** `-apple-system` stack. Never import fonts. The fastest asset is the one that doesn't load.

2. **One color per role.** Text gets one black. Secondary gets one gray. Links get one blue. If you have three shades of navy competing for "dark text," you have no palette.

3. **Functional color survives, brand color dies.** Diff red/green, error states, success badges — these encode meaning. Brand accent on headings, colored bullets, tinted backgrounds — these encode identity. Kill identity, keep meaning.

4. **Proximity binds headings to content.** Large top margin (2.5rem) separates from previous section. Tiny bottom margin (0.25rem) couples heading to its paragraph. The heading belongs to what follows.

5. **Borders are optional.** Code blocks: no border, `12px` radius. TOC sidebar: no border-right. Inline code: no border. If the background contrast is sufficient, the border is noise.

6. **Progressive disclosure on hover.** Copy buttons appear on hover. Anchor links appear on hover. Tooltips appear on hover. Chrome that isn't needed right now shouldn't be visible right now.

7. **Transform over margin for layout shifts.** `translateX(140px)` instead of `margin-left: 260px`. Transforms are GPU-composited and animate smoothly. Margins trigger layout reflow.

## Minimal HTML Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document Title</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: var(--sheet);
      color: var(--ink);
      font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text',
                   'Helvetica Neue', Helvetica, Arial, sans-serif;
      font-size: 17px;
      line-height: 1.47059;
      -webkit-font-smoothing: antialiased;
    }
    .container { max-width: 740px; margin: 0 auto; padding: 3rem 1.5rem; }
    h1, h2, h3 { font-weight: 700; color: var(--ink); letter-spacing: -0.005em; }
    h1 { font-size: 40px; line-height: 1.1; margin: 2.5rem 0 0.25rem; }
    h2 { font-size: 32px; line-height: 1.125; margin: 2.5rem 0 0.15rem; }
    h3 { font-size: 24px; line-height: 1.16667; margin: 2rem 0 0.1rem; }
    p { margin: 1em 0; }
    a { color: var(--blue); text-decoration: none; }
    a:hover { text-decoration: underline; }
    strong { font-weight: 600; }
    em { font-weight: 600; font-style: normal; }
    code {
      font-family: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, monospace;
      background: var(--field); padding: 0.15rem 0.4rem; border-radius: 4px;
      font-size: 0.875em; border: none;
    }
    pre {
      background: var(--field); border: none; border-radius: 12px;
      padding: 1.25rem 1.5rem; overflow-x: auto; margin: 1.5rem 0;
    }
    pre code { background: none; padding: 0; font-size: 14px; }
    hr { border: none; border-top: 1px solid var(--hairline); margin: 2rem 0; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid var(--hairline); padding: 0.4rem 0.75rem; text-align: left; }
    th { background: var(--field); font-weight: 600; font-size: 13px; }
    img { max-width: 100%; border-radius: 6px; }
  </style>
</head>
<body>
  <main class="container">
    <!-- content -->
  </main>
</body>
</html>
```

Copy this template. It works. Forty lines of CSS for a complete document renderer.
