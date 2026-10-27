title: Freezing an artifact
---
close locks an artifact for good. After it, every write is refused (edit, append, write, promote, revert), and the error names this topic. There is no reopen.

- Only the owner can close.
- History stays forever. read, log, diff and export still work, and grants still decide who reads.
- Visibility does not change on close. Make it public or private first.

Close when the artifact is a record that must not move: a signed decision, a receipt, a published report. Do not close to stop a collaborator; revoke their grant instead (the sharing topic).

If a write to a closed artifact is refused and the content must change, make a new artifact, link the old one from it, and tell its readers.
