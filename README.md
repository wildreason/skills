# wildreason/skills

Agent skills for engineering workflows. Today that means one family: the
**tunnel artifact formats** — seven ways to shape a document, and the shared
foundation they all inherit.

## Say the word, get the format

Seven words. They do not change. The styling inside them will.

| Say | For | Not for |
|---|---|---|
| `sheet` | one thing at a time — a decision, a receipt, a short note | anything dense |
| `doc` | prose rendered legibly — a readme, a reference, a how-to | data, persuasion |
| `brief` | a launch note, ship note, or status one-pager | a multi-section case |
| `essay` | a made argument, read top to bottom | a record, a lookup |
| `deck` | a case argued section by section, cover to close | numbers to look up |
| `log` | entries appended over time, one URL forever | a one-shot page |
| `report` | results, verdicts, tables to trust in ten seconds | a narrative |

The "Not for" column is the fast reject. A format that tells you when to walk
away is quicker to choose than one that only sells itself. If two fit, take the
calmer one — drifting up the density ladder is the common failure, drifting down
is not.

`tunnel-a-base` is the shared foundation: the token set, the type and build
rules, the restraint discipline. Every format inherits it and declares
only its deltas. It is never picked on its own.

`guide/tunnel-an-artifact` is the operating manual — sharing, access, versioning,
closing, media. It is **not** a format and is deliberately outside `formats/`, so
it never competes when you are choosing how a document should look.

## The vocabulary is capped

**Seven formats. That is the number.** `tools/check-names.py` fails the build if
it changes, so an eighth name has to be a decision someone makes on purpose in a
commit — not something that accumulates.

The reason is not tidiness. These words are the interface: someone learns to say
"make it a deck" and that has to keep meaning one thing. Styling underneath is
expected to keep improving; the word is the part that holds still.

One word, one thing. No aliases — a second name for the same body is a second
word to learn and, on a harness that de-duplicates skill directories, it can
silently replace the canonical one on the surface an agent actually sees.

## Install

```
git clone https://github.com/wildreason/skills.git && skills/tools/install.sh
```

`install.sh` copies the skills where the harness reads them and writes a **pin**
next to each one — `<name>.head.json` with `content_sha256`, `pulled_at` and
`source: git:wildreason/skills@<sha>`. That format is openlap's, adopted rather
than invented; a second pin format would be a defect.

It also reports any pin it finds that another rail wrote, instead of replacing it
quietly. The installer is the only thing that sees both rails, so that is where
detection belongs. It reports; it does not gate.

`~/.claude/skills` is often a symlink into another tool's managed tree (openlap
materializes into `~/.openlap/skills`, a git repo with no remote). The installer
copies *into* it. Never clone over it — a bare `git pull` there is a silent no-op
and cloning fights whoever manages that tree.

Once the files are there, selection is automatic — the harness surfaces each
skill's description and the model picks. There is nothing to invoke.

## Publish

```
tools/publish.sh
```

**Editing this repo changes nothing about what any agent loads.** Most boxes —
including the author's own — read the copy in openlap's skill store, not a
checkout. Until `publish.sh` runs, a fixed repo and an unfixed reader coexist:
measured 2026-08-01, four hours after the colour reconcile went green here, two
other boxes were still loading `green 24 / violet 18`.

The script gates → installs → pushes → **pulls the store's bytes back down** →
verifies `repo == delivered`, per file, and exits 1 on any mismatch. That last
step is the point; the first four all print success against a store that took
nothing. It installs before pushing because `openlap push --skill` reads
`~/.claude/skills`, never this repo — pushing without that ships stale bytes,
a mistake this repo has already made once.

## Gates

Both run on the repo, both label every rule as **INVARIANT** or **PROXY**,
because an unlabelled green gets read a year later as proof of something it
never checked.

```
tools/check-tokens.sh    no colour outside the token block; no skill shadows a base token name
tools/check-names.py     no dangling names; exactly seven formats; the guide stays out of the pick lane
```

**Scope limit, and it is structural.** These read *this repo*. The set of skills
an agent actually sees is assembled from repos nobody owns together, so a green
run means "none of ours collide" — never "no collisions exist".

## Layout

```
formats/     the seven, plus tunnel-a-base
guide/       tunnel-an-artifact — the operating manual, not a format
tools/       the gates
```

**Every skill is exactly one `SKILL.md`.** There are no companion files: the token
set lives as a fenced block inside `tunnel-a-base`, and the sheet template inside
`tunnel-a-sheet`. That is deliberate — openlap's skill store cannot accept
companion files (`OLP-430`), so a skill that needs one could never be distributed.
Eliminating them beat keeping a second copy plus a rule to hold the two equal.
