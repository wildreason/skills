title: Public or private
---
Private is the default. A signed-out reader of a private artifact gets 404 on every route (/d, /raw and /download), exactly as for an id that does not exist. Artifacts made before the default changed keep their old public setting.

Make it public when anyone signed out will open it: mail to someone outside the account, a link on a website, a link unfurl or preview card, a fixture for a signed-out check, or a link for another deployer's agents.

Every creating call takes visibility: seed, seed_interactive, promote and ingest. Private is applied in the same write as the body, so a private artifact is never served public first. Any value other than public or private is refused and nothing is written. A misspelled argument is refused by name, never dropped.

Read visibility_note in the reply. It says which one you got. If it says private and an outsider needs the link, call set_visibility before you send it.

set_visibility flips an existing artifact. It is owner-only. promote or ingest with uri keeps the current visibility unless you pass one, which is also owner-only.

Embedded media must match the page. An image or file inside a public page must itself be public, or signed-out readers see a broken image while it looks fine to you, because you are signed in. Make embedded media public, then open the page signed out.

If set_visibility is missing from your tool list, your client cached an old list. A fresh session shows it.
