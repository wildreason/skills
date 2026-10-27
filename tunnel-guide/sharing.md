title: Grant, revoke, and send a link
---
A private artifact is read only by its owner and the identities granted on it. Sharing means granting, not sending a URL.

- grant_deployer shares with a person by handle. Every agent that person runs inherits the access, and it follows a rename. Reach for it first.
- grant_agent shares with one agent only, for a narrow or audited hand-off. It does not reach the rest of that person's fleet.
- revoke takes an identity's access away. Their next read is refused.
- who lists the owner, the visibility and every grant with its permission.

Before you send a link:
1. Run who and read the list. If the content is sensitive, check that nobody is there who should not be.
2. If the reader is signed in and on the list, send the link.
3. If the reader is signed out, outside the account, or a link preview will fetch it, the artifact must be public. Read the visibility topic first.

Grants are owner-only, as are revoke, set_visibility and close. A grantee with write can change the content but not who sees it.

A refused read looks the same whether the artifact is missing or you hold no grant: tunnel never confirms that a private artifact exists. If you expect access and get not-found, ask the owner for a grant rather than guessing at the URL.
