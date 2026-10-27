#!/usr/bin/env python3
"""Pointer gate (TUNN-100-070). Run from anywhere: tools/check-pointers.py

Tunnel serves the manual (`templates({action:"guide"})`), the templates
(`templates({action:"get", id})`) and the kit, so a skill no longer carries any
of them. A skill is a pointer: when to use it, the exact tunnel call, and only
what a template cannot say. This holds every skill to that:

  1. INVARIANT -- each formats/*/SKILL.md and guide/*/SKILL.md body (after the
     frontmatter) is at most MAX_WORDS words. A body that grows past it is
     copying back what tunnel serves.
  2. INVARIANT -- each format skill except tunnel-a-base names
     templates({action:"get", id:"<its shape>"}), and templates/<shape>/ ships.
  3. INVARIANT -- tunnel-a-base and every guide skill name
     templates({action:"guide" ...}).
  4. INVARIANT -- every guide topic a skill names exists in tunnel-guide/: each
     topic:"X" (a placeholder like topic:"<topic>" is skipped), each backticked `X/Y` reference whose X is a topic, and each
     topic in the first column of a guide skill's table.
  5. INVARIANT -- every topic in tunnel-guide/ appears in that table, so a new
     topic cannot ship without the manual pointing at it.

All repo-scoped. Says nothing about what tunnel actually serves: that is
tools/publish-guide.sh --verify and tools/publish-templates.sh --verify.
"""
import pathlib
import re
import sys

MAX_WORDS = 300

ROOT = pathlib.Path(__file__).resolve().parent.parent
GUIDE = ROOT / "tunnel-guide"

TOPIC_ARG = re.compile(r'topic:\s*"([^"]+)"')
REF = re.compile(r"`([a-z][a-z0-9-]*)/([a-z][a-z0-9-]*)`")
ROW = re.compile(r"^\|\s*`([a-z][a-z0-9-]*)`\s*\|", re.M)


def body(path):
    text = path.read_text()
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 4)
    return None if end < 0 else text[end + len("\n---\n"):]


def main():
    fails = []
    topics = {p.stem for p in GUIDE.glob("*.md")}
    refs = {f"{p.parent.name}/{p.stem}" for p in GUIDE.glob("*/*.md")}
    if not topics:
        print("FATAL: tunnel-guide/ holds no topics -- nothing to check names against")
        return 2

    skills = sorted(ROOT.glob("formats/*/SKILL.md")) + sorted(ROOT.glob("guide/*/SKILL.md"))
    tabled = set()
    for path in skills:
        rel = path.relative_to(ROOT)
        name = path.parent.name
        b = body(path)
        if b is None:
            fails.append(f"{rel}: no frontmatter, cannot find the body")
            continue

        # 1. size
        n = len(b.split())
        if n > MAX_WORDS:
            fails.append(f"{rel}: body is {n} words, cap {MAX_WORDS} -- it is carrying what tunnel serves")

        # 2. format skills name their own template
        if path.parent.parent.name == "formats" and name != "tunnel-a-base":
            shape = name.removeprefix("tunnel-a-")
            call = f'templates({{action:"get", id:"{shape}"}})'
            if call not in b:
                fails.append(f"{rel}: does not name {call}")
            if not (ROOT / "templates" / shape).is_dir():
                fails.append(f"{rel}: templates/{shape}/ does not ship")

        # 3. base and the guide name the guide call
        if name == "tunnel-a-base" or path.parent.parent.name == "guide":
            if 'templates({action:"guide"' not in b:
                fails.append(f'{rel}: does not name templates({{action:"guide" ...}})')

        # 4. every topic named exists
        for t in TOPIC_ARG.findall(b):
            if t.startswith("<") and t.endswith(">"):
                continue                       # a placeholder, e.g. topic:"<topic>"
            if t not in topics:
                fails.append(f'{rel}: names topic:"{t}", but tunnel-guide/{t}.md does not exist')
        for a, c in REF.findall(b):
            if a in topics and f"{a}/{c}" not in refs:
                fails.append(f"{rel}: names `{a}/{c}`, but tunnel-guide/{a}/{c}.md does not exist")
        if path.parent.parent.name == "guide":
            for t in ROW.findall(b):
                tabled.add(t)
                if t not in topics:
                    fails.append(f"{rel}: its table names `{t}`, but tunnel-guide/{t}.md does not exist")

    # 5. every topic is in the manual's table
    for t in sorted(topics - tabled):
        fails.append(f"tunnel-guide/{t}.md: no guide skill's table names `{t}`")

    if fails:
        print("FAIL")
        for f in fails:
            print(f"     {f}")
        return 1
    print(f"PASS {len(skills)} skills are pointers: each at most {MAX_WORDS} words, each names its tunnel call, "
          f"{len(topics)} guide topics named and all real (INVARIANT, scoped to this repo)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
