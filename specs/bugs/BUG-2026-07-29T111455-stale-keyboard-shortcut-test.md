---
bug_id: BUG-2026-07-29T111455
status: open
severity: high
scope: build-and-test
title: Remove stale keyboard shortcut test wiring
---

# BUG-2026-07-29T111455: Remove stale keyboard shortcut test wiring

## Problem

`make check` fails before running the regression suite because the test orchestrator requires a keyboard-shortcut source file that is intentionally absent. The supported baseline should build and execute all remaining checked-in tests.

Reproduce with:

```sh
xvfb-run --auto-servernum make check
```

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

The Xvfb-backed check reaches the top-level test orchestrator and stops with “No rule to make target … test-keyboard-shortcuts.c”.

### Isolate

The failure is isolated to stale declarations in the test orchestrator and source-distribution manifests. No runtime source or public interface is involved.

### Hypothesize

1. A missing generated test source causes the failure. Falsification: inspect tracked files and generation rules; no generator exists.
2. Stale wiring survived removal of the source. Falsification: remove the target from a temporary Makefile copy and run the remaining suite.

### Verify

Repository inventory confirms the source is untracked and intentionally discarded, no generation rule exists, and the orchestrator still names its target and executable. The verified root cause is stale build/test metadata referring to a removed test.

Risk level: Low.

## TDD Fix Plan

1. **RED**: Run the test orchestrator and observe that it requires the absent keyboard-shortcut source.
   **GREEN**: Remove the stale target, invocation, clean entry, and distribution entries from authoritative and shipped build metadata.
   **verify**: `! rg -n 'test-keyboard-shortcuts' Makefile.am Makefile.in tests/Makefile && xvfb-run --auto-servernum make check`

**REFACTOR**: None; retain all other test targets unchanged.

## Acceptance Criteria

- [ ] No build or test manifest references the removed keyboard-shortcut test.
- [ ] The remaining Xvfb-backed test suite passes.
- [ ] Source-distribution metadata remains internally consistent.

## Resolution

Removed the stale target, invocation, cleanup, and distribution references; made the authoritative test orchestrator trackable despite the general generated-Makefile ignore rule. The remaining Xvfb-backed suite passes.
