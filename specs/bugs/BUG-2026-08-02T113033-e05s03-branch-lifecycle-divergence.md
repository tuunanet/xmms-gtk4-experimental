# BUG-2026-08-02T113033: Reconcile duplicated e05s03 branch history

**type:** fix
**risk:** P1
**context:** Git lifecycle and worktree management

## Problem

The e05s03 lifecycle state names `feat/meson-parity-distribution` as the
active delivery branch even though the same Meson parity implementation is
already present on `main`. The branch is not an ancestor of `main`, so the
solo-local landing gate correctly rejects it. Keeping the stale worktree and
lifecycle pointer risks duplicate work and makes the next story unsafe to
start.

Reproduce with:

```sh
git merge-base --is-ancestor feat/meson-parity-distribution main
git diff --quiet main feat/meson-parity-distribution -- \
  meson.build meson_options.txt tools/verify-meson-dist.sh \
  tests/verify-meson-install-layout.sh
```

Security impact: NONE — no security exploit path was identified. The landing
script fails closed when the branch is not based on current `main`.

## Root Cause Analysis

### Reproduce

The branch is checked out in its own clean worktree and is behind the current
remote default branch. It cannot satisfy the ancestry condition required for a
solo-local landing. The lifecycle cockpit still points at an older branch
commit rather than the current default branch.

### Isolate

The parity source, distribution verifier, install verifier, story definition,
and audit artifact have matching contents in both histories. The default branch
also contains the newer workflow-contract test that the stale branch lacks.

### Hypothesize

1. **The branch contains unique e05s03 work.** Falsification: compare every
   parity implementation artifact and stable patch identity with the default
   branch.
2. **The default branch contains the parity work independently.**
   Falsification: run the complete Meson suite and clean distribution verifier
   from the default branch after confirming matching patch identities.
3. **The stale branch can be landed safely.** Falsification: evaluate its
   default-branch ancestry using the solo-local landing precondition.

### Verify

All non-empty parity implementation patches have matching stable identities in
both histories, while the branch fails the default-branch ancestry check.
The current default branch passes the full 26-test Meson suite and clean
source-distribution build, test, and staged-install verification. The verified
root cause is duplicated commit history with different parents, combined with
unreconciled lifecycle metadata after the equivalent implementation arrived on
`main`.

Risk level: Medium. The defect does not affect runtime behavior, but it can
block delivery or cause redundant work if the stale branch is retained.

## TDD Fix Plan

1. **RED**: Demonstrate that the recorded branch cannot meet the solo-local
   ancestry precondition while the current default branch contains the parity
   artifacts.
   **GREEN**: Record the reconciliation decision, mark the completed story
   verified, and point lifecycle handoff at the planned successor story.
   **verify**: `git merge-base --is-ancestor feat/meson-parity-distribution main; test $? -ne 0 && xvfb-run --auto-servernum meson test -C /tmp/xmms-e05s03-main-build --print-errorlogs`

2. **RED**: Confirm that no required e05s03 artifact is lost when the stale
   checkout is removed.
   **GREEN**: Remove the clean obsolete worktree and its local branch only
   after the reconciliation metadata has landed on the default branch.
   **verify**: `git worktree list | grep -q 'meson-parity-distribution' && exit 1 || test -z "$(git branch --list feat/meson-parity-distribution)"`

**REFACTOR**: None. Preserve the existing verified Meson code and only correct
lifecycle records and obsolete Git state.

## Acceptance Criteria

- [ ] e05s03 is recorded as verified on the default branch.
- [ ] Lifecycle handoff identifies e05s04 and requires a new isolated branch.
- [ ] The current default branch passes the Meson suite and clean distribution verifier.
- [ ] The obsolete clean e05s03 worktree and local branch are removed only after metadata lands.
- [ ] The remote branch remains untouched unless separately approved.

## Resolution

Verified that current `main` contains the complete e05s03 patch series and
passes its full Meson and clean-distribution gates. The lifecycle cockpit now
marks e05s03 verified, assigns the planned e05s04 successor, and requires a
new isolated branch. The obsolete clean local e05s03 worktree and branch are
removed after this metadata is landed; the remote branch is intentionally left
unchanged.
