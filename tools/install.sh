#!/usr/bin/env bash
# install.sh -- land the tunnel formats where the harness reads them, and pin them.
#
# Two things this does that a bare `cp` does not:
#
#   1. It writes a PIN. Each skill gets a <name>.head.json alongside it, in the
#      format openlap already uses -- {version, content_sha256, pulled_at,
#      source}. Adopted, not invented: openlap's backpack writes the same file,
#      and a second pin format would be a defect.
#
#   2. It stamps `source: git:wildreason/skills@<sha>`. openlap's backpack does
#      not write a `source` field, and an ABSENT source must read as UNKNOWN --
#      never as "backpack". Defaulting a missing field to a specific value
#      stamps a derived value as captured data and freezes a fabricated claim
#      into a receipt that still validates. Freshness checks skip what they do
#      not own, so a foreign or unknown pin sits out rather than being corrected.
#
# It also REFUSES to be silent when it finds a pin it does not own: the installer
# is the only actor that sees both rails, so detection belongs here. It reports;
# it does not gate.
#
# NOTE ~/.claude/skills is often a SYMLINK into another tool's managed tree
# (openlap materializes into ~/.openlap/skills, a git repo with no remote). We
# copy INTO it. Never clone over it -- that fights whoever manages that tree.

set -euo pipefail
cd "$(dirname "$0")/.."

DEST="${1:-$HOME/.claude/skills}"
SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
SRC="git:wildreason/skills@${SHA}"

mkdir -p "$DEST"
installed=0
foreign=0
unshadowed=0

# UPGRADE PATH -- the case a clean install never exercises, and the one every
# real box is in.
#
# A prior release shipped alias symlinks (apple-html -> tunnel-a-doc, reporting
# -> tunnel-a-report, ...). Copying new bodies over the top leaves those aliases
# in place, still resolving, still ALPHABETICALLY FIRST -- and a harness that
# de-duplicates skill directories keeps the first name. Measured: after an
# upgrade, 5 of 5 canonical names were still shadowed. The install would have
# delivered the reconciled tokens and NONE of the vocabulary fix, silently.
#
# So: remove any symlink in DEST that points at a directory this repo owns.
# Only symlinks, only ones aimed at our names -- a real directory or a link to
# something else is somebody else's and is left alone.
for link in "$DEST"/*; do
  [ -L "$link" ] || continue
  target=$(basename "$(readlink "$link")")
  [ -d "formats/$target" ] || [ -d "guide/$target" ] || continue
  echo "  unshadow  $(basename "$link") -> $target (alias hid the canonical name)"
  rm -f "$link"
  unshadowed=$((unshadowed+1))
done

for dir in formats/*/ guide/*/; do
  name=$(basename "$dir")
  pin="$DEST/${name}.head.json"

  if [ -f "$pin" ]; then
    existing=$(grep -o '"source"[[:space:]]*:[[:space:]]*"[^"]*"' "$pin" 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/' || true)
    if [ -z "$existing" ]; then
      echo "  note  $name has a pin with NO source -- another rail wrote it. Overwriting with $SRC."
      foreign=$((foreign+1))
    elif [ "${existing%@*}" != "${SRC%@*}" ]; then
      echo "  note  $name is pinned to '$existing', not this repo. Overwriting."
      foreign=$((foreign+1))
    fi
  fi

  rm -rf "${DEST:?}/${name}"
  cp -R "$dir" "$DEST/$name"

  # REFUSE a symlink inside a skill, rather than hashing around it.
  #
  # The sha below uses `-type f`, which does NOT follow symlinks -- so a
  # symlinked file inside a skill would be silently ABSENT from the pin while
  # the pin still claimed to cover the skill. That is the exact defect class
  # that cost four wrong readings on 2026-08-01: `find -type f` called a full
  # tree empty, `diff` called a link a fork, `[ -d ]` called a link a real
  # directory, and a sha of a link against its own target proved a tautology.
  # A content_sha256 that under-covers is worse than none, because provenance
  # is what everyone reasons from afterwards.
  #
  # Refusing is correct rather than merely safe: ART-075 made every skill ONE
  # FILE so it can travel (the store has no companion ingress, OLP-430). A
  # symlink inside a skill dir already violates that contract, so there is
  # nothing to preserve -- fail loud and fix the tree.
  if [ -n "$(find "$DEST/$name" -type l -print -quit)" ]; then
    echo "  FATAL $name contains a symlink -- skills are single files (ART-075) and"
    echo "        a -type f content sha would silently omit it:"
    find "$DEST/$name" -type l -exec ls -ld {} \; | sed 's/^/          /'
    exit 1
  fi

  sha=$(find "$DEST/$name" -type f -exec shasum -a 256 {} + | sort | shasum -a 256 | cut -d' ' -f1)
  cat > "$pin" <<JSON
{
  "version": 1,
  "content_sha256": "$sha",
  "scripts_hash": "",
  "pulled_at": "$NOW",
  "source": "$SRC"
}
JSON
  installed=$((installed+1))
done

echo "installed $installed skills into $DEST, pinned at $SRC"
[ "$foreign" -gt 0 ] && echo "  ($foreign pin(s) were not ours -- reported above, not silently replaced)"
exit 0
