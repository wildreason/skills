title: When tunnel fails to connect or sign in
refs: tunnel-down/session-wedge
---
A connect or sign-in failure is not a content or permission error. Treat it differently.

1. Reconnect once. The usual cause is a session whose sign-in ran out, not a server outage. One re-auth of the tunnel connection usually clears it. tunnel-down/session-wedge says how to tell the two apart.
2. If the reconnect fails, stop. Tell the user that tunnel is unreachable, what you tried, and ask how they want to go on.
3. Do only what they choose.

Never route around it quietly. In particular:
- Do not upload to a different store instead. Another store mints a new link on every upload, keeps no versions and has no grants.
- Do not paste a large file through your own context as base64 because the normal route failed.

A disclosed outage costs the user five seconds. A quiet fallback produces a worse artifact that someone finds later, at a worse time.

A refusal with a code (not_found, permission_denied, doc_closed, invalid_argument) is the server answering. It is not an outage; read its message and the topic it names.
