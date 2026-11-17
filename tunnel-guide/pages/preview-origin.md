title: A live preview beside the page (preview origin)
---
Use this when an html artifact goes with a live page of yours, for example a pod that needs the microphone. Tunnel can frame that page beside the artifact. The artifact itself never gets the microphone.

## Declare it

Pass preview_origin to seed or write (or to POST /api/seed). It must be one https origin in lower case, with an optional port: https://host or https://host:port. A path, a trailing slash, a query, userinfo, a wildcard or a list is refused.

Tunnel stores it in the body as one tag, `<meta name="tunnel-preview" content="https://host:port">`. Because the tag is part of the body, it is versioned with it: log and diff show it, and revert brings it back. Pass "" to remove it. If you leave preview_origin out, the body is kept as you sent it. A body that declares an invalid origin, or declares two, is refused.

Only html artifacts take it.

## What the reader frames

When an html artifact declares one valid origin, the reader serves a host page instead of the bare body. The host page holds two frames side by side:

1. The artifact body, with exactly the sandbox it always has. That sandbox does not include the microphone or same-origin access.
2. Your declared origin's root page (`https://host:port/`), framed with allow="microphone https://host:port". This is the only frame that can ask for the microphone.

The host page has no script of its own. Its CSP lets it frame only the declared origin, and its Permissions-Policy grants the microphone only to itself and that origin. An artifact with no declaration, or with an invalid one, gets the ordinary reader page, byte for byte.

## The body never gets the microphone

The artifact's own script cannot reach the microphone, whether or not it declares an origin. If you need audio, it has to come from your preview page, never from the body. Do not try to frame your origin from inside the body: that frame gets no microphone either, because the body's sandbox still applies.

## What the body gives up while it declares

The page kit runs unpinned, because its parent is the host page and not the reader. So pointing and scroll messages do not reach the reader. The body may frame only the declared origin. If you need those back, remove the declaration (preview_origin "").
