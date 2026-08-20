---
name: pr-splitter
description: Interview-driven breakdown of an oversized branch or PR into a stack of small reviewable PRs using gh-stack. Scans the diff, commits, and linked ticket, proposes dependency-ordered layers and dark-launch flags, interviews the developer until the plan is approved, then builds the stack, generates PR descriptions, and opens draft PRs. Use when a PR or branch is too large to review, or when asked to split, chunk, stack, or break down a PR or branch.
---

# PR Splitter

Turn one oversized branch into a stack of small, dependency-ordered, independently reviewable PRs. You are the arbiter of where the seams go, but the developer always has the final word: **never create a branch, commit, or PR before the developer explicitly approves the stack plan.**

Read the `gh-stack` skill before running any `gh stack` command and follow its non-interactive rules exactly (`--json`, `--auto`, always pass branch names). Splitting is file-level: every changed file is assigned to exactly one layer. Hunk-level splitting is out of scope; mixed files are resolved in the interview.

## Phase 0: Preflight

Stop and tell the developer if any of these fail:

1. On the oversized feature branch, not the default branch. Working tree clean (ask them to commit or stash first; never stash for them).
2. `gh extension list | grep -q stack` shows gh-stack installed; `git config rerere.enabled true` and `git config remote.pushDefault origin` are set (set them if not).
3. Fetching the default branch succeeds.

Then gather context:

```bash
TRUNK=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
git fetch origin $TRUNK
ORIGINAL=$(git branch --show-current)
MB=$(git merge-base origin/$TRUNK $ORIGINAL)
git diff --stat $MB..$ORIGINAL | tail -1
gh pr view --json number,title,body,url 2>/dev/null   # existing PR, if any
```

There may or may not be an existing PR: the developer might be splitting a monster PR that is already up, or splitting their feature branch into a stack before ever opening one. Both are first-class paths. If no PR exists, skip every PR-specific step below without comment; the branch's diff, commits, and ticket carry the analysis.

- **Ticket**: parse an issue tracker reference from the branch name, commit messages, or PR body (Linear or Jira slugs like `ABC-123`, GitHub issue numbers). If found and tooling for that tracker is available, fetch the issue for scope context. If no ticket is found, ask the developer whether one exists rather than guessing.
- **Size check**: if the diff is under ~400 lines or ~10 files, say that splitting is probably not worth the overhead and confirm they still want to proceed.

## Phase 1: Seam Analysis

If a `stack-seam-analyst` agent is available, launch it with: the base ref (`origin/<trunk>`), the branch name, the ticket summary, the existing PR title/body, and anything the developer has said about intent. It returns a proposed stack, mixed files, dark-launch candidates, and open questions. If no such agent is available, perform the same analysis inline: cluster the changed files into 2-6 dependency-ordered layers using the diff, the commit history, and repository area boundaries, flag files that mix concerns, and note anything user-visible that would ship before its dependents merge.

Sanity-check the analysis before presenting it: the layer file lists must partition the full changed-file set (no file missing, none in two layers). If the partition is broken, fix the assignment and note the correction.

## Phase 2: Interview

This is the heart of the skill. Present the proposed stack bottom-to-top with per-layer file lists, approximate line counts, and rationale. Then interview the developer one topic at a time, offering your recommendation with each question:

1. **Layer boundaries**: does each seam land where they would draw it? Offer merges and splits of layers as options.
2. **Mixed files**: for each one, which layer does it belong to, or do they want to manually split it first?
3. **Dark-launch flags**: for each candidate, gate it, reorder it, or ship it dark as-is? If gating, confirm the flag name and where the check goes, using the project's existing feature flag system.
4. **Branch names**: confirm or rename the suggested names (kebab-case, used verbatim by gh-stack).
5. **The original PR** (only if one exists): keep it open for reference, convert to draft, or close it after the stack is up? Never close it without being told. If there is no PR, skip this question entirely; do not offer to open one on the original branch.

Iterate until the developer explicitly approves the final plan. Restate the approved plan in full (layers, files, flags, branch names) before touching anything.

## Phase 3: Build the Stack

Update trunk first so the stack roots on the current default branch, then build bottom-up:

```bash
git checkout $TRUNK && git pull --ff-only && git checkout $ORIGINAL

gh stack init --base $TRUNK <layer-1>
git diff --binary $MB..$ORIGINAL -- <layer-1 paths> | git apply --index
git commit -m "<conventional message for layer 1>"

gh stack add <layer-2>
git diff --binary $MB..$ORIGINAL -- <layer-2 paths> | git apply --index
git commit -m "..."
# ...repeat for each layer
```

Rules:

- Commit messages follow the repository's existing conventions; check `git log` for the local style (conventional commits, ticket prefixes) and match it.
- Approved feature-flag gating is **new code**: write it as a separate commit on the layer that exposes the surface, so it is visible in that layer's PR.
- **Never touch the original branch.** No deletes, no force-pushes, no resets. It is the developer's safety net and the verification baseline.

**Verify before pushing anything:**

```bash
git diff $ORIGINAL HEAD   # from the top of the stack
```

This must be empty, or show only the approved flag-gating additions. Any other difference means the split lost or mangled changes: stop, report exactly what differs, and fix it before Phase 4. Also spot-check one or two layers with `git diff <parent-branch>..<layer>` to confirm each PR's diff is just its own concern.

## Phase 4: Submit and Describe

1. `gh stack submit --auto` (creates draft PRs, bottom to top).
2. `gh stack view --json` to collect PR numbers and URLs.
3. For each branch, bottom to top: check it out and write a proper PR body (use a `pr-description` skill if one is available, otherwise summarize the layer's diff following the repository's PR template if it has one), then apply it with `gh pr edit <number> --body-file -`. Fix titles with `gh pr edit <number> --title` to match the repo's conventions. Link the ticket, and add a one-line stack position note at the top of each body ("Part N of M in a stack; based on #X").
4. Cross-link (only if an original PR exists): comment on it with the stack's PR list, then do whatever the developer chose for it in the interview. With no original PR there is nothing to cross-link; the stack itself is the source of truth.
5. Report the finished stack: ordered list of PR URLs with titles and line counts, and remind the developer that `gh stack sync` keeps the stack rebased as PRs merge.

## Failure Modes

- **`git apply` fails on a layer**: usually a path assigned to the wrong layer (depends on an unapplied change) or a rename split across layers. Reassign in consultation with the developer; do not hand-edit the patch.
- **`gh stack submit` exits 9**: stacked PRs are not enabled on the repository. Stop and tell the developer; do not fall back to manual PR chaining without asking.
- **Anything goes wrong mid-build**: the original branch is untouched, so recovery is always `gh stack unstack`, delete the layer branches, and start Phase 3 over.
