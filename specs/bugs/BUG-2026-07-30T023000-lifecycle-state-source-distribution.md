# BUG-2026-07-30T023000: Source distribution omits lifecycle test inputs

## Problem

`xvfb-run --auto-servernum make distcheck` fails after e05s01 adds the lifecycle
contract test. The test is present in the extracted distribution tree, but its
three lifecycle YAML inputs are absent, so the validator cannot open them.

**Expected:** source-distributed tests include all files required to validate
the contracts they run.

**Security impact:** NONE. No exploit path was identified; this is a fail-closed
release-quality gate failure.

## Root cause analysis

### Reproduce

Run `xvfb-run --auto-servernum make distcheck`. The extracted build invokes
`test-meson-migration-contracts.sh`, which raises `FileNotFoundError` for the
missing lifecycle state file.

### Isolate

The working tree test passes. The source-distribution manifest includes the new
test and validators but not `state.yaml`, `execution-status.yaml`, or
`release-plan.yaml`.

### Hypothesize and verify

The missing source-distribution manifest entries are the single root cause:
adding those inputs to the archive makes the test see the same release contract
as the working tree. No validator or YAML-content defect is involved.

## TDD fix plan

1. **RED:** The failed distcheck provides a reproducible archive-level test:
   the lifecycle contract cannot read its required inputs.
   **GREEN:** Add all three inputs to authoritative and shipped distribution
   manifests.
   **verify:** `xvfb-run --auto-servernum make distcheck`

## Acceptance criteria

- [ ] Source archives include every lifecycle YAML read by the test.
- [ ] The lifecycle test passes from the extracted distribution tree.
- [ ] Full distcheck passes without generated artifacts in Git.

## Resolution

Added the lifecycle YAML inputs to both source-distribution manifests. The
working-tree contract and full Xvfb-backed `make distcheck` pass.
