#!/usr/bin/env python3
"""guide-set.py -- build and gate tunnel's operating guide (TUNN-100).

tunnel-guide/ holds the guide tunnel serves to every agent, in levels:
  tunnel-guide/<id>.md          an L1 topic (at most 400 words)
  tunnel-guide/<id>/<name>.md   an L2 reference (at most 1,500 words), id <id>/<name>
Each file is header lines, a '---' line, then the body:
  title: <title>
  refs: <l2 id>, <l2 id>     (L1 only, optional)

  guide-set.py                  gate, print one line per topic
  guide-set.py --json FILE SHA  gate, write the set tunnel's POST /api/guide takes
  guide-set.py --digests FILE   gate, write {id: sha256} as tunnel computes it

The gate refuses what tunnel would refuse (internal/guide.Set.Validate), so a
red set never reaches the server; tunnel checks again on publish, including
that no body line repeats its initialize instructions (L0).
"""
import hashlib, json, pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent / "tunnel-guide"
# The L1 ids tunnel's L0 indexes (tunnel-artifacts guidetool.go, guideIndex).
# A set must hold exactly these. Changing the list is a change in both repos.
INDEX = ["lifecycle", "sharing", "visibility", "media", "undo", "close", "tunnel-down", "pages"]
L1MAX, L2MAX = 400, 1500
L1ID = re.compile(r"^[a-z][a-z0-9-]{0,31}$")
L2ID = re.compile(r"^[a-z][a-z0-9-]{0,31}/[a-z][a-z0-9-]{0,47}$")


def words(s):
    return len(s.split())


def load():
    topics, fails = [], []
    for p in sorted(ROOT.rglob("*.md")):
        rel = p.relative_to(ROOT).with_suffix("").as_posix()
        if any(part.startswith(".") for part in p.relative_to(ROOT).parts):
            continue  # editor and macOS metadata files (._x.md), not topics
        level = rel.count("/") + 1
        try:
            raw = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            fails.append(f"{rel}: not UTF-8 text")
            continue
        head, sep, body = raw.partition("\n---\n")
        if not sep:
            fails.append(f"{rel}: no '---' line between header and body")
            continue
        meta = {}
        for line in head.splitlines():
            k, _, v = line.partition(":")
            if k.strip() not in ("title", "refs"):
                fails.append(f"{rel}: unknown header {k.strip()!r}")
            meta[k.strip()] = v.strip()
        t = {"id": rel, "level": level, "title": meta.get("title", ""), "body": body.strip()}
        refs = [r.strip() for r in meta.get("refs", "").split(",") if r.strip()]
        if refs:
            t["refs"] = refs
        topics.append(t)
    return topics, fails


def gate(topics, fails):
    by = {}
    for t in topics:
        i, body = t["id"], t["body"]
        if i in by:
            fails.append(f"{i}: appears twice")
        by[i] = t
        if not t["title"] or not body:
            fails.append(f"{i}: needs a title and a body")
        bad = [c for c in t["title"] + body if (ord(c) < 32 and c != "\n") or ord(c) > 126]
        if bad:
            # ASCII only: the digest below then equals Go's json.Marshal byte for byte.
            fails.append(f"{i}: non-ASCII or control character {bad[0]!r}")
        if t["level"] == 1:
            if not L1ID.match(i):
                fails.append(f"{i}: not an L1 id")
            if i not in INDEX:
                fails.append(f"L1 {i!r} is not in tunnel's L0 index {INDEX}")
            if words(body) > L1MAX:
                fails.append(f"L1 {i!r} is {words(body)} words, over {L1MAX}")
        elif t["level"] == 2:
            if not L2ID.match(i):
                fails.append(f"{i}: an L2 id is <l1>/<name>")
            if "refs" in t:
                fails.append(f"L2 {i!r} names refs; only an L1 hands off")
            if words(body) > L2MAX:
                fails.append(f"L2 {i!r} is {words(body)} words, over {L2MAX}")
        else:
            fails.append(f"{i}: nested too deep (level {t['level']})")
    for i in INDEX:
        if by.get(i, {}).get("level") != 1:
            fails.append(f"L1 {i!r} is in tunnel's L0 index but not in tunnel-guide/")
    named = set()
    for t in topics:
        for r in t.get("refs", []):
            if by.get(r, {}).get("level") != 2:
                fails.append(f"L1 {t['id']!r} names {r!r}, which is no L2 here")
            elif not r.startswith(t["id"] + "/"):
                fails.append(f"L1 {t['id']!r} names {r!r}, which belongs to another topic")
            named.add(r)
    for t in topics:
        if t["level"] == 2 and t["id"] not in named:
            fails.append(f"L2 {t['id']!r} is named by no L1, so no agent can reach it")
        if t["level"] == 2 and t["id"] not in by.get(t["id"].split("/")[0], {}).get("body", ""):
            fails.append(f"L2 {t['id']!r}: its L1's body never says when to read it")
    return fails


def go_json(v):
    """json.Marshal's bytes: compact, non-ASCII as raw UTF-8, and <, >, &,
    U+2028 and U+2029 escaped as Go escapes them. The gate refuses non-ASCII
    today; this stays exact if that rule is ever relaxed (fennec, TUNN-100)."""
    s = json.dumps(v, separators=(",", ":"), ensure_ascii=False)
    for c, e in (("<", "\\u003c"), (">", "\\u003e"), ("&", "\\u0026"), ("\u2028", "\\u2028"), ("\u2029", "\\u2029")):
        s = s.replace(c, e)
    return s


def digest(t):
    # Field order is Go's struct order: id, level, title, body, refs (omitempty).
    o = {k: t[k] for k in ("id", "level", "title", "body")}
    if t.get("refs"):
        o["refs"] = t["refs"]
    return hashlib.sha256(go_json(o).encode("utf-8")).hexdigest()


def main(argv):
    topics, fails = load()
    fails = gate(topics, fails)
    if fails:
        for f in fails:
            print("FAIL", f)
        print(f"RED {len(fails)} problem(s) in tunnel-guide/")
        return 1
    for t in topics:
        print(f"   L{t['level']} {t['id']:<28} {words(t['body']):>4} words  {digest(t)[:12]}")
    if len(argv) == 3 and argv[0] == "--json":
        pathlib.Path(argv[1]).write_text(json.dumps({"source": argv[2], "topics": topics}))
    elif len(argv) == 2 and argv[0] == "--digests":
        pathlib.Path(argv[1]).write_text(json.dumps({t["id"]: digest(t) for t in topics}))
    elif argv:
        print("usage: guide-set.py [--json FILE SOURCE_SHA | --digests FILE]")
        return 2
    print(f"PASS {sum(t['level'] == 1 for t in topics)} topics, {sum(t['level'] == 2 for t in topics)} references, within budget")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
