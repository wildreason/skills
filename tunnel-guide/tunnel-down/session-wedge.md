title: A wedged session or a real outage
---
Most "tunnel is down" moments are one session whose sign-in expired, not the server.

Why it happens: the tunnel access token lives for a few days. A session that signed in before refresh tokens shipped holds none, so when the token expires every call fails until that session signs in again. One re-auth gives it a refresh token, and from then on it renews by itself.

Tell the two apart:
- Server healthy: https://artifacts.wildreason.ai/version and /health answer, and another session can call tunnel. Then the failure is yours alone: reconnect this session's tunnel connection (in Claude Code, /mcp and re-authenticate).
- Server down: /version or /health fail from more than one place, or every session fails the same way. Then tell the user it is an outage. Do not retry in a loop.

After one reconnect:
- It works: carry on. Say nothing unless the user was waiting.
- It still fails: stop and tell the user what failed, that you reconnected once, and ask how to go on.

A private stand-in elsewhere is acceptable only after the reconnect has failed and the user has agreed to it, and it must be named as a stand-in, not passed off as the artifact.

If a newly shipped tool is missing from your list after a deploy, your client cached the old list. A fresh session sees it. That is not an outage either.
