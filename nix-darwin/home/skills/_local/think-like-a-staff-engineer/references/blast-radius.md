# Blast radius and decisions that outlive the ticket

Reached when a decision sets or crosses a boundary. These are the decisions that get made silently inside a PR and are expensive to unmake, which is exactly why they deserve a written pass.

## Classify the decision first

**Reversible.** Changing it later costs a normal refactor. Make the call, note it, move on. Most decisions are here and treating them as heavier than they are is its own failure mode.

**One-way door.** Changing it later requires a migration, a coordinated deploy, a data backfill, or agreement from a team that does not report to you. These earn a written proposal before a branch exists.

The common one-way doors:

- Dependency direction between modules. Easy to add, hard to reverse once both sides assume it.
- Anything that widens a shared surface, especially a table other domains read or a type other teams import.
- Putting two failure domains on one deploy surface, which converts an incident in one into an incident in both.
- Data model shape, particularly a column on a hot table or a nullable field that becomes load-bearing.
- Anything that becomes a public contract, including internal APIs other teams start depending on.

## Ask what is downstream

Name the things that break if this is wrong. Not hypothetically. Actually go look:

- Which modules import this, and which of those belong to other teams.
- Whether the change shares a deploy with something that has a different risk profile. A payment path and a reporting path failing together is a different severity than either failing alone.
- What the failure looks like from outside. Silent failure is worse than loud failure and is usually the one that goes undetected, so ask specifically whether this can fail without anyone noticing.

## Prefer enforcement over documentation

A boundary described in a document degrades on a schedule. A boundary enforced by a check holds.

When proposing a boundary, sequence it as:

1. **Add the mechanism first**, on a boundary that already mostly holds. One dependency, one check, running in CI. Low risk and it proves the tool before any argument starts.
2. **Pin one real boundary** as a proof of concept, ideally one you are already touching for other reasons.
3. **Then write the proposal** for the broader set, with the mechanism already in the repo doing something.

A proposal with a working check attached is a plan. A proposal alone is an opinion, and it loses to whoever is shipping features that week.

## The modular-in-name-only pattern

A common shape worth recognizing: a codebase with a domain directory structure, real intent behind it, and no enforcement. Half the code sits inside domains and half sits in a legacy namespace, one concern is split across three locations, and nothing prevents any module from reaching into any other.

The tell is that the structure is aspirational rather than actual. The fix is not a reorganization, which is expensive and reverts under pressure. The fix is a check that makes new violations impossible while the existing ones get paid down opportunistically.

## Cross-team decisions are influence work, not code work

If the decision needs agreement from teams that do not report to you, most of the cost is in the agreement rather than the implementation. Two implications:

- Ask who already owns the question before proposing anything. Landing on someone's toes with a finished document is a slow way to make an enemy of a natural ally.
- Bring the person with the most context in as a partner early rather than reviewing them late. Someone who is also trying to grow into this scope is a collaborator, not competition.
