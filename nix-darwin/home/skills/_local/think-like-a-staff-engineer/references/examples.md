# Worked examples

Generalized patterns, each showing the pass applied and the failure mode it avoids. Anonymized on purpose. The shapes recur.

## 1. The template that spread on its own

**Situation.** One subsystem needed instrumentation. The obvious move was to instrument all of it.

**What happened instead.** One handler was instrumented well, the pattern was written down, and the second one was handed to another engineer. That engineer then started adding instrumentation to unrelated code unprompted, without being asked and without further explanation.

**Why it worked.** The pattern was legible enough to copy without its author present. That is the whole mechanism, and it lives entirely in the step everyone skips.

**The lesson.** The output was not instrumentation, it was an engineer who now instruments things. Build one, write the pattern, hand over the second.

## 2. The tacit process next to the visible problem

**Situation.** A team had a review-quality problem. Changes were arriving under-reviewed, and the tell was basic conventions missing, which meant nobody had read their own diff.

**The overlooked fact.** Two people on the team had a disciplined multi-pass self-review flow. It had never been written down. Best process knowledge on the team sat tacit while the team visibly lacked it.

**The move.** Encode the flow as a repo artifact so it applies by default rather than by memory.

**Why this is the highest-leverage shape.** It requires no permission, no reorganization, and no awkward conversation. It converts a personal habit into team capability, which is the definition of the multiplier move. Look for this pattern specifically: **your own undocumented defaults, sitting beside a team problem those defaults would solve.**

## 3. The bus factor that was not who everyone thought

**Situation.** A legacy payment path everyone avoided. Received wisdom was that one engineer was the sole expert.

**What measurement showed.** Three different answers. The engineer with the most commits was the current maintainer. A different engineer had written most of the surviving lines. And the largest file in the path was roughly three quarters authored by a contractor who had left the company.

**Why it mattered.** "One person is the expert" is a staffing risk. "Nobody currently here wrote the majority of this, and the people maintaining it did not write it" is a different and worse problem requiring a different fix.

**The lesson.** Measure the ownership map. Arriving with the measured version rather than the hallway version is what makes a case credible.

## 4. Enforcement before the manifesto

**Situation.** A codebase with a domain structure, genuine intent behind it, and no enforcement whatsoever. Roughly half the code outside the intended structure, one core concern split across three locations, no dependency checks.

**The tempting move.** Write the architecture direction document.

**The better sequence.** Add the checking mechanism first, on a boundary that already mostly holds. Pin one real boundary in CI. Then write the document, with the check already in the repo catching violations.

**Why the order matters.** A document with a working mechanism attached is a plan. A document alone is an opinion, and it loses to whoever shipped a feature that week.

## 5. The interesting problem versus the important one

**Situation.** A checkout path was both slow and occasionally silently broken. The engineer's instinct, stated in their own self-assessment, was to reduce latency.

**What leadership actually cared about.** A payment method that had failed silently for six hours. Not the latency.

**The distinction.** Slow is a degraded experience. Silent failure means the product did not do the one thing it exists to do, and nobody found out. Categorically different severities.

**The lesson.** Reliability beats performance when the product's core competency is at stake. Check whether your instinct matched the actual liability before building the case, because leading with the fun problem signals whose interests you optimized for.

## 6. The prerequisite hiding inside the growth area

**Situation.** An engineer received consistent feedback across two review cycles and multiple reviewers, all describing the same behavior in different words. Absorbing work rather than distributing it. Everyone treated it as a growth area.

**The reframe from a level up.** It was not a growth area, it was a prerequisite, with a pass-or-fail test: *anyone can pick up this work without a handoff.*

**Why the reframe changed everything.** A growth area gets incremental effort. A prerequisite gets sequenced first. The same feedback, correctly categorized, reorders the entire plan.

**The lesson.** When feedback recurs across independent reviewers and cycles, it has stopped being feedback and become a finding. Ask whether it is a gate rather than a gradient, because the two get worked differently.
