#!/usr/bin/env bash
# check-tokens.sh -- ART-073 gate.
#
# Every colour literal in a format skill must come from formats/tunnel-a-base/tokens.css.
# Green is banned as a UI signal by base; a survivor must be declared, not tolerated.
#
# RULE KINDS -- read this before trusting a green run:
#
#   INVARIANT, SCOPED TO THIS REPO
#     Set difference over hex literals is complete for the files in formats/ and guide/.
#     It says nothing about any skill installed from elsewhere.
#
#   PROXY
#     "Green is gone" is checked as the absence of specific literals. A different
#     green (#0b0, rgb(0,186,124), hsl) would pass. Conservative, not a solved invariant.
#
# HTML numeric entities (&#8599;) are NOT colours. The first version of this script
# counted two of them as off-token literals; anyone "fixing" those would have broken
# an arrow glyph. Matches preceded by & are excluded.
#
# Exempt survivors live in tools/token-exemptions.txt, one "<file>:<hex> reason" per line.
# An exemption is a written decision. An empty reason is not an exemption.

set -uo pipefail
cd "$(dirname "$0")/.."

TOKENS="formats/tunnel-a-base/SKILL.md"
EXEMPT="tools/token-exemptions.txt"
[ -f "$TOKENS" ] || { echo "FATAL: $TOKENS missing -- cannot compute the allowlist"; exit 2; }
# OLP-430: companions cannot reach the skill store, so tokens.css was ELIMINATED
# rather than synchronised. The fenced block inside tunnel-a-base/SKILL.md IS the
# token set, and is therefore also the allowlist the gate verifies against.

allow=$(grep -ohE '#[0-9a-fA-F]{3,8}' "$TOKENS" | tr 'A-F' 'a-f' | sort -u)

fail=0
total=0
for f in $(find formats guide -name SKILL.md -o -name '*.html' -o -name '*.css' | grep -v "$TOKENS" | sort); do
  hits=""
  while read -r hex; do
    [ -z "$hex" ] && continue
    lc=$(echo "$hex" | tr 'A-F' 'a-f')
    echo "$allow" | grep -qx "$lc" && continue
    if [ -f "$EXEMPT" ] && grep -qE "^$f:$lc[[:space:]]+\S" "$EXEMPT"; then continue; fi
    hits="$hits $hex"
  done < <(grep -ohE '&?#[0-9a-fA-F]{3,8}' "$f" | grep -v '^&' | sort -u)

  if [ -n "$hits" ]; then
    n=$(echo $hits | wc -w | tr -d ' ')
    lines=$(grep -cE "$(echo $hits | tr ' ' '|')" "$f")
    echo "FAIL $f -- $n off-token literal(s) across $lines line(s):$hits"
    fail=$((fail+1)); total=$((total+n))
  fi
done

# INVARIANT: a skill may not redefine a base token name to a DIFFERENT value.
#
# Two things this had to learn the hard way:
#   - mapping brief's competing :root onto tokens produced `--blue:var(--blue)`,
#     self-referential and invalid, and the hex check PASSED on it. A gate that
#     goes green on broken CSS is worse than no gate.
#   - a blanket "no base name outside tokens.css" rule FALSE-POSITIVES on
#     tunnel-a-sheet/template.html, which inlines the token block verbatim --
#     which base explicitly instructs authors to do. Redefinition is the defect;
#     verbatim inlining is the contract.
# So: a `--name:value` pair is fine iff that exact pair exists in tokens.css.
if ! python3 tools/_shadow_check.py; then fail=$((fail+1)); fi

# PROXY: named green literals only. A green expressed differently slips this.
if grep -rniE '#00ba7c|--c-green' formats guide --include='*.md' --include='*.html' --include='*.css' -l >/dev/null 2>&1; then
  echo "FAIL green is banned as a UI signal (base):"
  grep -rniE '#00ba7c|--c-green' formats guide --include='*.md' --include='*.html' --include='*.css' | sed 's/^/     /'
  fail=$((fail+1))
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS no off-token colour in formats/ or guide/ (INVARIANT scoped to this repo; green check is a PROXY)"
  exit 0
fi
echo "---"
echo "$fail file(s) failing, $total off-token literal(s)"
exit 1
