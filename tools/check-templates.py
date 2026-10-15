#!/usr/bin/env python3
"""TUNN-033 template gate. Run from the repo root: tools/check-templates.py

templates/<name>/ holds one template as it is authored: manifest.json, with
its skeleton beside it as skeleton.html or skeleton.md (tunnel's LoadDir reads
the same layout). These are the manifests tunnel serves through its `templates`
tool, so any agent finds them without a skill installed. This checks each one
the way tunnel's own parser does (internal/templates/manifest.go, Validate),
so a manifest that would be refused is caught here, before a publish.

PROXY, not the authority. Tunnel validates the whole batch again on
POST /api/templates and writes none of it if one manifest fails. This copy of
the rules can drift from tunnel's; when they disagree, tunnel is right and this
file is the one to fix. It does not check count selectors (tunnel does).
"""
import json
import pathlib
import re
import sys

SHAPES = ["notes", "brief", "timeline", "board", "numbers", "story", "rendition"]
FIELDS = {"name", "shape", "summary", "intents", "not_for", "content_types",
          "slots", "finish_line", "example", "skeleton"}
SLOT_FIELDS = {"name", "says", "required"}
TEST_FIELDS = {"id", "says", "kind", "selector", "text", "texts", "level", "min", "max"}
# kind -> runs mechanically (a manual test is read by a person, never scored)
KINDS = {"title": True, "count": True, "heading": True, "in_order": True,
         "no_slots": True, "no_external": True, "no_emoji": True, "words": True,
         "max_bytes": True, "banned_words": True, "source_contains": True,
         "table_totals": True, "manual": False}
MAX_SKELETON = 3 * 1024
NAME_RE = re.compile(r"^[a-z0-9-]+(/[a-z0-9-]+)?$")
SLOT_RE = re.compile(r"\{\{([A-Za-z0-9_.-]+)\}\}")
LEFT_RE = re.compile(r"\{\{[^{}\n]{1,80}\}\}")
TEST_RE = re.compile(r"^[a-z0-9_-]{1,40}$")


def problems(m):
    if not isinstance(m, dict):
        return ["not a JSON object"]
    out = []
    bad = out.append
    unknown = set(m) - FIELDS
    if unknown:
        bad(f"unknown field(s): {', '.join(sorted(unknown))}")
    name, shape = m.get("name", ""), m.get("shape", "")
    if not NAME_RE.match(name) or len(name) > 80:
        bad("name must be lower-case words joined by '-', optionally shape/variant")
    if shape not in SHAPES:
        bad(f"shape must be one of {', '.join(SHAPES)}")
    if name.split("/")[0] != shape:
        bad("a template's name starts with its shape word")
    summary = m.get("summary", "")
    if not summary.strip() or len(summary.encode()) > 300:
        bad("summary is one line, 1..300 bytes")
    if not m.get("intents"):
        bad("intents: at least one")
    cts = m.get("content_types") or []
    if not cts:
        bad("content_types: at least one")
    for ct in cts:
        if ct not in ("html", "markdown"):
            bad(f"content_types: html or markdown, not {ct!r}")
    sk = m.get("skeleton", "")
    if not sk.strip():
        bad("skeleton is required")
    if len(sk.encode()) > MAX_SKELETON:
        bad(f"skeleton is {len(sk.encode())} bytes; the limit is {MAX_SKELETON}")
    if len(LEFT_RE.findall(sk)) != len(SLOT_RE.findall(sk)):
        bad("skeleton slots are {{name}}: letters, digits, _ . - and no spaces")
    in_sk = set(SLOT_RE.findall(sk))
    seen = set()
    for s in m.get("slots") or []:
        if set(s) - SLOT_FIELDS:
            bad(f"slot {s.get('name')!r}: unknown field(s) {', '.join(sorted(set(s) - SLOT_FIELDS))}")
        n = s.get("name", "")
        if not SLOT_RE.fullmatch("{{" + n + "}}") or n in seen:
            bad(f"slot {n!r}: a unique name of letters, digits, _ . -")
        seen.add(n)
        if s.get("required") and n not in in_sk:
            bad(f"required slot {n!r} is not marked {{{{{n}}}}} in the skeleton")
    for n in sorted(in_sk - seen):
        bad(f"skeleton marks {{{{{n}}}}} but slots does not name it")
    tests = m.get("finish_line") or []
    if not tests:
        bad("finish_line: at least one test")
    ids, mechanical = set(), 0
    for t in tests:
        tid = t.get("id", "")
        if set(t) - TEST_FIELDS:
            bad(f"test {tid!r}: unknown field(s) {', '.join(sorted(set(t) - TEST_FIELDS))}")
        if not TEST_RE.match(tid) or tid in ids:
            bad(f"test {tid!r}: a unique id of a-z 0-9 _ -")
        ids.add(tid)
        if not t.get("says", "").strip():
            bad(f"test {tid!r}: says is required")
        kind = t.get("kind")
        if kind not in KINDS:
            bad(f"test {tid!r}: unknown kind {kind!r}")
            continue
        mechanical += KINDS[kind]
        texts, mn, mx = t.get("texts") or [], t.get("min"), t.get("max")
        if kind in ("count", "words") and mn is None and mx is None:
            bad(f"test {tid!r}: {kind} needs min or max")
        if kind == "count" and not t.get("selector"):
            bad(f"test {tid!r}: count needs a selector")
        if kind == "heading" and not 0 <= t.get("level", 0) <= 6:
            bad(f"test {tid!r}: level is 1..6, or 0 for any")
        if kind == "in_order" and len(texts) < 2:
            bad(f"test {tid!r}: in_order needs two or more texts")
        if kind == "no_external" and (not texts or set(texts) - {"stylesheet", "script"}):
            bad(f"test {tid!r}: no_external names stylesheet and/or script")
        if kind == "max_bytes" and (mx is None or mx < 1):
            bad(f"test {tid!r}: max_bytes needs max")
        if kind in ("banned_words", "source_contains") and not texts:
            bad(f"test {tid!r}: {kind} needs texts")
        if mn is not None and mx is not None and mn > mx:
            bad(f"test {tid!r}: min is above max")
    if tests and mechanical == 0:
        bad("finish_line: at least one test must run mechanically")
    return out


def load(d):
    """One template dir as tunnel's LoadDir reads it: the manifest, with the
    skeleton file joined in unless the manifest already carries one."""
    m = json.loads((d / "manifest.json").read_text())
    if isinstance(m, dict) and "skeleton" not in m:
        found = [f for f in ("skeleton.html", "skeleton.md") if (d / f).is_file()]
        if len(found) > 1:
            raise ValueError(f"one skeleton, not {found}")
        if found:
            m["skeleton"] = (d / found[0]).read_text()
    return m


def load_all(root="templates"):
    return [(d, load(d)) for d in sorted(pathlib.Path(root).iterdir()) if d.is_dir()]


def main():
    dirs = sorted(d for d in pathlib.Path("templates").glob("*") if d.is_dir())
    if not dirs:
        print("FAIL no templates/<name>/ found (run from the repo root)")
        return 1
    files = dirs
    fail, names = 0, {}
    for f in dirs:
        try:
            m = load(f)
        except (OSError, ValueError) as e:
            print(f"FAIL {f}: {e}")
            fail += 1
            continue
        ps = problems(m)
        name = m.get("name") if isinstance(m, dict) else None
        if name and f.name != name.replace("/", "--"):
            ps.append(f"dir is {f.name}/; a template named {name!r} lives in templates/{name.replace('/', '--')}/")
        if name in names:
            ps.append(f"name {name!r} is also used by {names[name]}")
        names[name] = f.name
        for p in ps:
            print(f"FAIL {f}: {p}")
        fail += bool(ps)
    if fail:
        print(f"--- {fail} of {len(files)} template(s) would be refused by tunnel")
        return 1
    print(f"ok   {len(files)} template(s): {', '.join(sorted(n for n in names if n))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
