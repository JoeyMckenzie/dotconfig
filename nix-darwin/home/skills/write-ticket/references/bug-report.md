# Fix campaign story WYSIWYG editor from truncation

> RAISE-3306 · Bug report · prose only, no sections

We've been dealing with some issues recently of users reporting truncation on stories on the editor when posting lots of content. We've tracked this down to silent truncation using our DOM sanitizer (Symfony dependency) where we need to find a better generic solution to the current problem. The campaign story editor works around this, but there are other instances where this could potentially bite us since the sanitizer is a common component.

Right now, we're doing a character check on the frontend, though only characters are counted towards DOM sanitization. The problem mostly arises with SVGs and inline images that can be silently stripped.

---

A second bug-report example, this one with honest uncertainty about the cause left in the ticket:

# [BE] Fix magic campaign created with default campaign title

> RAISE-3151 · Bug report · 4 points

There appears to be an issue when we create the campaign from the magic suggestions, where depending on the timing of the campaign creation, we will create it with the default campaign title that we use as a workaround to be able to create the campaign in the first place. Passing an empty campaign title during the campaign creation dialogue on the front end. Example [here](https://demo.givebutter.com/untitled-campaign-htn01a/joeymckenzie).

We need to fix this so that when the campaigns are created, they are created with the suggested Magic Campaign title rather than the default untitled campaign placeholder that we have right now. I'm not exactly sure what's causing this behavior as some campaigns do create correctly. It seems to be only campaigns once we've got to the deployed environment on demo where this happens periodically.
