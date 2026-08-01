#!/usr/bin/env bash
# publish.sh -- carry formats/ and guide/ to the openlap skill store.
#
# WHY THIS FILE EXISTS (found 2026-08-01 by @quill and @lemming, the hard way):
# this repo had install.sh and three checkers and NO PUBLISH PATH. Nothing
# carried the repo to the store. The hop was a hand-run push, per skill,
# documented nowhere.
#
# The cost, measured: the repo went clean on colour at ~23:50 and four hours
# later BOTH other boxes in the channel were still loading green 24 / violet 18,
# because both had pulled from the store. An author reads the store copy of
# their own skill too -- so the person who "fixed" a skill is reasoning against
# the unfixed bytes, by construction, until this script runs.
#
# A green gate on formats/ proves nothing about what any agent loads. THE GATE
# IS THE FIRST HALF; THIS SCRIPT IS THE SECOND.
#
# WHAT IT DOES, in the only order that verifies anything:
#   1. gate     -- refuse to publish a tree that fails its own checks
#   2. install  -- make ~/.claude/skills match the repo (push reads THAT dir,
#                  never the repo; pushing without this ships stale bytes, which
#                  is a mistake already made once on this repo)
#   3. push     -- one global per skill
#   4. pull     -- bring the STORE's bytes back down
#   5. verify   -- repo == delivered, per file, or exit 1
#
# Step 5 is the point. Steps 1-4 all print success on a store that took nothing.
#
# CLOBBER WARNING: step 4 replaces ~/.claude/skills/<name>/SKILL.md with the
# server copy. `openlap pull` backs local edits up to SKILL.md.local-<ts> first,
# but if you are hand-editing a skill in place, commit it to this repo BEFORE
# running this. Step 2 has already overwritten it by then anyway.

set -uo pipefail
cd "$(dirname "$0")/.."

echo "== 1/5 gate =================================================="
if ! ./tools/check-tokens.sh >/dev/null 2>&1; then
  echo "REFUSING TO PUBLISH: check-tokens.sh is RED. Run it and fix the tree."
  ./tools/check-tokens.sh
  exit 1
fi
if ! python3 tools/check-names.py >/dev/null 2>&1; then
  echo "REFUSING TO PUBLISH: check-names.py is RED."
  python3 tools/check-names.py
  exit 1
fi
echo "   gates green"

skills=()
for d in formats/*/ guide/*/; do
  [ -f "$d/SKILL.md" ] || continue
  skills+=("$(basename "$d")")
done
echo "   ${#skills[@]} skill(s): ${skills[*]}"

echo "== 2/5 install (push reads ~/.claude/skills, NOT this repo) =="
./tools/install.sh >/dev/null || { echo "install failed"; exit 1; }
echo "   installed"

echo "== 3/5 push =================================================="
for s in "${skills[@]}"; do
  out=$(openlap push --skill "$s" 2>&1 | tail -1)
  echo "   $out"
done

echo "== 4/5 pull (fetch back what the STORE actually holds) ======="
#
# THE SIDECAR DELETION IS LOAD-BEARING. Without it this step is a no-op and the
# whole verify is theatre -- @quill caught this within minutes of the first
# version shipping, which had exactly that hole.
#
# Step 2 (install) writes <name>.head.json with the REPO's content_sha256.
# Step 3 pushes those same bytes. `openlap pull` then compares local sidecar to
# store sha, sees them equal, prints "all current" and DOWNLOADS NOTHING -- there
# is no --force. Step 5 would then compare the repo against the bytes install.sh
# had just copied from that same repo. It would pass on a store that took
# nothing, which is the one failure this script exists to catch.
#
# Removing the sidecar makes pull treat the skill as unknown and fetch for real.
# The pins are rewritten by pull, so nothing is lost.
#
# (My own falsification arm missed this: I armed step 5's COMPARISON with an
# injected divergence and never asked whether step 4 had fetched. Arming half a
# mechanism reads as arming it.)
for s in "${skills[@]}"; do
  rm -f "$HOME/.claude/skills/$s.head.json"
done
echo "   sidecars removed -> pull must download rather than compare"
openlap pull >/dev/null 2>&1 || { echo "pull failed -- cannot verify"; exit 1; }
echo "   pulled"

echo "== 5/5 verify repo == delivered =============================="
fail=0
for s in "${skills[@]}"; do
  repo=$(ls formats/"$s"/SKILL.md guide/"$s"/SKILL.md 2>/dev/null | head -1)
  got="$HOME/.claude/skills/$s/SKILL.md"
  if [ ! -f "$got" ]; then
    echo "   FAIL $s -- not delivered to \$HOME/.claude/skills"
    fail=$((fail+1)); continue
  fi
  if cmp -s "$repo" "$got"; then
    echo "   ok   $s"
  else
    echo "   FAIL $s -- repo $(wc -c <"$repo" | tr -d ' ')B != delivered $(wc -c <"$got" | tr -d ' ')B"
    fail=$((fail+1))
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "---"
  echo "$fail skill(s) did NOT round-trip. The store does not hold what this repo holds."
  exit 1
fi
# Step 4's pull rewrites every sidecar WITHOUT a `source` field -- so publishing
# used to erase the provenance install.sh had just stamped, and the next
# install.sh then reported all nine as "pinned by another rail". That note is
# what made a foreign writer look real earlier tonight; it was this flow talking
# to itself. Re-stamp now that the bytes are PROVEN identical to the repo, so
# nothing changes but the pin.
echo "== 6/5 re-stamp provenance (pull writes sourceless pins) ====="
./tools/install.sh >/dev/null 2>&1 || { echo "re-stamp failed"; exit 1; }
echo "   pins carry source=git:wildreason/skills@$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

echo "---"
echo "PASS all ${#skills[@]} skills round-tripped: repo == store == \$HOME/.claude/skills"
echo "NOTE this proves delivery to THIS box. Another box gets these bytes on its"
echo "     next \`openlap pull\` -- it is not pushed to them."
