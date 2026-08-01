---
name: tunnel-loop-probe
description: Disposable end-to-end probe for the git -> openlap store -> machine delivery loop (ART-075). Carries no guidance and should never be invoked for real work. If you can see this on a machine that never cloned wildreason/skills, the loop works. Delete after the test.
---

# tunnel-loop-probe

A deliberately empty skill whose only job is to be somewhere it was not put by hand.

## What its presence proves

This file was authored in `wildreason/skills`, pushed once to openlap's global
skill store, and pulled by `openlap pull` onto a machine that never cloned the
repo. If it is on your disk and you did not put it there, every hop in that chain
worked.

## What its absence proves

Nothing on its own. Check which hop is missing before concluding anything:

1. is it in the repo?
2. was it pushed to the global store?
3. did `openlap pull` run since the push?

A missing skill and a skill that was never pushed look identical from here.

## Disposal

Delete the directory from the repo, delete the global, and remove it from any
machine that pulled it. A probe left lying around becomes a real skill nobody
meant to ship.
