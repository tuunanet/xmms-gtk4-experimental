# e05s01: Capture release baseline and Meson migration contracts

**type:** docs
**risk:** P1
**context:** build and delivery infrastructure

## Context

The repository state still describes e04 as awaiting a release dispatch even
though the tagged package run succeeded and created a draft pre-release. Before
changing the build system, preserve that factual release state and freeze the
observable build/delivery contracts that Meson must reproduce.

## Requirements

#### ADDED: Meson migration baseline

The project records a machine-checkable inventory of feature options, outputs,
install paths, test inventory, Debian contents, source-distribution inputs, and
release inputs before legacy build definitions change.

#### MODIFIED: Lifecycle state

**Before:** e04 lifecycle state says post-merge tag dispatch is pending.
**After:** It records the successful `v0.0.1` tagged package run and draft
pre-release without representing the draft as published.

## Steps

1. Record e04 delivery evidence and reconcile active lifecycle YAMLs → verify: `python3 tools/validate-lifecycle-state.py specs/state.yaml specs/execution-status.yaml specs/release-plan.yaml`
2. Add ADR and baseline inventory from current legacy outputs → verify: `tools/verify-build-baseline.sh`
3. Define the system-only Meson/Ninja policy and version floor → verify: `tools/verify-meson-toolchain-policy.sh`

## Test traceability

- SC-e05s01-P1-01

## Acceptance criteria

- Given the repository state, when lifecycle validation runs, then e04 is no
  longer reported as awaiting a completed dispatch.
- Given the baseline inventory, when a later story validates Meson, then every
  declared output and delivery contract has an observable comparison target.

## Out of scope

No Meson build file or legacy build artifact changes occur in this story.
