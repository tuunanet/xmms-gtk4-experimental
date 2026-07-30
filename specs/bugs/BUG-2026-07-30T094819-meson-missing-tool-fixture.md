# BUG-2026-07-30T094819: Isolate the missing-Meson test fixture

## Problem

The Meson policy contract fails after contributors install the required system
Meson package because its negative fixture uses `/usr/bin` and assumes Meson is
absent there. The test should simulate a missing tool independently of the host
machine while still verifying the actionable failure path.

Reproduce with:

```sh
tests/test-meson-migration-contracts.sh "$PWD"
```

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

With system Meson installed, the negative invocation succeeds and the test
reports that the verifier did not fail fast.

### Isolate

The policy verifier behaves correctly. The test fixture supplies the host's
normal executable directories, so it is not isolated from installed tools.

### Hypothesize

1. **Non-hermetic PATH fixture.** Falsification: run the verifier with a PATH
   containing only its shell-runtime prerequisites and no Meson/Ninja.
2. **Verifier no longer rejects missing Meson.** Falsification: inspect the
   diagnostic and exit status under the isolated PATH.

### Verify

Under a prerequisite-only PATH, the verifier exits nonzero and prints the
expected system-package guidance. The verified root cause is a host-dependent
negative test fixture, not production policy behavior.

Risk level: Low. Only test isolation changes.

## TDD Fix Plan

1. **RED**: Run the policy contract on a host where Meson is installed and
   observe that the missing-tool fixture does not simulate absence.
   **GREEN**: Build a temporary PATH containing only required helper commands,
   then run the missing-Meson assertion through it.
   **verify**: `tests/test-meson-migration-contracts.sh "$PWD"`

## Acceptance Criteria

- [ ] The negative fixture passes whether or not host Meson is installed.
- [ ] The real system-tool positive check still passes.
- [ ] Missing Meson still produces actionable package guidance.
- [ ] Full Xvfb-backed tests pass.

## Resolution

<!-- filled in by validate-fix -->
