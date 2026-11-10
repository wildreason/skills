title: A live preview beside the page, with the microphone
---
A fellow sometimes runs a live page somewhere else (a pod, a dev server) that needs the microphone, and wants it next to the artifact that explains it. An html artifact can declare ONE such origin. The reader then frames that page beside the artifact and grants the microphone to it, and only to it. The artifact's own script never gets the microphone.

Declare it
Pass preview_origin to seed or write, or to POST /api/seed:
  seed({markdown: "<!DOCTYPE html>...", type: "html", preview_origin: "https://abc123-8000.proxy.runpod.net"})
  write({uri, markdown, preview_origin: "https://pod.example.com:8443"})
Pass "" to remove it. Leave it out and the body is kept as you send it.

The value is exactly one origin: https, a lower-case host, and an optional port that is not 443. It has no path, no trailing slash, no query, no user, no wildcard and no list, and it is never a wildreason.ai host. Anything else is refused with invalid_field, and nothing is written. Only an html artifact can declare an origin.

Where it lives
The declaration is one tag in the body, written for you just after <head>:
  <meta name="tunnel-preview" content="https://pod.example.com">
It is versioned with the body, so log and diff show it, revert restores or removes it with the body, and a reader of the source sees it. If you write the tag by hand with edit or append, it is not checked when you write it. A tag that is invalid, or a second tag, makes the reader serve the ordinary page with no preview, so a mistake never opens anything.

What the reader shows
For an artifact that declares an origin, the reader page holds two frames, one above the other:
- the artifact, in the top 40 percent, in exactly the sandbox it always has: scripts, forms and popups, but never same-origin access and never the microphone;
- the declared page, ORIGIN + "/", in the bottom 60 percent, with allow="microphone ORIGIN". It is the root path, so serve the live page at /.
The reader page's own policy lets it frame that one origin and nothing else (CSP frame-src), and its Permissions-Policy grants the microphone only to the page itself and that origin. The browser shows its usual microphone prompt to the person reading.

What the artifact gives up while it declares
- It may frame only the declared origin. Any other iframe in the body is blocked. A frame of the origin that the body draws itself still gets no microphone.
- Pointing and review marks from the reader do not reach the body while it declares.
Remove the declaration and the artifact is byte for byte what it was before.

What the live page must allow
Browsers only show it if it lets tunnel frame it. Its Content-Security-Policy frame-ancestors (or X-Frame-Options) must allow https://artifacts.wildreason.ai and https://wildreason.ai. A page that forbids framing shows an empty frame, and tunnel cannot fix that from its side.

Readers of the source
GET /d/<id>/view answers with the header X-Artifact-Preview-Origin: <origin> when the body declares one valid origin, and with no such header otherwise. It is meant for the Wildreason app's reader, so it can delegate the microphone through its own frame too.
