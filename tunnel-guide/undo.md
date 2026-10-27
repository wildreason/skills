title: Getting an earlier version back
---
Every write keeps the version before it. Nothing is overwritten in history.

1. Run log on the artifact. It lists each version with its time and author. For an image or file, each version also carries a ready restore call.
2. Pick the version N you want. Use diff from N if you need to see what changed since.
3. Call revert with uri and version N.

revert restores text, images and files the same way: version N's bytes and type come back as a new version on top. Nothing after N is lost, and the revert can itself be reverted.

What is refused, with nothing changed:
- an unknown version (and /d/<id>/download?version=N answers 404 for it);
- a binary version whose stored bytes fail the image check.

Do not make a new artifact to undo. A new seed is a new URL, and every link and grant on the old one stays behind.

A closed artifact cannot be reverted. Its history stays readable through log and diff.
