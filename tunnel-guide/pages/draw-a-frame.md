title: How to draw a frame
---
A freeform template gives you a job and a finish line, not a skeleton. The layout is yours. This is how to draw it so it does not come out like every other page.

The bar is a storyboard where every frame carries its own picture. The kit v2 storyboard (three ways to show a replay on a status page) is that bar. Its "The screen" frames are inline SVG mockups of the actual screen. One frame is a live animation. One is a working prototype in a few lines of JS. One is a chart of that option's own numbers. No two frames are the same block with different words in it.

What a frame is
A frame is one thing the reader should see, with a title that says what it shows and one or two lines under it. On a board it is an article.frame inside a lane. On a story it is a step. In a rendition it is a figure in a chapter, and in numbers it is a chart with its finding. The shape tells you what the page is for. It does not tell you how many frames there are or what goes in them.

Draw the picture first
For each frame, ask what the reader would see if this were real, then draw that:
- A screen or a product: an inline SVG mockup of that screen, with the real words and numbers on it. Put it in an img with a data:image/svg+xml URL, or in an inline svg. Give it an alt that says what it shows.
- Something that moves or changes: animate it with CSS in the page's own style tag, and stop the animation under prefers-reduced-motion.
- Something to try: a small working prototype in the page's own script, a few lines, with real controls. Mark its controls data-nopan inside a board canvas, so a drag is a click and not a pan.
- A number that matters: a kit chart (bars, line, variance, waterfall) of that frame's own data, with a unit, a source line and a takeaway.
- A sequence: numbered steps you draw yourself, not three identical cards.
- A quote or a voice: the words, who said them and when.
If two frames would get the same picture, merge them or find what really differs.

What to keep from the kit
Link kit v2 with its two exact tags, and nothing else from another host:
<link rel="stylesheet" href="https://artifacts.wildreason.ai/kit/v2/kit.css">
<script src="https://artifacts.wildreason.ai/kit/v2/kit.js"></script>
The kit gives you type, colour tokens, dark mode, the charts, the canvas (main.canvas, section.lane, div.frames, article.frame, .frame.wide), and review marks that hold through pan and zoom. Your own style and script tags go in the page, using the kit's tokens (var(--ink), var(--mute), var(--sand), var(--cu) for the one accent, var(--bg)) so dark mode follows. A page's own :root token wins over the kit, so you can retune the accent.

The page rules still hold
- The H1 states the finding. Each frame title says what that frame shows.
- One accent colour, on the one thing that carries the message.
- Every figure has a takeaway, and its source line marks sample or estimated numbers.
- It reads at 400px wide and in dark mode. Frames stack on a phone.
- No emoji, no stock blocks, no external fonts, images or scripts.

Check it
Run templates check on the uri. The mechanical tests are the floor: a title, one H1, the kit, nothing external, no emoji. The manual tests are the bar, and a person reads them: every frame or figure carries its own picture, not a stock block; it works at 400px and in dark mode.

Before you call it done, look at the page and ask: if I swapped this page's words onto another page of the same shape, would anyone notice? If not, the frames are not drawn yet.
