# Handing work over so it stays handed over

Reached from question 3. Delegation that does not stick is worse than no delegation, because it costs the other person's time and yours and produces the same bus factor.

## The loop

Four steps. Step 2 is the one that gets skipped, and skipping it is the difference between a pattern that spreads and a system only you can operate.

1. **Build one instance well.** Not a prototype. A real one, in production, good enough to copy.
2. **Write down the pattern, not the instance.** The generalizable shape, the decisions and why they went that way, the parts that vary. This is the artifact. Without it, step 3 is a tutoring session that has to be repeated per person.
3. **Hand off the second one and review it.** Review against the pattern, not against how you would have written it.
4. **Let someone else own the third, and stop touching it.**

The failure mode is doing step 1 repeatedly. Building five excellent instances yourself feels like five times the output and produces one bus factor.

## The cold start test

The bar is not "documentation exists." The bar is:

**Can someone begin this work without a handoff conversation?**

A handoff conversation is the thing being eliminated, so a doc that works only after you explain it has not passed. Writing docs and assuming they work is not the test.

The test is: hand it to someone cold, watch where they stall, fix the artifact at the point of the stall. Repeat until they do not stall. The stall points are never the ones you would have guessed, which is the entire reason to run it rather than reason about it.

## Delegate at design time

Slices are easy to divide while the work is abstract and hard to divide once you have started. So decide the split before writing implementation, not when it starts to feel safe.

Practically: write the design, run the kickoff, name the slices, name who takes each. Then review rather than implement.

The measurable version: **you are a minority of the commits on projects you designed.** If that number comes in high, the handoff did not happen regardless of whether the project shipped.

## Accept a worse first outcome

This is the part that does not happen through good intentions.

The person taking the work will do it worse than you would have, the first time. That is the price and it is not optional. Two specific failure modes to watch for in yourself:

- **Silent redo.** Accepting the handoff, then quietly rewriting it. This teaches nothing and costs double.
- **Hovering.** Reviewing so closely that nobody actually owns it. Ownership without the authority to make a call is not ownership.

The discipline: define done up front, then do not intervene until the acceptance criteria are genuinely violated. Not when the approach differs from yours. When the criteria are violated.

## Make the handoff worth their while

A handoff framed as a favor to you competes with everything else on their plate. A handoff framed as their growth does not.

Concretely: name what they get out of it, and tell their manager it is happening so it counts on their review. This costs one message and changes whether the handoff survives a busy month.

Better still, ask their manager who they would most like to see grow, and hand it to that person. That outsources the selection to someone with more org context than you have.

## Teach the rule, not the instance

Code review is the highest-frequency surface available for this, and the easiest to underuse. It is daily, already in the workflow, and where tacit standards actually transmit.

"Change this to X" fixes one line. "This is the rule, here is the class of bug it prevents, here is the reference" changes what they write next week.

The stronger version is asking a question that leads them to the fix rather than leaving the fix. Slower, and the only version they retain.

## Stop being the fastest answer

Being first to answer in a shared channel is genuinely valuable and is also the mechanism by which people become critical paths. Every question answered first is a question nobody else learned to answer.

Route instead. "X knows this best," or answer in a thread with the actual owner tagged. This feels like withholding help and is not, and doing it in public means the routing itself teaches who owns what.
