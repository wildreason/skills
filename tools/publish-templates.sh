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
#   tools/publish-templates.sh --upload   gate, upload, read back, verify
#
# --upload needs TUNL_TEMPLATE_PUBLISH_TOKEN (the bearer set on tunnel-prod).
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

if [ "${1:-}" != "--upload" ]; then
  echo "---"
  echo "gate only (no --upload): nothing was sent to $base"
  exit 0
fi
if [ -z "${TUNL_TEMPLATE_PUBLISH_TOKEN:-}" ]; then
  echo "REFUSING TO PUBLISH: TUNL_TEMPLATE_PUBLISH_TOKEN is not set."
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "== 2/3 upload -> $base/api/templates =========================="
python3 - "$tmp/batch.json" <<'EOF'
import json, pathlib, sys
sys.path.insert(0, "tools")
from importlib import import_module
ct = import_module("check-templates")
pathlib.Path(sys.argv[1]).write_text(json.dumps([m for _, m in ct.load_all()]))
for d, m in ct.load_all():
    pathlib.Path(sys.argv[1]).with_name(d.name + ".want.json").write_text(json.dumps(m))
EOF
by="git:wildreason/skills@$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
code=$(curl -sS -o "$tmp/out.json" -w '%{http_code}' -X POST "$base/api/templates" \
  -H "Authorization: Bearer $TUNL_TEMPLATE_PUBLISH_TOKEN" \
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

if [ "$fail" -ne 0 ]; then
  echo "---"
  echo "$fail template(s) did NOT round-trip. Tunnel does not serve what this repo holds."
  exit 1
fi
echo "---"
echo "PASS every template in templates/ is what $base serves"
