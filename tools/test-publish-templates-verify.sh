#!/usr/bin/env bash
# test-publish-templates-verify.sh -- TUNN-100-060, the templates leg: the
# read-only check `tools/publish-templates.sh --verify` passes only when tunnel
# serves exactly this commit's templates, and fails when the server's copy is
# behind (an older manifest) or missing one.
#
# It runs against a fake tunnel on loopback, never against prod. The fake
# records every request, so the test also proves --verify sends no bearer and
# makes no write.
#
#   tools/test-publish-templates-verify.sh     last line: TEST: PASS|FAIL
set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1
cd "$(dirname "$0")/.."

tmp=$(mktemp -d)
srv=""
trap '[ -n "$srv" ] && kill "$srv" 2>/dev/null; rm -rf "$tmp"' EXIT
fails=0
check() { if [ "$1" = 0 ]; then echo "  ok    $2"; else echo "  FAIL  $2"; fails=$((fails+1)); fi; }

# What the fake serves: this commit's manifests, as tunnel's GET returns them.
python3 - "$tmp/served" <<'EOF'
import json, pathlib, sys
sys.path.insert(0, "tools")
from importlib import import_module
ct = import_module("check-templates")
out = pathlib.Path(sys.argv[1]); out.mkdir()
for _, m in ct.load_all():
    (out / (m["name"] + ".json")).write_text(json.dumps({"id": m["name"] + "@1", "version": 1, "manifest": m}))
EOF

cat > "$tmp/fake.py" <<'EOF'
import http.server, json, pathlib, sys
served, log, portfile = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
class H(http.server.BaseHTTPRequestHandler):
    def note(self):
        with open(log, "a") as f:
            f.write(json.dumps({"m": self.command, "p": self.path, "auth": "Authorization" in self.headers}) + "\n")
    def do_GET(self):
        self.note()
        name = self.path.removeprefix("/api/templates/")
        f = served / (name + ".json")
        if self.path.startswith("/api/templates/") and f.exists():
            b = f.read_bytes(); self.send_response(200)
        else:
            b = b'{"error":"template_not_found"}'; self.send_response(404)
        self.send_header("Content-Type", "application/json"); self.end_headers(); self.wfile.write(b)
    def do_POST(self):
        self.note(); self.send_response(500); self.end_headers()
    def log_message(self, *a): pass
s = http.server.HTTPServer(("127.0.0.1", 0), H)
pathlib.Path(portfile).write_text(str(s.server_address[1]))
s.serve_forever()
EOF
: > "$tmp/req.log"
python3 -I "$tmp/fake.py" "$tmp/served" "$tmp/req.log" "$tmp/port" &
srv=$!
for _ in $(seq 50); do [ -s "$tmp/port" ] && break; sleep 0.1; done
[ -s "$tmp/port" ] || { echo "TEST: FAIL the fake tunnel did not start"; exit 1; }
base="http://127.0.0.1:$(cat "$tmp/port")"

run() { TUNL_TEMPLATES_URL="$base" TUNL_TEMPLATE_PUBLISH_TOKEN="" TUNL_TEMPLATE_PUBLISH_TOKEN_FILE="" \
  bash tools/publish-templates.sh --verify > "$tmp/out" 2>&1; echo $?; }

victim=$(ls "$tmp/served" | head -1); victim=${victim%.json}

echo "case 1: the server holds this commit's templates"
rc=$(run); check $([ "$rc" = 0 ] && echo 0 || echo 1) "--verify exits 0 (got $rc)"
grep -q "^PASS every template" "$tmp/out"; check $? "it prints PASS"

echo "case 2: the server is behind on $victim (an older manifest)"
python3 - "$tmp/served/$victim.json" <<'EOF'
import json, sys
p = sys.argv[1]; d = json.load(open(p))
d["manifest"]["description"] = "an older version of this template"
json.dump(d, open(p, "w"))
EOF
rc=$(run); check $([ "$rc" = 1 ] && echo 0 || echo 1) "--verify exits 1 (got $rc)"
grep -q "FAIL $victim -- served manifest differs" "$tmp/out"; check $? "it names $victim as differing"
grep -q "^PASS" "$tmp/out"; check $([ $? != 0 ] && echo 0 || echo 1) "it prints no PASS"

echo "case 3: the server does not hold $victim"
rm "$tmp/served/$victim.json"
rc=$(run); check $([ "$rc" = 1 ] && echo 0 || echo 1) "--verify exits 1 (got $rc)"
grep -q "FAIL $victim -- not served" "$tmp/out"; check $? "it names $victim as not served"

echo "every case: read only"
n=$(grep -c . "$tmp/req.log")
check $([ "$n" -gt 0 ] && echo 0 || echo 1) "the fake saw the reads ($n requests)"
grep -q '"m": "POST"' "$tmp/req.log"; check $([ $? != 0 ] && echo 0 || echo 1) "no POST was sent"
grep -q '"auth": true' "$tmp/req.log"; check $([ $? != 0 ] && echo 0 || echo 1) "no request carried an Authorization header"

if [ "$fails" -ne 0 ]; then echo "TEST: FAIL $fails check(s)"; exit 1; fi
echo "TEST: PASS"
