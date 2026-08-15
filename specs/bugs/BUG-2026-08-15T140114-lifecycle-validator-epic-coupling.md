# BUG-2026-08-15T140114: Decouple completed e05 evidence from future epic state

## Problem

Starting the planned e06 epic requires a `build_epic` state and an in-progress
execution ledger. The lifecycle validator rejects that legitimate transition
because it requires the completed e05 cutover to retain a global `sustain`
flow, a completed handoff, and a global execution status of `verified`.

Reproduce with a temporary state copy that changes only the active flow to
e06's build flow while retaining the published v0.0.6 release fields and all
e05 verification records:

```sh
python3 tools/validate-lifecycle-state.py \
  /tmp/e06-transition-state.yaml specs/execution-status.yaml \
  specs/release-plan.yaml
```

Actual: validation rejects the state with `must hand off the completed cutover
to sustain mode`.

Expected: the durable v0.0.6/e05 facts validate while a later planned epic is
active.

Security impact: NONE — no security exploit path identified.

## Related history

This is a recurrence of BUG-2026-07-30T094453. That repair removed coupling to
the active story but retained coupling to the active epic's terminal snapshot.

## Root Cause Analysis

### Reproduce

A temporary e06 transition state retains the v0.0.6 release fields and e05
verification ledger entries but changes only the transient active-flow fields.
The validator rejects it.

### Isolate

The lifecycle validator and its Meson migration contract test assert the completed e05 snapshot's global `active_flow: sustain`, handoff
status, and global execution `status: verified` fields. Those fields must
change when a subsequent epic starts, unlike the durable e05 and release
facts.

### Hypothesize

1. **Residual terminal-snapshot coupling.** Falsification: remove only the two
global-state assertions and validate the e06 transition fixture.
2. **The v0.0.6/e05 evidence itself requires sustain mode.** Falsification:
keep every release and e05 assertion unchanged while validating the transition
fixture.

### Verify

The temporary transition fixture fails at the `active_flow: sustain` assertion
before any v0.0.6/e05 evidence is checked. The earlier active-story-coupling
repair confirms the intended validator shape: retain durable release and e05
facts, not a transient workflow position. The verified root cause is residual
terminal-snapshot coupling.

Risk level: Low. The correction removes three transient-state requirements
while keeping all v0.0.6 and e05 verification checks intact.

## TDD Fix Plan

1. **RED:** Add a lifecycle-validator fixture representing the e06 transition
while retaining the published v0.0.6 and verified e05 facts; demonstrate that
it currently fails.
   **GREEN:** Remove only the global sustain and global execution-status
requirements from the lifecycle validator and replace snapshot assertions with
the transition fixture.
   **verify:** `tests/test-meson-migration-contracts.sh "$PWD"`

2. **RED:** Use the real e06 start state after the contract change.
   **GREEN:** Make no further validator changes if the durable v0.0.6 and e05
negative checks remain enforced.
   **verify:** `tools/preflight.sh --strict`

**REFACTOR:** Keep lifecycle checks limited to durable release and completed
story facts.

## Acceptance Criteria

- [x] An e06 transition fixture validates with unchanged v0.0.6/e05 evidence.
- [x] Altered v0.0.6 or e05 verification facts still fail validation.
- [x] Starting e06 does not require rewriting completed e05 evidence.
- [x] The strict preflight passes.

## Resolution

Removed only the transient active-flow, handoff-status, and global
execution-status requirements. The durable v0.0.6 tag/publish and e05/e05s06
verification checks remain required. The new transition fixture advances the
flow and global execution state, while the existing negative fixture still
rejects an in-progress e05. The focused contract and strict preflight passed
with all 34 Meson tests.
