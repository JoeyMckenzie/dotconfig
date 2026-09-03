---
name: think-like-a-staff-engineer
description: Staff-level framing pass to run before implementation. Use when handed an ambiguous or under-specified problem, when scoping or decomposing a project, when a decision will outlive its ticket (boundaries, data model, dependency direction, deploy surface), when making the case for foundational work, or when a request lands that you would otherwise absorb.
---

# Think like a staff engineer

Senior means the work gets done. Staff means the team's capability changed and stayed changed. The gap between them is not effort or skill, it is a set of questions asked *before* implementation that are easy to skip because the work is already tractable.

Run this pass at the start. It is four questions and a tell-check, and it ends with a plan, not code.

The single test everything here serves:

**After this work lands, someone else can do the next one without you.**

## The four questions

Ask in order. Each one is answered in writing before implementation starts. An answer of "unknown" is a valid answer and becomes the first task.

### 1. What is actually being asked, and what does done look like?

Under-specified work invites the shape of the solution to be decided by whoever writes the first line. Convert the request into a claim, a constraint set, and an acceptance criterion someone else could check.

Done when the acceptance criterion is checkable by a person who was not in the conversation. If the ask stays fuzzy after one pass, read [`references/scoping.md`](references/scoping.md).

### 2. What is the blast radius?

Some decisions end with the ticket. Others set a dependency direction, widen a shared surface, or put two failure domains on one deploy. Those are the ones that get made silently inside a PR and are expensive to unmake.

Name what is downstream, and whether this decision is reversible. If it sets a boundary or crosses one, read [`references/blast-radius.md`](references/blast-radius.md).

### 3. Who should own this, and is that you?

The default answer is you, because you are the one holding the ticket, and the default answer is usually wrong. Decide the owner at design time, while the work is still abstract enough to divide.

Done when the slices are named alongside the people who take them. For the mechanics of handing work over so it stays handed over, read [`references/handoff.md`](references/handoff.md).

### 4. What does this displace, and who gets to choose?

Capacity is finite and the person asking usually cannot see what is already in flight. Surfacing the cost and handing the prioritization back is the move. Read [`references/tradeoffs.md`](references/tradeoffs.md).

When the work is foundational and competes against roadmap features, the argument has to be built in the requester's terms rather than in engineering's. Read [`references/investment-case.md`](references/investment-case.md).

## Tells

Signals that the senior move is about to happen instead of the staff move. Each one has a positive counter-move.

| Tell | Counter-move |
| --- | --- |
| You are the only person who could do this task | Pick a second owner now, while the work is still divisible |
| The pattern lives in your head | Write the pattern down as an artifact, then apply it to the instance |
| You said yes without naming what it displaces | Send the cost and the choice back to the requester |
| You are about to write the interesting part yourself | Keep the argument and the acceptance criteria, hand over the interesting part |
| The decision is getting made in a PR | Move it to a written proposal before the branch exists |
| You are the fastest answer in the channel | Route to the owner, in public, so the routing is visible too |
| The plan is a document with no enforcement | Ship the smallest mechanism that makes the rule automatic |

## Leading words

Use these as the vocabulary for the pass. They compress most of the reasoning above.

- **Blast radius**: how far a failure or a change reaches beyond the thing being edited.
- **Bus factor**: how many people can carry a piece of work. One is a defect, not a compliment.
- **Cold start**: whether someone can begin the work with no handoff conversation. The only honest test of documentation.
- **Seam**: a place where work divides cleanly, so it can be reviewed, reverted, or handed over independently.
- **Tacit**: knowledge that works but has never been written down. Tacit process is invisible capability, which means it is capability the team does not have.
- **Multiplier**: work whose output is other people's output.

## Worked examples

Generalized patterns showing the pass applied, including the failure modes: [`references/examples.md`](references/examples.md).

## Output

The pass produces a short written plan carrying, at minimum:

- The claim and the checkable acceptance criterion
- The blast radius, and which decisions are one-way doors
- The seams, with an owner named per slice
- What this displaces, and who was asked to choose
- The artifact that outlives the work, so the next one is cheaper
