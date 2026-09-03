# Making the case for foundational work

Reached when the work is foundational and competes against roadmap features. This is the pass that engineering most reliably loses, and it loses on argument quality rather than on merit.

## Why it loses

Product wins roadmap debates by default, because product arrives with a user, a number, and a consequence. Engineering arrives with "this is bad and it scares us."

Both can be true and only one is an argument. The fix is to build the case with the same rigor a product manager would, in the requester's units rather than in engineering's.

## The reframe that carries it

**Foundational work is a velocity argument, not a cleanliness argument.**

Nobody funds debt reduction. People fund "every feature in this area currently takes twice as long, and here is why, and here is what it costs to stop that."

Same work, different frame, completely different reception. Lead with what it unlocks.

## Structure

One page. It competes with roadmap items for the same attention, so it has to be skimmable.

1. **The claim.** One sentence naming the liability and its severity in user terms. The strongest version connects to a core competency: if the product cannot do the one thing it exists to do, nothing else on the roadmap matters.

2. **The evidence.** Specific, and gathered rather than asserted:
   - The incident that already happened, with its duration and its user impact.
   - The uncovered path that allowed it. "This failed because nothing tested it" is nameable and fixable, which beats "this area is risky."
   - The ownership map, measured rather than assumed. See below.
   - Structural facts. Fragmentation, missing enforcement, coupling.

3. **The cost of the status quo**, in the units the business already tracks. Revenue at risk per unit of downtime multiplied by an outage that already occurred is the number that ends arguments. Get it, even approximately.

4. **The velocity upside**, quantified rather than claimed. Compare cycle time on tickets touching this area against the team median. If they take meaningfully longer, that is the argument made numerically.

5. **The ask.** Bounded and specific. A named slice of capacity for a defined duration, with acceptance criteria that say when it is done. Open-ended asks get declined by default because they cannot be planned around.

6. **The trade-off**, presented rather than demanded. See `tradeoffs.md`. Asking for capacity as though it were free is how a good case gets read as naive.

7. **Who does the work.** Not you alone. The project should end with more people able to work in the area than started, which is both the point and the thing that makes it worth funding twice.

## Measure the ownership map rather than repeating the hallway version

Everyone "knows" who owns the scary code, and the received wisdom is usually wrong in an interesting way. Three different measurements that rarely agree:

- **Most commits** identifies who currently dares to touch it. The de facto maintainer.
- **Most surviving lines**, via blame, identifies who actually wrote what is there now.
- **Original authorship** often identifies someone who has left.

The genuinely alarming case is a large file whose majority author is gone, maintained by people who did not write it. That is a materially different risk from "one person is the expert," and showing up with the measured version rather than the hallway version is the difference between an engineering gripe and a credible case.

Cheap to compute and it makes the whole document more believable.

## Check the instinct against the actual liability

A trap worth naming: the interesting version of the problem is often not the important one.

Performance work is more fun than reliability work. Latency is measurable and satisfying to improve. But a path that silently fails for hours is a categorically worse problem than a path that is slow, and leading with the fun one signals that you optimized for your own interest.

Ask what the actual liability is, then lead with that. The interesting work usually rides along anyway.
