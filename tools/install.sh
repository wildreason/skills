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
