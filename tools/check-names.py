#!/usr/bin/env python3
"""ART-071 name gate. Run from the repo root: tools/check-names.py

Three rules. Each is labelled PROXY or INVARIANT, per the ART-058 precedent
("a proxy for a token cap -- conservative, not a solved invariant"). An
unlabelled green gets read a year later as proof of something it never checked.

  1. INVARIANT (repo-scoped) -- no dangling name.
     Every tunnel-a-* / tunnel-an-* name mentioned inside any shipped file
     resolves to a directory that ships. Catches the tunnel-a-logger class:
     a rename that leaves inbound references pointing at nothing.

  2. INVARIANT (repo-scoped) -- exactly SEVEN format bodies.
     The vocabulary is fixed and bounded. An eighth format fails the build
     until someone changes this number on purpose. This is the only rule here
     that makes "a fixed vocabulary" a mechanism instead of an intention.

  3. PROXY -- the guide does not trigger at author time.
     Checked as the absence of author-time verbs in a non-format description.
     Paraphrase clears it: "use when you need a document on the web" trips no
     verb and fires identically. Conservative, not sufficient.

     It also OVER-fires: it caught "diagnosing a failed publish", a diagnostic
     clause that never competes at author time. That direction is the safe one
     -- a proxy that cries wolf costs a rewording; a proxy that stays quiet
     costs the defect. Reword rather than widening the allowlist.

SCOPE LIMIT, and it is structural: this reads only this repo. The dispatch
surface an agent actually sees is assembled from repos nobody owns together --
a skill like `understand` fires at format-pick and will never be vendored here.
A green run means "none of ours collide", never "no collisions exist".
"""
import pathlib
import re
import sys

FORMATS = {"tunnel-a-sheet", "tunnel-a-doc", "tunnel-a-brief", "tunnel-an-essay",
           "tunnel-a-deck", "tunnel-a-log", "tunnel-a-report"}
AUTHOR_TIME_VERBS = ["creating", "create ", "make ", "write ", "writing",
                     "publish", "turn into", "author "]

root = pathlib.Path(__file__).resolve().parent.parent
fails = []

shipped = {p.name for p in (root / "formats").iterdir() if p.is_dir()}
shipped |= {p.name for p in (root / "guide").iterdir() if p.is_dir()}

# 1. INVARIANT -- no dangling name
mentioned = set()
for path in list(root.glob("formats/**/*")) + list(root.glob("guide/**/*")) + [root / "README.md"]:
    if not path.is_file() or path.suffix not in (".md", ".html", ".css"):
        continue
    for name in re.findall(r'tunnel-an?-[a-z]+', path.read_text()):
        mentioned.add((name, path.relative_to(root)))
for name, where in sorted(mentioned):
    if name not in shipped:
        fails.append(f"dangling name {name!r} referenced in {where} but no such directory ships")

# 2. INVARIANT -- exactly seven formats
bodies = {p.name for p in (root / "formats").iterdir() if p.is_dir()} - {"tunnel-a-base"}
if bodies != FORMATS:
    extra, missing = bodies - FORMATS, FORMATS - bodies
    fails.append(f"format set changed: +{sorted(extra) or '-'} -{sorted(missing) or '-'} "
                 f"(count {len(bodies)}, expected 7). Adding a name must be deliberate: "
                 f"edit FORMATS in this file in the same commit.")

# 3. PROXY -- the guide must not fire at author time.
#
# SCOPE, stated because a green here is easy to over-read: this loop walks
# guide/ ONLY, so it governs tunnel-an-artifact and nothing else. It does NOT
# look at tunnel-a-base, which now carries author-time language DELIBERATELY --
# quill's ruling that base is the family's entry point ("where do I start"),
# the one question no shape skill answers. Do not "fix" base by adding it here;
# that would flag the intended design. If a fourth non-format ever appears,
# decide explicitly which lane it is in rather than inheriting this loop.
for guide in (root / "guide").iterdir():
    skill = guide / "SKILL.md"
    if not skill.exists():
        continue
    fm = skill.read_text().split("---")[1].lower() if "---" in skill.read_text() else ""
    hit = [v for v in AUTHOR_TIME_VERBS if v in fm]
    if hit:
        fails.append(f"{guide.name} description contains author-time verb(s) {hit} -- "
                     f"it would compete with the format skills at pick time")

if fails:
    print("FAIL")
    for f in fails:
        print(f"     {f}")
    sys.exit(1)
print(f"PASS {len(bodies)} formats, no dangling names, guide does not fire at author time")
print("     (rules 1-2 INVARIANT scoped to this repo; rule 3 PROXY. "
      "Says nothing about skills installed from elsewhere.)")
sys.exit(0)
