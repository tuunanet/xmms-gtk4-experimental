# BUG-2026-08-15T073425: Release containers do not trust their checkout

## Problem

The authorized `v0.0.3` draft-release workflow reached Meson in both target
containers but failed to create its source archive. Git rejected the checked-
out repository because the container process and checkout directory have
different owners. Meson then reported that distribution works only from a Git
or Mercurial repository.

Reproduce by dispatching the manual release workflow for `v0.0.3`; both package
targets in run `31870919715` fail before artifacts are created. A local
container reproduction with a repository owned by UID 0 and Git run as UID
1000 reproduces Git's "detected dubious ownership" failure. Adding only that
repository path to Git's safe-directory configuration restores repository
access.

**Security impact: LOW.** No security exploit path is identified: the trusted
path is the runner-provided workspace containing a tag already validated
against `main`. A wildcard trust setting would be an unnecessary weakening and
is out of scope.

## Root Cause Analysis

### Reproduce

The `v0.0.3` workflow run installs Git before checkout, then Meson invokes the
release package helper in each target container. Both package jobs fail at
Meson source distribution; Ubuntu additionally reports that Git rejected the
repository as dubiously owned.

### Isolate

The failure occurs after checkout and before package assembly, at the boundary
where Meson asks Git for source metadata. Package helper behavior, source
contents, tag validation, and Meson no-download configuration are unchanged.

### Hypothesize

1. Git's ownership safety check rejects the mounted checkout. **Falsification:**
   run Git as a non-owner against a mounted fixture repository, then add only
   that path to `safe.directory` and retry.
2. Git was still absent. **Falsification:** the release logs show Meson reaches
   Git detection after the `v0.0.3` dependency installation repair.
3. The checkout lacks repository metadata. **Falsification:** Git identifies a
   repository but rejects it for ownership, and scoped trust restores access in
   the fixture reproduction.

### Verify

The fixture reproduction confirmed hypothesis 1 and rejected hypotheses 2 and
3: untrusted Git access fails with the ownership diagnostic; adding the exact
workspace path succeeds. The root cause is missing scoped workspace trust in
the target-container workflow.

**Risk level: High.** The release path is blocked for every supported container,
but the implementation is a single scoped configuration command.

## TDD Fix Plan

1. **RED:** Extend the package-workflow contract to require an exact
   `${GITHUB_WORKSPACE}` safe-directory command, reject the wildcard setting,
   and require the trust step after checkout and before package construction.
   **GREEN:** Add the scoped trust step and a repository-access assertion to the
   target-container workflow.
   **verify:** `tests/test-package-recipes.sh "$PWD"`

2. **RED:** Update the release lifecycle contract to describe the failed
   immutable `v0.0.3` dispatch and active `v0.0.4` repair.
   **GREEN:** Update version, changelog, lifecycle records, story acceptance,
   and build documentation to name `v0.0.4` as the new tagged acceptance.
   **verify:** `tools/check-release-version.sh 0.0.4 && python3 tools/validate-lifecycle-state.py specs/state.yaml specs/execution-status.yaml specs/release-plan.yaml`

**REFACTOR:** None expected; retain the workflow's existing structure and
least-privilege permissions.

## Acceptance Criteria

- [ ] Each target container trusts only `${GITHUB_WORKSPACE}` after checkout.
- [ ] The workflow rejects a wildcard Git safe-directory configuration.
- [ ] The trust setup completes before `tools/package-deb.sh` runs.
- [ ] `v0.0.3` remains immutable and is recorded as a failed draft workflow.
- [ ] Release metadata and lifecycle records target `0.0.4` consistently.
- [ ] `tools/preflight.sh --strict` passes.
- [ ] The `v0.0.4` draft-release workflow succeeds on both package targets and
      creates a draft release.

## Resolution

**Status:** local repair verified; tagged acceptance pending

The workflow now trusts only `${GITHUB_WORKSPACE}` after checkout and proves Git
can read it before Meson creates the source archive. The static contract rejects
Git's wildcard setting and protects the required order. A local ownership
fixture reproduced the failure and passed after the scoped setting; the full
local P0 terminal command passed. Immutable `v0.0.3` remains unchanged;
`v0.0.4` awaits tagged draft-release acceptance before this defect is closed.
