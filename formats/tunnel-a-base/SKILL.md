---
name: tunnel-a-base
description: THE ENTRY POINT for tunnel artifact pages, and the shared kit every tunnel-a-<format> inherits -- the copper palette, the three fonts, the page rules (finding titles, answer first, Setup, one accent, a takeaway and a source under every figure) and the chart blocks. Start here when the SHAPE is not yet decided: this skill names the seven shapes and routes you to the one the reader's job earns (tunnel-a-notes / -brief / -timeline / -board / -numbers / -story / -rendition). It answers WHICH shape; the format skill you land on answers how to fill it. Also read it to author a new format.
user-invocable: false
---

# tunnel-a-base -- start here for a page

Tunnel serves the templates, the page rules and the kit. This skill only picks
the shape and points at them.

## Pick the shape from the reader's job, not the topic

| Format | The reader needs to... |
|---|---|
| **tunnel-a-notes** | capture many small things and find the important ones again |
| **tunnel-a-brief** | get the answer and make a decision |
| **tunnel-a-timeline** | see what happens when, and what is stuck |
| **tunnel-a-board** | see every option at once before choosing |
| **tunnel-a-numbers** | understand what the money or metrics say |
| **tunnel-a-story** | care about one idea and remember it |
| **tunnel-a-rendition** | read a fuller story, chapter by chapter |

If two fit, ask what the reader is doing: deciding, exploring, tracking,
checking figures, looking something up, being persuaded, or reading it all.

## Then read the rest from tunnel

1. `templates({action:"guide", topic:"pages"})`: the page rules. Its references
   `pages/kit-blocks` and `pages/charts-and-numbers` hold the blocks and the
   type, colour and chart rules.
2. `templates({action:"get", id:"<shape>"})`: the skeleton, its slots and the
   finish line. The shape's own skill adds only what a template cannot say.
3. Seed it as HTML with `template` set to that id, then
   `templates({action:"check", uri})` before you call it done.

Sharing, access and undo are in `tunnel-an-artifact`.

## Authoring a new format

The vocabulary is capped at seven (`tools/check-names.py`). A new word replaces
an old one in one commit: its skill, its `templates/<word>/`, its row above and
tunnel's shape list. Never keep an old-name alias symlink: the harness keeps the
alphabetically first of de-duplicated names (ART-071).
