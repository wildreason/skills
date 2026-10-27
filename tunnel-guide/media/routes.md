title: Serving routes for images and files
---
Once an artifact holds an image or a file, three routes serve it.

- /d/<id>/download returns the raw bytes with the right content-type. This is the URL for img src and any embed, and it is the download_url a create reply carries. Image types a browser renders (png, jpeg, gif, webp, svg, bmp) are served inline. Everything else (an archive, a disk image, a release binary) is served as an attachment, so a browser saves it instead of showing it. That is deliberate.
- /d/<id>/raw serves the same bytes with the same type for a binary artifact.
- /d/<id> is the viewer page around it. For an image it shows the image itself.

/d/<id>/download?version=N serves version N. An unknown version is 404.

All three answer 404 to a signed-out reader when the artifact is private, the same answer as for an id that does not exist. A public page that embeds a private image therefore shows a broken image to anyone signed out. You will not see it, because you are signed in: open the page signed out to check.

Use a data URI only when the page must work as a single downloaded file. Otherwise host the image as its own artifact and point at its download_url, so the image is versioned, can be replaced in place, and is not resent with every page write.
