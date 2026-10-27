#!/usr/bin/env bash
# test-check-pointers.sh -- TUNN-100-070: tools/check-pointers.py passes on this
# tree and fails on each way a skill can stop being a pointer. Every case runs on
# a throwaway copy; this checkout is never edited.
#
#   tools/test-check-pointers.sh     last line: TEST: PASS|FAIL
set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1
here="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fails=0

fresh() {
  rm -rf "$tmp/repo"; mkdir "$tmp/repo"
  tar -C "$here" --exclude=.git -cf - . | tar -C "$tmp/repo" --no-same-owner -xf -
}
run() { python3 "$tmp/repo/tools/check-pointers.py" > "$tmp/out" 2>&1; echo $?; }
expect() {  # expect <rc> <grep pattern> <label>
  rc=$(run)
  if [ "$rc" = "$1" ] && grep -q -- "$2" "$tmp/out"; then echo "  ok    $3"
  else echo "  FAIL  $3 (rc $rc, want $1 and /$2/)"; sed 's/^/        | /' "$tmp/out" | tail -6; fails=$((fails+1)); fi
}
edit() {  # edit <file> <python expression over t>
  python3 - "$tmp/repo/$1" "$2" <<'EOF'
import pathlib, sys
p = pathlib.Path(sys.argv[1]); t = p.read_text()
n = eval(sys.argv[2])
assert n != t, "corruption changed nothing"
p.write_text(n)
EOF
}

echo "case 0: this tree"
fresh; expect 0 "^PASS 9 skills are pointers" "the clean tree passes, 9 skills"

echo "case 1: a format body copies the manual back in"
fresh; edit formats/tunnel-a-notes/SKILL.md 't + " word" * 300'
expect 1 "tunnel-a-notes/SKILL.md: body is .* words, cap 300" "an overlong body fails"

echo "case 2: a format skill drops its template call"
fresh; edit formats/tunnel-a-board/SKILL.md 't.replace("id:\"board\"", "id:\"brief\"")'
expect 1 'tunnel-a-board/SKILL.md: does not name templates({action:"get", id:"board"})' "a missing get call fails"

echo "case 3: a format whose template does not ship"
fresh; rm -rf "$tmp/repo/templates/story"
expect 1 "tunnel-a-story/SKILL.md: templates/story/ does not ship" "a missing template dir fails"

echo "case 4: base drops the guide call"
fresh; edit formats/tunnel-a-base/SKILL.md 't.replace("templates({action:\"guide\"", "templates({action:\"find\"")'
expect 1 'tunnel-a-base/SKILL.md: does not name templates({action:"guide"' "base without the guide call fails"

echo "case 5: a skill names a topic tunnel does not serve"
fresh; edit formats/tunnel-a-brief/SKILL.md 't.replace("topic:\"pages\"", "topic:\"page-rules\"")'
expect 1 'tunnel-a-brief/SKILL.md: names topic:"page-rules"' "an unknown topic:\"...\" fails"

echo "case 5b: a placeholder topic is not a topic"
fresh; grep -q 'topic:"<topic>"' "$tmp/repo/guide/tunnel-an-artifact/SKILL.md" && expect 0 "^PASS" "topic:\"<topic>\" passes" \
  || { echo "  FAIL  the manual no longer holds the placeholder this case needs"; fails=$((fails+1)); }

echo "case 6: base names a reference tunnel does not serve"
fresh; edit formats/tunnel-a-base/SKILL.md 't.replace("`pages/kit-blocks`", "`pages/blocks`")'
expect 1 "names \`pages/blocks\`, but tunnel-guide/pages/blocks.md does not exist" "an unknown reference fails"

echo "case 7: the manual's table names a topic tunnel does not serve"
fresh; edit guide/tunnel-an-artifact/SKILL.md 't.replace("| `undo` |", "| `rollback` |")'
expect 1 "its table names \`rollback\`" "an unknown table topic fails"
grep -q "tunnel-guide/undo.md: no guide skill's table names" "$tmp/out" && echo "  ok    ... and undo is reported unlisted" \
  || { echo "  FAIL  undo not reported unlisted"; fails=$((fails+1)); }

echo "case 8: tunnel gains a topic the manual does not point at"
fresh; printf '# new\n' > "$tmp/repo/tunnel-guide/billing.md"
expect 1 "tunnel-guide/billing.md: no guide skill's table names \`billing\`" "an unlisted topic fails"

echo "case 9: a skill with no frontmatter"
fresh; edit formats/tunnel-a-timeline/SKILL.md 't.replace("---\n", "", 1)'
expect 1 "tunnel-a-timeline/SKILL.md: no frontmatter" "a skill without frontmatter fails"

if [ "$fails" -ne 0 ]; then echo "TEST: FAIL $fails check(s)"; exit 1; fi
echo "TEST: PASS"
