#!/usr/bin/env python3
"""ART-073 shadow rule. Called by check-tokens.sh; not meant to be run alone.

A format skill may INLINE tunnel-a-base/tokens.css verbatim -- base instructs
authors to do exactly that. What it may not do is redefine a base token NAME to
a DIFFERENT value, because the artifact then silently disagrees with the family
under names that look official.

Rule: a `--name:value` declaration is allowed iff that exact pair appears in
tokens.css (any of its light / dark / data-theme blocks). Otherwise it is a shadow.

INVARIANT, scoped to this repo. Says nothing about skills installed from elsewhere.
"""
import pathlib
import re
import sys

DECL = re.compile(r'--([a-z0-9-]+)\s*:\s*([^;}\n]+)')

root = pathlib.Path(__file__).resolve().parent.parent
tokens = root / "formats/tunnel-a-base/SKILL.md"   # the token block lives inside it
if not tokens.exists():
    print("FATAL: tunnel-a-base/SKILL.md missing -- cannot compute base names")
    sys.exit(2)

base_pairs, base_names = set(), set()
for name, value in DECL.findall(tokens.read_text()):
    base_names.add(name)
    base_pairs.add((name, value.strip()))

violations = []
for path in sorted(root.glob("formats/**/*")) + sorted(root.glob("guide/**/*")):
    if path.suffix not in (".md", ".html", ".css") or path == tokens:
        continue
    for lineno, line in enumerate(path.read_text().splitlines(), 1):
        for name, value in DECL.findall(line):
            if name not in base_names:
                continue                                  # skill's own alias, fine
            if (name, value.strip()) in base_pairs:
                continue                                  # verbatim inline, the contract
            violations.append((path.relative_to(root), lineno, name, value.strip()))

if violations:
    print("FAIL a skill redefines a base token name to a different value:")
    for rel, lineno, name, value in violations:
        print(f"     {rel}:{lineno}  --{name}: {value}")
    sys.exit(1)
sys.exit(0)
