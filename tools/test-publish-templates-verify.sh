#!/usr/bin/env bash
# test-publish-templates-verify.sh -- TUNN-100-060, the templates leg: the
# read-only check `tools/publish-templates.sh --verify` passes only when tunnel
# serves exactly the templates of a merged commit, and fails when the server's
# copy is behind, missing one, or holds one the commit dropped. It also refuses
# a source that is not a merged commit: a dirty tree, or a HEAD not on
# origin/main, even when the server serves exactly those bytes.
#
# It copies this checkout into a throwaway git repo with its own bare origin,
# and runs against a fake tunnel on loopback -- never prod. The fake records
# every request, so the test also proves --verify sends no bearer and no write.
#
#   tools/test-publish-templates-verify.sh     last line: TEST: PASS|FAIL
set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1
here="$(cd "$(dirname "$0")/.." && pwd)"

tmp=$(mktemp -d)
srv=""
trap '[ -n "$srv" ] && kill "$srv" 2>/dev/null; rm -rf "$tmp"' EXIT
fails=0
check() { if [ "$1" = 0 ]; then echo "  ok    $2"; else echo "  FAIL  $2"; fails=$((fails+1)); [ -s "$tmp/out" ] && sed "s/^/        | /" "$tmp/out" | tail -6; fi; }
yes_if() { if "$@"; then echo 0; else echo 1; fi; }
no_if()  { if "$@"; then echo 1; else echo 0; fi; }
g() { git -C "$tmp/repo" -c user.name=test -c user.email=test@invalid -c commit.gpgsign=false "$@"; }

# A throwaway repo whose origin/main is its HEAD: the merged-commit case.
mkdir "$tmp/repo"
# --no-same-owner: the copy belongs to whoever runs the test (root on a bench),
# so git needs no safe.directory exception and the script runs git as-is.
tar -C "$here" --exclude=.git -cf - . | tar -C "$tmp/repo" --no-same-owner -xf -
git init -q --bare "$tmp/origin.git"
g init -q -b main && g add -A && g commit -qm base
g remote add origin "$tmp/origin.git" && g push -q origin main

# What the fake serves: the repo's manifests as they sit now, as tunnel's GET
# returns them.
serve_repo() {
  rm -rf "$tmp/served"
  (cd "$tmp/repo" && python3 - "$tmp/served" <<'EOF'
import json, pathlib, sys
sys.path.insert(0, "tools")
from importlib import import_module
ct = import_module("check-templates")
out = pathlib.Path(sys.argv[1]); out.mkdir()
for _, m in ct.load_all():
    f = out / (m["name"] + ".json"); f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text(json.dumps({"id": m["name"] + "@1", "version": 1, "manifest": m}))
EOF
)
}

cat > "$tmp/fake.py" <<'EOF'
import http.server, json, pathlib, sys
served, log, portfile = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
class H(http.server.BaseHTTPRequestHandler):
    def note(self):
        with open(log, "a") as f:
            f.write(json.dumps({"m": self.command, "p": self.path, "auth": "Authorization" in self.headers}) + "\n")
    def send(self, code, b):
        self.send_response(code); self.send_header("Content-Type", "application/json"); self.end_headers(); self.wfile.write(b)
    def do_GET(self):
        self.note()
        if self.path == "/api/templates":
            ids = [json.loads(f.read_text())["id"] for f in sorted(served.rglob("*.json"))]
            return self.send(200, json.dumps({"templates": [{"id": i, "sha256": "x", "published_at": "t"} for i in ids]}).encode())
        f = served / (self.path.removeprefix("/api/templates/") + ".json")
        if self.path.startswith("/api/templates/") and f.is_file():
            return self.send(200, f.read_bytes())
        self.send(404, b'{"error":"template_not_found"}')
    def do_POST(self):
        self.note(); self.send(500, b"{}")
    def log_message(self, *a): pass
s = http.server.HTTPServer(("127.0.0.1", 0), H)
pathlib.Path(portfile).write_text(str(s.server_address[1]))
s.serve_forever()
EOF
serve_repo
: > "$tmp/req.log"
python3 -I "$tmp/fake.py" "$tmp/served" "$tmp/req.log" "$tmp/port" &
srv=$!
for _ in $(seq 50); do [ -s "$tmp/port" ] && break; sleep 0.1; done
[ -s "$tmp/port" ] || { echo "TEST: FAIL the fake tunnel did not start"; exit 1; }
base="http://127.0.0.1:$(cat "$tmp/port")"

run() { (cd "$tmp/repo" && TUNL_TEMPLATES_URL="$base" TUNL_TEMPLATE_PUBLISH_TOKEN="" TUNL_TEMPLATE_PUBLISH_TOKEN_FILE="" \
  bash tools/publish-templates.sh --verify > "$tmp/out" 2>&1); echo $?; }
says() { grep -q -- "$1" "$tmp/out"; }

victim=$(cd "$tmp/served" && ls *.json | head -1); victim=${victim%.json}
src=$(g rev-parse --short=12 HEAD)
older() {  # rewrite one manifest's description, in the served copy or the repo
  python3 - "$1" <<'EOF'
import json, sys
p = sys.argv[1]; d = json.load(open(p))
(d["manifest"] if "manifest" in d else d)["summary"] = "An older version of this template."
json.dump(d, open(p, "w"))
EOF
}

echo "case 1: the server holds the merged commit's templates"
rc=$(run); check $(yes_if [ "$rc" = 0 ]) "--verify exits 0 (got $rc)"
check $(yes_if says "^PASS every template in templates/ at $src") "it prints PASS naming source $src"

echo "case 2: the server is behind on $victim (an older manifest)"
older "$tmp/served/$victim.json"
rc=$(run); check $(yes_if [ "$rc" = 1 ]) "--verify exits 1 (got $rc)"
check $(yes_if says "FAIL $victim -- served manifest differs") "it names $victim as differing"
check $(no_if says "^PASS every template") "it prints no PASS"

echo "case 3: the server does not hold $victim"
serve_repo; rm "$tmp/served/$victim.json"
rc=$(run); check $(yes_if [ "$rc" = 1 ]) "--verify exits 1 (got $rc)"
check $(yes_if says "FAIL $victim -- not served") "it names $victim as not served"
check $(no_if says "^PASS every template") "it prints no PASS"

echo "case 4: the server still holds ghost, a template the commit dropped"
serve_repo; cp "$tmp/served/$victim.json" "$tmp/served/ghost.json"
python3 -c 'import json,sys; p=sys.argv[1]; d=json.load(open(p)); d["id"]="ghost@3"; d["manifest"]["name"]="ghost"; json.dump(d,open(p,"w"))' "$tmp/served/ghost.json"
rc=$(run); check $(yes_if [ "$rc" = 1 ]) "--verify exits 1 (got $rc)"
check $(yes_if says "FAIL ghost -- served, but not in templates/") "it names ghost as an extra"
check $(no_if says "^PASS every template") "it prints no PASS"

mf=$(cd "$tmp/repo" && ls templates/*/manifest.json | head -1)
echo "case 5: a dirty tree ($mf edited, not committed), served exactly"
older "$tmp/repo/$mf"; serve_repo
rc=$(run); check $(yes_if [ "$rc" = 1 ]) "--verify exits 1 (got $rc)"
check $(yes_if says "REFUSING: templates/ or the template tools have uncommitted changes") "it refuses the dirty tree"
check $(no_if says "^PASS every template") "it prints no PASS"

echo "case 6: HEAD committed but not on origin/main, served exactly"
g commit -qam "unmerged edit"
rc=$(run); check $(yes_if [ "$rc" = 1 ]) "--verify exits 1 (got $rc)"
check $(yes_if says "REFUSING: HEAD .* is not on origin/main") "it refuses the unmerged HEAD"
check $(no_if says "^PASS every template") "it prints no PASS"

echo "case 7: the same commit once merged, served exactly"
g push -q origin main
rc=$(run); check $(yes_if [ "$rc" = 0 ]) "--verify exits 0 (got $rc)"
check $(yes_if says "^PASS every template in templates/ at $(g rev-parse --short=12 HEAD)") "it prints PASS naming the new source"

echo "every case: read only"
n=$(grep -c . "$tmp/req.log")
check $(yes_if [ "$n" -gt 0 ]) "the fake saw the reads ($n requests)"
check $(no_if grep -q '"m": "POST"' "$tmp/req.log") "no POST was sent"
check $(no_if grep -q '"auth": true' "$tmp/req.log") "no request carried an Authorization header"

if [ "$fails" -ne 0 ]; then echo "TEST: FAIL $fails check(s)"; exit 1; fi
echo "TEST: PASS"
