# Fix listing description WYSIWYG editor from truncation

> Bug report · prose only, no sections

We've been dealing with some issues recently of users reporting truncation on descriptions on the editor when posting lots of content. We've tracked this down to silent truncation using our DOM sanitizer (Symfony dependency) where we need to find a better generic solution to the current problem. The listing description editor works around this, but there are other instances where this could potentially bite us since the sanitizer is a common component.

Right now, we're doing a character check on the frontend, though only characters are counted towards DOM sanitization. The problem mostly arises with SVGs and inline images that can be silently stripped.

---

A second bug-report example, this one with honest uncertainty about the cause left in the ticket:

# [BE] Fix smart draft created with default placeholder title

> Bug report · 4 points

There appears to be an issue when we create the listing from the smart draft suggestions, where depending on the timing of the listing creation, we will create it with the default placeholder title that we use as a workaround to be able to create the listing in the first place. Passing an empty title during the creation dialogue on the front end.

We need to fix this so that when the listings are created, they are created with the suggested draft title rather than the default untitled placeholder that we have right now. I'm not exactly sure what's causing this behavior as some listings do create correctly. It seems to be only listings once we've got to the deployed environment on demo where this happens periodically.
