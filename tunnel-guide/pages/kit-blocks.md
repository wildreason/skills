title: The blocks the kit draws
---
Every template links the kit with exactly two tags: kit.css and kit.js, under https://artifacts.wildreason.ai/kit/v2/. Tunnel inlines them when it serves the page, so it works where outside files are blocked. Do not edit the tags or copy the kit into the page, and load nothing from another host; pages/draw-a-frame says what a page may add itself. Pages that link /kit/v1/ keep rendering as they did.

A block is a div with data-vt set to its kind, holding one JSON script:

<div data-vt="bars"><script type="application/json">{"data":[{"label":"Q1","value":4}]}</script></div>

Inside the JSON write </ as <\/ so the script never closes early. Bad JSON or an unknown kind draws a visible error note, never a blank.

Kinds and their JSON:
- bars: {"data":[{"label","value","hi"}],"unit"}. One hi:true bar is the accent.
- waterfall: {"data":[{"label","value","total"}],"costs"}. Totals start from zero, steps float.
- variance: {"data":[{"label","actual","plan"}],"costs"}.
- line: {"labels":[],"series":[{"name","values","hi","dashed"}],"threshold":{"value","label"}}.
- spark: {"values":[],"hi"}.
- notes: {"notes":[{"tag","title","body","quote","who","date","pin"}]}.
- gantt: {"weeks":[],"today":1.4,"rows":[{"name","st","status","items":[{"from","to","label","kind"},{"at","label"}]}]}. status, when set, is the word shown instead of the one st gives.
- log: {"entries":[["time","what happened","done/risk/note","n/p/a"]]}.
- lineitems: {"lines":[{"label","plan","actual","trend":[]}],"costs","unit"}.

costs:true means over plan is bad (spend); costs:false means under plan is bad (revenue).

A board is not a block: draw it as HTML, a main.canvas holding section.lane > div.frames > article.frame (.frame.wide for a wide one). The kit pans and zooms it; see pages/draw-a-frame.

Status is a word. In gantt, st p, h, f or n shows On track, At risk, Blocked or Not started, with At risk and Blocked in the accent. In log, the third field is the word and the fourth (n, p or a) styles its chip.

Every item the kit draws carries data-vt-key: "#" plus its id when the item has an id, otherwise its index path ("2", "1.0"). Give items an id when a review mark should follow them through a reorder; an index key follows the position instead.
