#!/usr/bin/env bash
# publish-templates.sh -- carry templates/ to tunnel's template registry (TUNN-033).
#
# Tunnel serves these manifests through its `templates` tool, so any agent on
# any runtime finds them with no skill installed. Nothing reaches tunnel until
# this script runs WITH the publish bearer.
#
# templates/<name>/ is manifest.json plus skeleton.html or skeleton.md.
#
#   tools/publish-templates.sh            gate only; never uploads
#   tools/publish-templates.sh --verify   gate, then read the served templates back
#                                         and compare; no bearer, no write. Exit 1
#                                         if tunnel serves anything but this
#                                         commit's templates (e.g. an older one)
#   tools/publish-templates.sh --upload   gate, upload, read back, verify
#
# --upload needs the bearer set on tunnel-prod: TUNL_TEMPLATE_PUBLISH_TOKEN_FILE
# (a path to a file holding it -- preferred, the value is never in an env) or
# TUNL_TEMPLATE_PUBLISH_TOKEN. The bearer never reaches a command line: it is
# written to a 0600 header file in the trap-cleaned tmp dir and curl reads it
# with -H @file (curl >= 7.55), so `ps` never shows it.
# TUNL_TEMPLATES_URL picks the server (default https://artifacts.wildreason.ai).
#
# WHAT --upload DOES, in the order that verifies anything (same lesson as
# publish.sh: steps that print success prove nothing until a read-back agrees):
#   1. gate     -- tools/check-templates.py; refuse a tree tunnel would refuse
#   2. upload   -- POST every manifest in one batch. Tunnel validates the whole
#                  batch first and writes none of it if one fails. A manifest
#                  whose bytes didn't change keeps its version; a changed one
#                  gets the next version (brief@1 -> brief@2). Old versions stay,
#                  so a doc made under brief@1 is still checked against brief@1.
#   3. verify   -- GET each template back and compare it with the repo file.
#
# Publishing is a write to prod: run --upload only when the templates are
# reviewed and someone said go.

set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1
cd "$(dirname "$0")/.."

base="${TUNL_TEMPLATES_URL:-https://artifacts.wildreason.ai}"
base="${base%/}"

echo "== 1/3 gate ================================================="
if ! python3 tools/check-templates.py; then
  echo "REFUSING TO PUBLISH: check-templates.py is RED."
  exit 1
fi
if ! python3 tools/check-kit.py; then
  echo "REFUSING TO PUBLISH: check-kit.py is RED. The templates link a kit this repo does not hold."
  exit 1
fi

mode="${1:-}"
case "$mode" in ""|--verify|--upload) ;; *) echo "usage: $0 [--verify|--upload]"; exit 2;; esac
if [ -z "$mode" ]; then
  echo "---"
  echo "gate only (no --upload or --verify): nothing was sent to $base"
  exit 0
fi
# The source must be a commit, not a working tree: what is uploaded or compared
# is what HEAD holds, and HEAD is on origin/main so anyone can resolve it. Tunnel
# stores X-Published-By but does not serve it back, so --verify proves "served ==
# the templates at merged commit <src>", not which commit did the upload.
paths="templates tools/publish-templates.sh tools/check-templates.py"
git rev-parse -q --git-dir >/dev/null 2>&1 || { echo "REFUSING: not a git checkout; the source commit cannot be named."; exit 1; }
dirty=$(git status --porcelain -- $paths)
if [ -n "$dirty" ]; then
  echo "REFUSING: templates/ or the template tools have uncommitted changes; no commit describes them:"
  echo "$dirty" | head -5
  exit 1
fi
git fetch -q origin main || { echo "REFUSING: cannot fetch origin/main to check HEAD is on it."; exit 1; }
if ! git merge-base --is-ancestor HEAD origin/main; then
  echo "REFUSING: HEAD $(git rev-parse --short=12 HEAD) is not on origin/main; only a merged commit is a source."
  exit 1
fi
src=$(git rev-parse --short=12 HEAD)
echo "source   git:wildreason/skills@$src"

umask 077
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
python3 - "$tmp/batch.json" <<'EOF'
import json, pathlib, sys
sys.path.insert(0, "tools")
from importlib import import_module
ct = import_module("check-templates")
pathlib.Path(sys.argv[1]).write_text(json.dumps([m for _, m in ct.load_all()]))
for d, m in ct.load_all():
    pathlib.Path(sys.argv[1]).with_name(d.name + ".want.json").write_text(json.dumps(m))
EOF

if [ "$mode" = "--verify" ]; then
  echo "== 2/3 upload: skipped (--verify) ============================"
else
tok=""
if [ -n "${TUNL_TEMPLATE_PUBLISH_TOKEN_FILE:-}" ]; then
  if [ ! -r "$TUNL_TEMPLATE_PUBLISH_TOKEN_FILE" ]; then
    echo "REFUSING TO PUBLISH: TUNL_TEMPLATE_PUBLISH_TOKEN_FILE is not a readable file."
    exit 1
  fi
  IFS= read -r tok < "$TUNL_TEMPLATE_PUBLISH_TOKEN_FILE" || true
else
  tok="${TUNL_TEMPLATE_PUBLISH_TOKEN:-}"
fi
unset TUNL_TEMPLATE_PUBLISH_TOKEN
if [ -z "$tok" ]; then
  echo "REFUSING TO PUBLISH: no bearer (set TUNL_TEMPLATE_PUBLISH_TOKEN_FILE)."
  exit 1
fi
case "$tok" in *[[:space:]]*) echo "REFUSING TO PUBLISH: the bearer holds whitespace."; exit 1;; esac
# printf is a shell builtin: the value goes to the file, never onto an argv.
printf 'Authorization: Bearer %s\n' "$tok" > "$tmp/auth.hdr"
tok=""

echo "== 2/3 upload -> $base/api/templates =========================="
by="git:wildreason/skills@$src"
code=$(curl -sS -o "$tmp/out.json" -w '%{http_code}' -X POST "$base/api/templates" \
  -H @"$tmp/auth.hdr" \
  -H "Content-Type: application/json" -H "X-Published-By: $by" \
  --data-binary @"$tmp/batch.json")
if [ "$code" != "200" ]; then
  echo "upload FAILED: HTTP $code"
  cat "$tmp/out.json"; echo
  exit 1
fi
python3 - "$tmp/out.json" <<'EOF'
import json, sys
for r in json.load(open(sys.argv[1]))["published"]:
    print(f"   {r['id']:<16} {'NEW VERSION' if r['changed'] else 'unchanged'}")
EOF
fi

echo "== 3/3 verify repo == served ================================"
fail=0
for d in templates/*/; do
  d=${d%/}
  f="$tmp/$(basename "$d").want.json"
  name=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["name"])' "$f")
  if ! curl -sSf -o "$tmp/got.json" "$base/api/templates/$name"; then
    echo "   FAIL $name -- not served"
    fail=$((fail+1)); continue
  fi
  # Tunnel stores the manifest re-encoded and drops empty fields, so compare
  # meaning, not bytes.
  if python3 - "$f" "$tmp/got.json" <<'EOF'
import json, sys
def norm(v):
    if isinstance(v, dict):
        return {k: norm(x) for k, x in v.items() if x not in (None, "", [], {}, False) and not (k == "level" and x == 0)}
    if isinstance(v, list):
        return [norm(x) for x in v]
    return v
want = norm(json.load(open(sys.argv[1])))
got = json.load(open(sys.argv[2]))
sys.exit(0 if norm(got["manifest"]) == want else 1)
EOF
  then
    echo "   ok   $(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["id"])' "$tmp/got.json")"
  else
    echo "   FAIL $name -- served manifest differs from $d/"
    fail=$((fail+1))
  fi
done

# An extra: a template tunnel still serves that this commit no longer holds.
if ! curl -sSf -o "$tmp/list.json" "$base/api/templates"; then
  echo "   FAIL GET /api/templates did not answer; extras not checked"
  fail=$((fail+1))
else
  extra=$(python3 - "$tmp/list.json" "$tmp" <<'EOF'
import json, pathlib, re, sys
want = {json.loads(f.read_text())["name"] for f in pathlib.Path(sys.argv[2]).glob("*.want.json")}
for t in json.load(open(sys.argv[1])).get("templates", []):
    name = re.sub(r"@[0-9]+$", "", t.get("id", ""))
    if name not in want:
        print(name)
EOF
)
  for name in $extra; do
    echo "   FAIL $name -- served, but not in templates/ at $src"
    fail=$((fail+1))
  done
fi

if [ "$fail" -ne 0 ]; then
  echo "---"
  echo "$fail template(s) did NOT round-trip. Tunnel does not serve what this repo holds."
  exit 1
fi
echo "---"
echo "PASS every template in templates/ at $src is what $base serves, and it serves no other"
