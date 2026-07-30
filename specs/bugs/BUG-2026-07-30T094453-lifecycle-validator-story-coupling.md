# BUG-2026-07-30T094453: Decouple release evidence from active story

## Problem

After lifecycle state advances from e05s01 to e05s02, `make check` fails even
though the completed release evidence remains valid. The lifecycle validator
should verify durable e04 release facts without requiring the workflow to stay
on the story that first recorded them.

Reproduce with:

```sh
python3 tools/validate-lifecycle-state.py \
  specs/state.yaml specs/execution-status.yaml specs/release-plan.yaml
```

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

The validator rejects current state solely because the active story is e05s02.
All asserted tag, draft-pre-release, e04 epic, and e04 story facts still match.

### Isolate

The failure is one assertion in the release-evidence validator. It couples an
immutable completed-release contract to the transient active-story pointer.

### Hypothesize

1. **Accidental workflow coupling.** Falsification: validate an e05s02 state
   fixture with unchanged release evidence while omitting only the active-story
   assertion.
2. **e04 evidence became stale when e05s02 started.** Falsification: compare all
   release fields and e04 statuses before and after the story transition.

### Verify

The release fields and e04 statuses are unchanged; only the active story moved
forward. The validator succeeds when the unrelated active-story assertion is
removed and continues to reject altered release evidence. The verified root
cause is accidental coupling to workflow position.

Risk level: Low. The correction narrows validation to its documented durable
release contract.

## TDD Fix Plan

1. **RED**: Validate a temporary state fixture whose active story has advanced
   to e05s02 while all completed-release facts remain unchanged.
   **GREEN**: Remove the active-story requirement from release-evidence
   validation while retaining the active e05 epic and every e04 release check.
   **verify**: `tests/test-meson-migration-contracts.sh "$PWD"`

2. **RED**: Run the full legacy regression suite with the real e05s02 state.
   **GREEN**: Make no further lifecycle changes unless another independent
   contract failure appears.
   **verify**: `xvfb-run --auto-servernum make check`

## Acceptance Criteria

- [ ] e05s02 state passes completed-release validation.
- [ ] Missing or altered v0.0.1 draft-pre-release evidence still fails.
- [ ] e04 epic/story verification remains required.
- [ ] Full Xvfb-backed tests pass.

## Resolution

<!-- filled in by validate-fix -->
