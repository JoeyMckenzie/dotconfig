# Scoping ambiguous work

Reached when the ask stays fuzzy after one pass. The goal is not certainty, it is a written frame that someone else could disagree with.

## Convert the request into three things

**A claim.** One sentence asserting what is true and what should change. "Donors on the slow path abandon at a higher rate than donors on the fast path" is a claim. "Improve performance" is not. A claim can be wrong, which is what makes it useful.

**A constraint set.** What is fixed and what is negotiable. Deadlines, compatibility, data that cannot be migrated during business hours, a launch this has to precede. Constraints are where most hidden scope lives, so write them before designing.

**An acceptance criterion.** A condition a person who was not in the conversation could check. "Faster checkout" fails. "The p95 on the charge segment is under 2s and the failure rate stays under its current baseline" passes.

## When the problem is ambiguous to you too

This is the case worth handling deliberately, because the instinct is to go away and resolve it alone and come back with an answer.

Sitting in someone else's unclear problem without taking it over is the harder skill and the more valuable one. Concretely:

- Say out loud that it is unclear, rather than absorbing the ambiguity and resurfacing with a solution.
- Frame the *decision* that needs making rather than the answer. "We need to choose between A and B, and the thing that decides it is X" moves further than either A or B.
- Name what would have to be true for each option. That converts an argument about preference into a question about facts, which someone else can go find.
- Let the person who owns the outcome make the call. Handing them a framed choice is the deliverable.

## Ask the questions that change the work

Not every unknown matters. Rank them by whether the answer changes what gets built:

1. **Blocking**: proceeding under either assumption produces wasted work. Ask before starting.
2. **Load-bearing**: changes the design but not whether to start. State an assumption in writing and proceed. Being explicit about the assumption is what makes it cheap to revisit.
3. **Cosmetic**: interesting, does not change the build. Do not spend the meeting on it.

Most questions that feel blocking are load-bearing. Default to stating the assumption and moving, because a written assumption is a better artifact than a delayed start.

## Signals the scope is wrong rather than unclear

- The request bundles a redesign with a behavior change. Two projects wearing one ticket.
- Nobody can name who is asking for it. Work without a requester has no acceptance criterion by construction.
- The estimate keeps growing as you learn more, rather than converging. That is a sign the boundary is in the wrong place, not that the work is big.
- The only justification is that the current state is bad. See `investment-case.md`.
