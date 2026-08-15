# BUG-2026-08-14T123713: Release containers check out without Git

## Problem

The authorized `v0.0.2` tagged draft-release workflow failed for both Linux
package targets. The package helper requires a Meson source archive created
from a VCS checkout, but the target containers checked out the tag before they
installed Git. The resulting workspace could not create the required archive.

**Expected:** each container package job has Git available before source
checkout, so its checked-out tag remains a usable VCS source tree for Meson
distribution and Debian packaging.

**Security impact:** LOW. No exploit path was identified. The failure blocks
release delivery rather than widening credential, artifact, or runtime access.

## Root Cause Analysis

### Reproduce

Dispatch the tagged manual package-release workflow for `v0.0.2`. Run
`31801007532` failed in both target package jobs: one package helper invocation
reported that an extracted source needs `DEB_SOURCE_ARCHIVE`; the other Meson
distribution invocation reported that it requires a Git or Mercurial repository.

### Isolate

The container-job workflow checks out its selected ref before it installs package
build dependencies. Git is among neither the pre-checkout environment guarantees
nor the early job steps. The package helper correctly uses Meson distribution
only when the workspace is a VCS checkout; it otherwise requires a supplied
source archive.

### Hypothesize

1. **Confirmed:** Git must be installed before `actions/checkout` in container
   jobs. The run's two failures are the two observable outcomes of a workspace
   that lacks usable VCS source state.
2. **Rejected:** installing Git in the existing later dependency step can repair
   checkout. It runs after checkout has already selected its fallback behavior.
3. **Rejected:** bypassing Meson distribution is appropriate. It would violate
   the no-download, one-verified-source-archive release contract.

### Verify

The workflow order places checkout before dependency installation, and the
failed target logs show both the absent-source-archive and no-VCS Meson errors.
Moving the existing dependency installation ahead of checkout and including Git
removes the only unfulfilled precondition while retaining the package helper's
contract.

## TDD Fix Plan

1. **RED:** Extend the package-workflow contract to require Git in the target
   dependency installation and require that installation to occur before the
   target checkout.
   **GREEN:** Reorder the target container steps and install Git with the
   package dependencies.
   **verify:** `tests/test-package-recipes.sh "$PWD"`

2. **RED:** Add a project-policy contract that requires autonomous epic
   progression and explicit terminal stop conditions.
   **GREEN:** Add the autonomous workflow recipe and project-local agent rule.
   **verify:** `meson test -C build-meson autonomous-epic-workflow`

3. **GREEN:** Update release metadata to `0.0.3` only after the local workflow
   contract and full preflight are green.
   **verify:** `tools/check-release-version.sh 0.0.3`

## Acceptance Criteria

- [ ] The target container installs Git before source checkout.
- [ ] The static release-workflow contract rejects a reversed step order or
      missing Git dependency.
- [ ] Agents advance through approved epic stories without routine checkpoints.
- [ ] Agents stop only for a declared blocked or exhausted terminal state.
- [ ] `tools/preflight.sh --strict` passes.
- [ ] `v0.0.3` draft-release workflow succeeds on both package targets.

## Resolution

**Status:** fixed

The workflow installs Git with the target dependencies before it checks out the
selected tag. Immutable `v0.0.3` run `31870919715` reached Meson in both target
containers, proving this prerequisite is restored. That run exposed a separate
checkout-ownership trust failure, tracked by
`BUG-2026-08-15T073425-release-container-workspace-trust.md`.
