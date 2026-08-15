# BUG-2026-08-15T095835: Release-container tests are not portable

## Problem

The immutable `v0.0.4` draft-release workflow reached Meson source
distribution in both targets but failed its distribution test suite. Ubuntu
lacks PyYAML for an internal policy test and has no X display for GUI tests.
Linux Mint reports one reviewed Cppcheck 2.13 `readdirCalled` diagnostic that
is absent from the current baseline.

Reproduce with workflow run `31877965751`:

- Ubuntu fails file-browser, font, popup, and GTK3 tests because `meson dist`
  runs its test suite without Xvfb; it also fails the autonomous-policy test
  with `ModuleNotFoundError: No module named 'yaml'`.
- Linux Mint fails the same GUI test class and rejects
  `readdirCalled:xmms/pluginenum.c:428` in its Cppcheck 2.13 baseline.

**Security impact: NONE.** No security exploit path is identified. The changes
make existing local verification portable to declared release containers and
retain the narrow reviewed lint baseline.

## Root Cause Analysis

### Reproduce

Run `31877965751` failed after both package jobs configured Meson and began
source distribution tests. The failure logs identify the missing X display,
optional Python import, and line-specific Cppcheck diagnostic.

### Isolate

`tools/package-deb.sh` invokes `meson dist` directly although normal project
tests run under `xvfb-run`. The autonomous-policy shell test imports PyYAML
although it validates a small fixed repository recipe. The lint baseline
already contains narrow Cppcheck 2.13 `readdirCalled` suppressions for retained
legacy paths but not the reported plugin enumeration call.

### Hypothesize

1. Wrapping `meson dist` with Xvfb makes GUI distribution tests display-safe.
   **Falsification:** run target-container package distribution with that
   wrapper and require the wrapper in the package contract.
2. The autonomous-policy test needs no YAML library. **Falsification:** run it
   with Python site packages disabled; it must pass after using only POSIX/text
   assertions.
3. A narrow suppression for the exact reported path and line restores the
   reviewed Cppcheck 2.13 baseline. **Falsification:** run Cppcheck 2.13 in the
   Linux Mint target; no other diagnostic may be suppressed.

### Verify

The failed workflow verifies each proposed boundary: the GUI failures occur
only during unwrapped distribution testing, the Python error names PyYAML, and
Linux Mint prints the exact Cppcheck identifier/path/line. The root causes are
missing Xvfb inheritance, an unnecessary optional Python dependency, and a
missing narrow reviewed suppression.

**Risk level: High.** The changes are small but block both release targets.

## TDD Fix Plan

1. **RED:** Require package source distribution to use `xvfb-run` and require
   the helper to fail clearly when its Xvfb prerequisite is unavailable.
   **GREEN:** Wrap the Meson distribution command in `xvfb-run --auto-servernum`
   and add the prerequisite check.
   **verify:** `tests/test-package-recipes.sh "$PWD"`

2. **RED:** Disable Python site packages in the autonomous-policy contract;
   it must fail while the test imports PyYAML.
   **GREEN:** Replace the optional-library parser with POSIX fixed-text
   assertions over the checked-in policy recipe.
   **verify:** `tests/test-autonomous-epic-workflow.sh "$PWD"`

3. **RED:** Require a line-specific Cppcheck 2.13 suppression for the reported
   `pluginenum.c` `readdirCalled` diagnostic.
   **GREEN:** Add only that reviewed suppression.
   **verify:** `tests/test-c-lint.sh "$PWD" && tools/run-c-lint.sh`

**REFACTOR:** None expected. Do not change historical codec code or broaden
any lint suppression.

## Acceptance Criteria

- [ ] Package distribution tests inherit an Xvfb display in each release
      container.
- [ ] Package setup fails clearly if `xvfb-run` is unavailable.
- [ ] The autonomous-policy test does not import PyYAML and runs where it is absent.
- [ ] The Cppcheck baseline suppresses only the reported legacy diagnostic.
- [ ] Local strict preflight and target-container package tests pass.
- [ ] Immutable `v0.0.4` remains unchanged.
- [ ] A newly authorized patch-tag workflow succeeds on both targets and
      creates a draft release.

## Resolution

**Status:** fixed and release-accepted in `v0.0.6`.

The package helper runs Meson distribution under Xvfb, autonomous-policy
verification uses only POSIX text checks, and the Cppcheck baseline updates only
the externally reported plugin-enumeration line. Strict preflight passed 34/34.
Workflow `31886668793` then passed Linux Mint 22.3 and Ubuntu 26.04 package
jobs, assembled the draft release, and produced assets whose checksums were
verified before the explicitly authorized `v0.0.6` release was published.
Immutable `v0.0.4` and `v0.0.5` remain unchanged.
