#!/usr/bin/env python3
"""ART-073-090 -- colour reconciled in EVERY syntax the family can express it.

check-tokens.sh is a set-difference over HEX literals. That is one syntax, not
colour. Measured after that gate went green: 21 distinct rgba() survived it,
including rgba(124,58,237,...) -- VIOLET -- in two skills whose hex violet had
been deleted hours earlier. A declared ceiling still hid a full parallel
population.

This file closes the other two syntaxes. Run from check-tokens.sh.

RULE KINDS -- read this before trusting a green run:

  RULE 1  INVARIANT, SCOPED TO THIS REPO
    Every rgb()/rgba()/hsl()/hsla() colour in formats/ and guide/ must resolve
    to a triple that a base token also declares. ALPHA IS FREE: rgba(<token>,.08)
    is how the family does a translucent overlay and must not be flagged --
    the defect is a DIFFERENT COLOUR, never a different opacity. Complete over
    these files; says nothing about a skill installed from elsewhere.

  RULE 2  PROXY
    A markdown TABLE CELL that is exactly an off-palette colour name. This is
    the shape that actually taught green: tunnel-a-report's verdict taxonomy
    said `| SHIPPED | green |` in a table an author copies from, 35 lines below
    the same file saying green is banned. Prose that DESCRIBES someone else's UI
    ("functional colour survives: diff red/green") is correct and must not fire
    -- so the rule keys on the table-cell syntax, not on the word. A prescriptive
    sentence outside a table slips it. Conservative, not a solved invariant.

  RULE 3  PROXY
    A line that enumerates the palette ("the :root color tokens already include
    blue/green/yellow/red/violet to draw from") naming a colour with no token.
    Keyed on enumeration verbs near a colour list. Narrow by construction.

  RULE 4  PROXY
    Three more prescriptive SYNTAXES, added after rules 2 and 3 went green on a
    tree still teaching green in six places -- the shapes rules 2/3 could not
    see, found by grepping every surviving `green` rather than by trusting a
    pass:
      (a) STATUS(colour)       "RESOLVED(green)", "SHIPPED(green)"
      (b) Colour = meaning     "Green = consolidation / done"
      (c) a slash-list of 3+   "the five (blue/green/yellow/red/violet)"
    (c) REQUIRES THREE. Two is the load-bearing guard: tunnel-a-doc's "functional
    colour survives: diff red/green" describes someone else's UI, is correct
    prose, and a 2-name rule would fire on it. -090 states that sparing doc is
    part of the contract, so the guard is not a convenience.

  THE NAME LIST IS OPEN, AND SO IS THE SYNTAX LIST -- WHICH IS WHY 2, 3 AND 4
  ARE PROXIES. The names are the colours this family has actually shipped
  wrongly (green, violet and near synonyms). A format prescribing `teal`, or
  prescribing green in a sentence shaped some fourth way, passes every rule
  here. Rules 2-4 are three known shapes, not a decision procedure for prose.

Exemptions live in tools/token-exemptions.txt as "<file>:<token> reason".
An exemption is a written decision; an empty reason is not an exemption.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
TOKENS = ROOT / "formats/tunnel-a-base/SKILL.md"
EXEMPT = ROOT / "tools/token-exemptions.txt"

# Colour words this family has shipped wrongly. Open list -> rules 2 and 3 are PROXIES.
OFF_PALETTE_NAMES = {
    "green", "violet", "purple", "emerald", "teal", "lime", "magenta", "cyan",
}

FUNC = re.compile(r"\b(rgba?|hsla?)\(\s*([^)]*)\)", re.I)
HEXDECL = re.compile(r"#([0-9a-fA-F]{3,8})")


def hex_to_triple(h):
    h = h.lower()
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    if len(h) in (6, 8):
        return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))
    return None


def load_exemptions():
    out = set()
    if not EXEMPT.exists():
        return out
    for line in EXEMPT.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        head, _, reason = line.partition(" ")
        if reason.strip():          # an empty reason is NOT an exemption
            out.add(head.strip())
    return out


def files():
    for path in sorted(ROOT.glob("formats/**/*")) + sorted(ROOT.glob("guide/**/*")):
        if path.suffix in (".md", ".html", ".css"):
            yield path


def main():
    if not TOKENS.exists():
        print("FATAL: tunnel-a-base/SKILL.md missing -- cannot compute the token set")
        return 2

    token_triples = set()
    for h in HEXDECL.findall(TOKENS.read_text()):
        t = hex_to_triple(h)
        if t:
            token_triples.add(t)

    exempt = load_exemptions()
    v1, v2, v3, v4 = [], [], [], []

    for path in files():
        rel = path.relative_to(ROOT)
        is_tokens = path == TOKENS
        for lineno, line in enumerate(path.read_text().splitlines(), 1):

            # RULE 1 -- functional colour notation must resolve to a token triple.
            for fn, args in FUNC.findall(line):
                parts = [p.strip() for p in re.split(r"[,\s/]+", args.strip()) if p.strip()]
                if len(parts) < 3:
                    continue
                if fn.lower().startswith("hsl"):
                    # Not converted: flagged as unresolvable rather than guessed.
                    key = f"{rel}:{fn}({','.join(parts[:3])})"
                    if key not in exempt:
                        v1.append((rel, lineno, f"{fn}({', '.join(parts[:3])})", "hsl not resolvable to a token triple"))
                    continue
                try:
                    triple = tuple(int(float(p)) for p in parts[:3])
                except ValueError:
                    continue
                if triple in token_triples:
                    continue
                key = f"{rel}:rgb({triple[0]},{triple[1]},{triple[2]})"
                if key in exempt:
                    continue
                v1.append((rel, lineno, f"{fn}({', '.join(parts[:3])}...)", f"#{triple[0]:02x}{triple[1]:02x}{triple[2]:02x} is not a token colour"))

            if is_tokens:
                continue

            low = line.lower()

            # RULE 2 -- a table CELL that is exactly an off-palette colour name.
            if low.lstrip().startswith("|"):
                for cell in low.split("|"):
                    word = cell.strip().strip("*`_ ")
                    if word in OFF_PALETTE_NAMES:
                        key = f"{rel}:name:{word}"
                        if key not in exempt:
                            v2.append((rel, lineno, word, "prescribed as a value in a table an author copies"))

            # RULE 4 -- three prescriptive syntaxes rules 2/3 cannot see.
            for name in OFF_PALETTE_NAMES:
                hit = None
                # (a) STATUS(colour) -- a verdict name with a parenthesised colour
                if re.search(rf"\w\(\s*{name}\s*\)", low):
                    hit = "prescribed as a status colour: STATUS(colour)"
                # (b) Colour = meaning, or meaning = colour, or an arrow pairing.
                #     The arrow arm was added because rule 4 as first written
                #     MISSED tunnel-an-essay:162 "green->blue for consolidation"
                #     while FALSE-POSITIVING on tunnel-a-sheet:38 -- one rule,
                #     both error directions, on the next two lines I read. That
                #     is the argument for keeping this a PROXY, not a decision
                #     procedure.
                elif re.search(rf"\b{name}\s*(=|→|->)|(=|→|->)\s*{name}\b", low):
                    hit = "paired with a meaning, which is a prescription"
                # (c) a slash-list of THREE or more colour names.
                #     THREE, not two: "diff red/green" describes another product's
                #     UI and must not fire -- -090 makes sparing that part of the
                #     contract, so this bound is load-bearing, not a convenience.
                else:
                    for run in re.findall(r"[a-z]+(?:/[a-z]+){2,}", low):
                        parts = run.split("/")
                        if name in parts and len(parts) >= 3:
                            hit = f"listed in a {len(parts)}-colour palette enumeration"
                            break
                if hit:
                    key = f"{rel}:prescribe:{name}"
                    if key not in exempt:
                        v4.append((rel, lineno, name, hit))

            # RULE 3 -- a palette enumeration naming a colour with no token.
            if re.search(r"\b(tokens?|palette|:root)\b", low) and re.search(r"\b(include|includes|are|draw from|choose from|pick from)\b", low):
                for name in OFF_PALETTE_NAMES:
                    if re.search(rf"\b{name}\b", low):
                        key = f"{rel}:list:{name}"
                        if key not in exempt:
                            v3.append((rel, lineno, name, "enumerated as available when no token defines it"))

    fail = 0
    for label, kind, rows in (
        ("RULE 1 (INVARIANT) rgb/rgba/hsl must resolve to a token colour", "colour", v1),
        ("RULE 2 (PROXY) off-palette colour name prescribed in a table cell", "name", v2),
        ("RULE 3 (PROXY) off-palette colour enumerated as a token", "name", v3),
        ("RULE 4 (PROXY) off-palette colour prescribed by status/assignment/list syntax", "name", v4),
    ):
        if rows:
            fail += 1
            print(f"FAIL {label} -- {len(rows)} hit(s):")
            seen = set()
            for rel, lineno, what, why in rows:
                sig = (str(rel), lineno, what)
                if sig in seen:
                    continue
                seen.add(sig)
                print(f"     {rel}:{lineno}  {what}  -- {why}")

    if fail:
        return 1
    print("PASS colour reconciled across hex-adjacent syntaxes "
          "(rule 1 INVARIANT scoped to this repo; rules 2-3 are PROXIES over an open name list)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
