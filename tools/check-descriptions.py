#!/usr/bin/env python3
"""check-descriptions.py -- every skill's description survives openlap's store.

TUNN-018: openlap's extractDescription (cmd/anylap/skills_workspace_list.go)
reads the `description:` LINE only, by design, and strips one pair of outer
quotes without unescaping. A YAML block scalar (`description: >` or `|`)
therefore stored as the literal `>`, and 4 of 10 skills showed that to any
agent picking a skill from the store.

Rules, per SKILL.md:
  1. INVARIANT  the frontmatter has a `description:` line whose value, read
                exactly as openlap reads it, is non-empty and is not a block
                scalar indicator (> >- >+ | |- |+).
  2. INVARIANT  a quoted value holds no escape sequence (openlap would show
                the backslash), and no stray copy of its own quote.

Usage: check-descriptions.py [SKILL.md ...]   (default: formats/*/ and guide/*/)
Exit 1 on any failure.
"""
import glob
import os
import sys

BLOCK = {">", ">-", ">+", "|", "|-", "|+"}


def openlap_value(path):
    """The description exactly as openlap's tiny parser extracts it."""
    lines = open(path, encoding="utf-8").read().split("\n")
    if not lines or not lines[0].startswith("---"):
        return None
    for line in lines[1:33]:
        if line.startswith("---"):
            return None
        if line.startswith("description:"):
            return line[len("description:"):].strip()
    return None


def check(path):
    raw = openlap_value(path)
    if raw is None:
        return "no description line in the frontmatter"
    if raw in BLOCK or raw.split(" ")[0] in BLOCK:
        return f"description is a block scalar ({raw!r}); openlap stores it as {raw!r}"
    v = raw
    if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
        q, v = v[0], v[1:-1]
        if "\\" in v:
            return "a quoted description holds a backslash escape, which openlap shows as is"
        if q in v:
            return f"a {q}-quoted description holds its own quote mark"
    if not v.strip():
        return "description is empty"
    return None


def main(argv):
    paths = argv[1:] or sorted(glob.glob("formats/*/SKILL.md") + glob.glob("guide/*/SKILL.md"))
    bad = 0
    for p in paths:
        err = check(p)
        if err:
            bad += 1
            print(f"FAIL {p}: {err}")
    if bad:
        print(f"FAIL {bad} of {len(paths)} description(s) would not survive openlap's store (INVARIANT)")
        return 1
    print(f"PASS {len(paths)} description(s) are single-line and survive openlap's store (INVARIANT)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
