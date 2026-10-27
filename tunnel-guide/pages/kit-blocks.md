title: The blocks the kit draws
---
Every template links the kit with exactly two tags: kit.css and kit.js, under https://artifacts.wildreason.ai/kit/v1/. Tunnel inlines them when it serves the page, so it works where outside files are blocked. Do not edit the tags, copy the kit into the page, or add any other stylesheet, script or font. v1 never changes; a new look is a new version at a new URL.

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
- gantt: {"weeks":[],"today":1.4,"rows":[{"name","st","items":[{"from","to","label","kind"},{"at","label"}]}]}.
- log: {"entries":[["time","what happened","done/risk/note","n/p/a"]]}.
- board: {"clusters":[{"name","items":[{"id","title","body","votes","fav","drop"}]}],"links":[["fromId","toId"]]}.
- lineitems: {"lines":[{"label","plan","actual","trend":[]}],"costs","unit"}.

costs:true means over plan is bad (spend); costs:false means under plan is bad (revenue).

Status letters: p proven or on track, h partial or at risk, f failing or blocked, n not started.

Every item the kit draws carries data-vt-key: "#" plus its id when the item has an id, otherwise its index path ("2", "1.0"). Give items an id when a review mark should follow them through a reorder; an index key follows the position instead.
