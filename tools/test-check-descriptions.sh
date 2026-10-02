#!/usr/bin/env bash
# TUNN-018-030: check-descriptions.py passes every ok-* fixture and fails every
# other one. Each fixture is checked on its own, so one bad fixture can't hide
# behind another.
set -u
cd "$(dirname "$0")/.."
fail=0
for d in tools/fixtures/descriptions/*/; do
  name=$(basename "$d")
  python3 tools/check-descriptions.py "$d/SKILL.md" >/dev/null 2>&1
  rc=$?
  case "$name" in
    ok-*) want=0 ;;
    *)    want=1 ;;
  esac
  if [ "$rc" -ne "$want" ]; then
    echo "FAIL $name: exit $rc, want $want"
    fail=1
  else
    echo "ok   $name (exit $rc)"
  fi
done
[ "$fail" -eq 0 ] && echo "PASS every fixture" || { echo "FAIL"; exit 1; }
