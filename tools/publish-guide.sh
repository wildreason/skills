#!/usr/bin/env bash
# publish-guide.sh -- carry tunnel-guide/ to tunnel's operating guide (TUNN-100).
#
# Tunnel serves the guide in levels to every agent with no skill installed:
# L0 is its initialize instructions (in tunnel's code), L1 topics and L2
# references are this repo's tunnel-guide/, read with templates({action:"guide"}).
# Nothing reaches tunnel until this script runs WITH the publish bearer.
#
#   tools/publish-guide.sh            gate only; never uploads
#   tools/publish-guide.sh --verify   gate, then read the served guide back and
#                                     compare it topic by topic (no bearer)
#   tools/publish-guide.sh --upload   gate, upload, read back, verify
#
# --upload takes the template publish bearer: TUNL_TEMPLATE_PUBLISH_TOKEN_FILE
# (a path to a file holding it). The bearer never reaches a command line: it
# goes to a 0600 header file in the trap-cleaned tmp dir and curl reads it with
# -H @file, so `ps` never shows it.
# TUNL_TEMPLATES_URL picks the server (default https://artifacts.wildreason.ai).
#
# WHAT --upload DOES, in the order that verifies anything:
#   1. gate    -- tools/guide-set.py; refuse a set tunnel would refuse, a
#                 dirty tree (the source commit must describe the bytes sent),
#                 and a HEAD not on origin/main (the source must resolve). The
#                 source is the last commit touching tunnel-guide/ or the tools.
#   2. upload  -- POST the whole set to /api/guide. Tunnel validates it whole
#                 (budgets, index, no L0 text in a body) and writes nothing if
#                 one topic fails. An identical set keeps its version.
#   3. verify  -- GET /api/guide and compare every topic's sha256 with the one
#                 computed here, the ids both ways, and (clean tree) the
#                 source. A topic the server holds an older copy of, or
#                 lacks, or holds extra, or a different source, is a FAIL.
#
# Publishing is a write to prod: run --upload only when the guide is reviewed
# and someone said go.

set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1
cd "$(dirname "$0")/.."

base="${TUNL_TEMPLATES_URL:-https://artifacts.wildreason.ai}"
base="${base%/}"
mode="${1:-}"
case "$mode" in ""|--verify|--upload) ;; *) echo "usage: $0 [--verify|--upload]"; exit 2;; esac

umask 077
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "== 1/3 gate ================================================="
if ! python3 tools/guide-set.py --digests "$tmp/want.json"; then
  echo "REFUSING TO PUBLISH: guide-set.py is RED."
  exit 1
fi
if [ -z "$mode" ]; then
  echo "---"
  echo "gate only (no --upload or --verify): nothing was sent to $base"
  exit 0
fi

# The source is the last commit that changed what is sent (the topics or the
# tool that encodes them), so a later unrelated commit on main still verifies.
paths="tunnel-guide tools/guide-set.py tools/publish-guide.sh"
if git rev-parse -q --git-dir >/dev/null 2>&1; then
  dirty=$(git status --porcelain -- $paths)
else
  dirty="not a git checkout"
fi
src_of() { git log -1 --format=%H -- $paths | cut -c1-12; }

if [ "$mode" = "--upload" ]; then
  if [ "$dirty" = "not a git checkout" ]; then
    echo "REFUSING TO PUBLISH: not a git checkout; the source commit cannot be named."
    exit 1
  fi
  if [ -n "$dirty" ]; then
    echo "REFUSING TO PUBLISH: tunnel-guide/ or the guide tools have uncommitted changes; the source commit would not describe them."
    exit 1
  fi
  # The served source must be a commit anyone can resolve: on origin/main.
  git fetch -q origin main || { echo "REFUSING TO PUBLISH: cannot fetch origin/main to check HEAD is on it."; exit 1; }
  if ! git merge-base --is-ancestor HEAD origin/main; then
    echo "REFUSING TO PUBLISH: HEAD $(git rev-parse --short=12 HEAD) is not on origin/main; publish only merged commits."
    exit 1
  fi
  src=$(src_of)
  [ -n "$src" ] || { echo "REFUSING TO PUBLISH: no commit holds tunnel-guide/"; exit 1; }
  if [ -z "${TUNL_TEMPLATE_PUBLISH_TOKEN_FILE:-}" ] || [ ! -r "$TUNL_TEMPLATE_PUBLISH_TOKEN_FILE" ]; then
    echo "REFUSING TO PUBLISH: set TUNL_TEMPLATE_PUBLISH_TOKEN_FILE to a readable file holding the bearer."
    exit 1
  fi
  tok=""
  IFS= read -r tok < "$TUNL_TEMPLATE_PUBLISH_TOKEN_FILE" || true
  if [ -z "$tok" ]; then echo "REFUSING TO PUBLISH: the bearer file is empty."; exit 1; fi
  case "$tok" in *[[:space:]]*) echo "REFUSING TO PUBLISH: the bearer holds whitespace."; exit 1;; esac
  # printf is a shell builtin: the value goes to the file, never onto an argv.
  printf 'Authorization: Bearer %s\n' "$tok" > "$tmp/auth.hdr"
  tok=""

  echo "== 2/3 upload -> $base/api/guide ============================"
  python3 tools/guide-set.py --json "$tmp/set.json" "$src" >/dev/null || exit 1
  code=$(curl -sS -o "$tmp/out.json" -w '%{http_code}' -X POST "$base/api/guide" \
    -H @"$tmp/auth.hdr" \
    -H "Content-Type: application/json" -H "X-Published-By: git:wildreason/skills@$src" \
    --data-binary @"$tmp/set.json")
  rm -f "$tmp/auth.hdr"
  if [ "$code" != "200" ]; then
    echo "upload FAILED: HTTP $code"
    cat "$tmp/out.json"; echo
    exit 1
  fi
  python3 -c 'import json,sys; r=json.load(open(sys.argv[1])); print("   version %s from %s, %s" % (r["version"], r["source"], "NEW VERSION" if r["changed"] else "unchanged"))' "$tmp/out.json"
else
  echo "== 2/3 upload: skipped (--verify) ============================"
  if [ -n "$dirty" ]; then
    echo "   NOTE source NOT checked ($dirty): comparing topics only"
    src=""
  else
    src=$(src_of)
  fi
fi

echo "== 3/3 verify repo == served ================================"
code=$(curl -sS -o "$tmp/got.json" -w '%{http_code}' "$base/api/guide")
if [ "$code" != "200" ]; then
  echo "FAIL GET /api/guide answered HTTP $code"
  cat "$tmp/got.json"; echo
  exit 1
fi
python3 - "$tmp/want.json" "$tmp/got.json" "$src" <<'PY'
import json, sys
want = json.load(open(sys.argv[1]))
got = json.load(open(sys.argv[2]))
src = sys.argv[3]
served = {t["id"]: t["sha256"] for t in got.get("topics", [])}
fail = 0
for i, d in sorted(want.items()):
    if i not in served:
        print(f"   FAIL {i} -- not served"); fail += 1
    elif served[i] != d:
        print(f"   FAIL {i} -- served copy differs (served {served[i][:12]}, repo {d[:12]})"); fail += 1
    else:
        print(f"   ok   {i}")
for i in sorted(set(served) - set(want)):
    print(f"   FAIL {i} -- served, but not in tunnel-guide/"); fail += 1
if src and got.get("source") != src:
    print(f"   FAIL served source is {got.get('source')!r}, the repo's guide commit is {src!r}"); fail += 1
elif src:
    print(f"   ok   source {src}")
print("---")
if fail:
    print(f"{fail} topic(s) did NOT round-trip. Tunnel does not serve what tunnel-guide/ holds.")
    sys.exit(1)
print(f"PASS every topic in tunnel-guide/ is what tunnel serves (guide v{got['version']}, source {got['source']})")
PY
