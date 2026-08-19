---
name: write-ticket
description: Write a Linear ticket in Joey's voice. Use whenever drafting a new Linear ticket, rewriting an existing ticket's description, or turning PR/review feedback into a follow-up ticket.
---

# Write a ticket in Joey's voice

A ticket is a brief, not a spec: prose that tells the assignee why the work exists and what done looks like, leaving the how open for them to explore. The draft is the deliverable — Joey reviews and approves before anything is created or edited in Linear.

## Workflow

1. **Gather the narrative.** A ticket opens by situating the work in the project's ongoing story, so collect what prompted it: the conversation, prior tickets, PRs, ADRs, Slack threads, dashboards. Done when you can write the opening sentence ("With X in place, we're now in a good spot to...") from real context, not invention.
2. **Read the matching reference** from the table below, in full, before writing a word.
3. **Draft** the ticket per Structure and Voice below.
4. **Show Joey the draft and stop.** Wait for his approval; he may rewrite it in his own words. Only after sign-off, create it in Linear: Fundraising team unless he says otherwise, estimate from the 1/2/4/8/16 point scale (powers of two only — split anything that feels bigger than 16).

## References

Real tickets Joey wrote, verbatim, in `references/`:

| File | Read when the ticket is... |
| --- | --- |
| `references/spike.md` | a spike or exploration — unknowns to resolve, a loose process sketch, an Expected Outcomes/AC list of learnings |
| `references/feature-scoped.md` | a larger scoped improvement — earns Goal and Scope sections on top of AC |
| `references/domain-model.md` | new domain modeling or architecture — leans on prior research, credits teammates, links ADRs |
| `references/bug-report.md` | a bug report — prose only, symptom and desired behavior, often no sections at all |
| `references/quick-win.md` | a small well-understood task — two short paragraphs and a 2–3 item AC |
| `references/fe-polish.md` | UI polish from teammate feedback — quote the feedback, then the ask |

The references carry a few dictation typos ("for you feedback", "quick napkin"). The structure and register are the style; the typos are not — write clean.

## Structure

- **Open with prose, no heading.** One to three flowing paragraphs: first the context (why now, what led here), then the intent. The reader learns why before what.
- **Close with one section, chosen by type.** `## Acceptance Criteria` with `- [ ]` checkboxes for features and fixes; `## Expected Outcomes` for spikes; nothing for pure bug reports. Larger tickets may add `## Goal`, `## Scope`, `## Background`, or `## References` between the prose and the AC — only when the ticket genuinely needs them.
- **AC items are outcomes, not steps.** "New scrapes store an S3 URL, never base64" — observable end states someone can check. Include non-goals inline where they save the assignee a detour ("We don't need alerts here, just silently bypass and log") and ops follow-through when it's part of done ("Run it for butter world in production").
- **State the constraints that matter, leave the how open.** Hard rules get said plainly ("As always, NO referential integrity through FKs, enforce in code"); everything else is the assignee's to figure out. When you sketch an approach, label it loose: "the following is a *loose* plan, take liberties where we see fit", "we can leave that as an implementation detail".
- **Titles are imperative with a scope tag** where one applies: `[BE]`, `[FE]`, `[BE + FE]`, `[Spike]`. Backtick identifiers in titles too: ``[BE] Add `website` domain model for NPOs``.

## Voice

- **"We" for team direction, "I" for personal observation and opinion.** "We need to redesign how we store images" vs. "I noticed a few accounts...", "I think option A here is the better bet". Opinions are flagged as opinions and left contestable.
- **Honest uncertainty stays in.** "I'm not exactly sure what's causing this behavior" is a feature — it tells the assignee where the fog is.
- **Conversational register.** Contractions throughout; plain colloquial verbs: whip up, kick off, chew through, bite us, drip feed, napkin math, giant red button. Write like explaining the work to a teammate at a whiteboard.
- **Credit and link prior work.** @mention teammates whose research feeds in, link the tickets, ADR PRs, dashboards, and example URLs.
- **Backticks for every identifier**: table names, columns, commands, flags, model classes.
- **Punctuation:** commas, parentheses, and "though" as the mid-sentence pivot ("We've been relying on Firecrawl to kick these out, though I noticed..."). Never an em dash.

## Write this, not that

| Slop | Joey |
| --- | --- |
| "This ticket aims to implement..." | "With X in place, we're now in a good spot to..." |
| `## Problem` / `## Solution` / `## Implementation` headers | Prose context, then at most Goal/Scope/AC |
| Numbered plan naming files, classes, and methods | Constraints in prose, the how left to the assignee |
| "**Database:** Add a new column..." (bolded lead-in bullets) | Plain bullets in sentence form |
| "leverage", "robust", "seamless", "comprehensive", "ensure" | "use", "solid", "just works", or nothing |
| Exhaustive edge-case enumeration | The one or two cases that actually worry you |
| A closing "Summary" restating the ticket | End on the AC checklist |
