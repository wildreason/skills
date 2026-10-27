#!/usr/bin/env python3
"""Kit gate. Run from the repo root: tools/check-kit.py [--served]

The kit is the copper look every template links: kit.css and kit.js, served by
tunnel at https://artifacts.wildreason.ai/kit/v1/ and inlined by tunnel when it
serves an HTML body. Two copies exist on purpose, and this holds them equal.
(A third, a ```css block in tunnel-a-base/SKILL.md, was dropped in TUNN-100-070:
tunnel serves and inlines the kit, so a skill no longer carries it.)

  1. (retired with that block)

  2. INVARIANT (repo-scoped) -- neither kit file can break out of the tag tunnel
     inlines it into: no "</style", "</script" or "<!--" in either.

  3. With --served: tunnel serves the same bytes as kit/v1/. A read-only GET.
     v1 never changes once published, so a mismatch here means someone edited
     v1 in one place; the fix is a v2, not an edit.

Every template in templates/ must link the kit by its exact tags; that is
checked by each manifest's own finish line (check-templates.py runs it as a
parse; tunnel runs it on the doc).
"""
import hashlib
import pathlib
import sys
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
KIT = ROOT / "kit/v1"
SERVED = "https://artifacts.wildreason.ai/kit/v1/"


def main():
    fails = []
    css = (KIT / "kit.css").read_bytes()
    js = (KIT / "kit.js").read_bytes()
    for name, data in (("kit.css", css), ("kit.js", js)):
        low = data.lower()
        for bad in (b"</style", b"</script", b"<!--"):
            if bad in low:
                fails.append(f"{name} contains {bad.decode()!r}; it would break the inlined tag")
    if "--served" in sys.argv:
        for name, data in (("kit.css", css), ("kit.js", js)):
            try:
                with urllib.request.urlopen(SERVED + name, timeout=20) as r:
                    got = r.read()
            except Exception as e:  # noqa: BLE001 -- report any fetch failure
                fails.append(f"served {name}: {e}")
                continue
            if got != data:
                fails.append(f"served {name} differs from kit/v1/{name}")
    if fails:
        print("FAIL")
        for f in fails:
            print(f"     {f}")
        return 1
    h = lambda b: hashlib.sha256(b).hexdigest()[:16]
    print(f"PASS kit v1: kit.css {len(css)} bytes ({h(css)}), kit.js {len(js)} bytes ({h(js)})"
          f"{', same as served' if '--served' in sys.argv else ''}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
