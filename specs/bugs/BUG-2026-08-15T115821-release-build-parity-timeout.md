# BUG-2026-08-15T115821: Release build-parity test exceeds its timeout

## Problem

The immutable `v0.0.5` Linux Mint package job failed while the same release
source passed locally and during Meson source-distribution verification. The
full package build runs the build-parity contract a second time; it received a
SIGTERM at 30.03 seconds, preventing the draft release from being created.

Reproduce from workflow run `31882860071` on Linux Mint 22.3. The
source-distribution invocation completes the contract in 26.27 seconds, while
the Debian package invocation times out at the default 30-second limit.

**Security impact: NONE.** No security exploit path is identified. The failure
is a bounded test-runner configuration error in release packaging.

## Root Cause Analysis

### Reproduce

The failed tagged package workflow runs the complete Meson suite after its
Debian build configuration. Its build-parity contract is terminated at the
runner's 30-second default limit. A preceding source-distribution invocation
of the same contract completes in 26.27 seconds, establishing that the test
is valid but has insufficient time budget in the slower package context.

### Isolate

The contract intentionally configures and compiles the full project in an
isolated temporary build directory before checking the frozen output inventory.
It has no explicit test timeout, unlike another long-running static-analysis
contract. The runner therefore applies its default 30-second limit.

### Hypothesize

1. An explicit, bounded timeout that accommodates the full isolated build will
   allow the test to complete in both declared package targets.
   **Falsification:** configure the suite and verify the contract's timeout is
   explicitly 120 seconds, then run the full package gate.
2. The timeout may conceal a functional build failure.
   **Falsification:** the contract must still complete its output verification
   and reject a deliberately removed required player artifact.

### Verify

Workflow `31882860071` provides the falsification result for the second
hypothesis: the same contract completes successfully during source distribution
and before the package build's constrained second invocation. The failure is
exactly a 30.03-second timeout, not an output-inventory failure. The missing
explicit timeout is the verified root cause.

**Risk level: Medium.** The change affects test execution only, but the
release package workflow cannot complete without it.

## TDD Fix Plan

1. **RED:** Extend the Meson test-suite contract to require the isolated
   build-parity test to declare an explicit 120-second timeout.
   **GREEN:** Give that test the bounded 120-second timeout in its Meson
   registration.
   **verify:** `meson setup build-meson --wrap-mode=nodownload && meson test -C build-meson --no-rebuild meson-test-suite-contract build-parity-contract`

2. **RED:** Run the package gate in the declared Linux Mint target and require
   the build-parity contract to finish rather than receive a runner timeout.
   **GREEN:** No additional implementation change is expected when the bounded
   registration is present.
   **verify:** `tools/package-deb.sh && tools/verify-release-artifacts.sh deb-artifacts`

**REFACTOR:** None expected. Keep the full isolated parity build and its
negative artifact check; only correct its bounded runner budget.

## Acceptance Criteria

- [ ] The build-parity contract has an explicit 120-second Meson timeout.
- [ ] The test-suite contract rejects removal or reduction of that timeout.
- [ ] The contract still verifies the frozen output inventory and negative case.
- [ ] Strict preflight passes.
- [ ] Both declared package targets complete the tagged `v0.0.6` workflow.
- [ ] The immutable `v0.0.5` tag and failed workflow remain unchanged.

## Resolution

**Status:** local and declared-container verification passed; tagged `v0.0.6`
acceptance pending.

The contract now has an explicit 120-second budget, and the test-suite
contract rejects its removal. Strict preflight passed with all 34 tests. Clean
branch clones also passed the full Debian package and extracted-artifact
verification in the pinned Linux Mint 22.3 and Ubuntu 26.04 images; their two
build-parity invocations completed within the new bound. The immutable
`v0.0.5` tag and failed workflow remain unchanged.
