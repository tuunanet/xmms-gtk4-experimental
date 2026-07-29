# BUG-2026-07-29T080737: GCC 15 default contributor build fails

## Problem

A fresh checkout configured with the documented `./configure --disable-esd` command fails during `make -j"$(nproc)"` under GCC 15.2. GTK2 callback connections in optional plugins are rejected as incompatible function-pointer arguments.

Expected behavior: the documented configure and build commands complete on the supported modern Linux development environment without requiring an undocumented compiler flag.

Reproduction:

```sh
./configure --disable-esd
make -j"$(nproc)"
```

Observed representative failure: GTK2's legacy signal macro passes a typed callback where modern GLib declares `GCallback`; GCC treats `-Wincompatible-pointer-types` as an error.

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

This is a novel build-compatibility defect, not a recurrence in the bug registry.

### Reproduce

A clean worktree configured without an explicit `CFLAGS` value generated the normal warning flags and failed while compiling GTK2 callback registrations.

### Isolate

The same checkout builds and passes tests when configured with:

```sh
CFLAGS='-Wno-error=incompatible-pointer-types' ./configure --disable-esd
```

The Debian package recipe already appends both `-Wno-error` and `-Wno-error=incompatible-pointer-types`, while the normal contributor configure path does not.

### Hypothesis

Modern GCC promotes the legacy GTK2 callback pointer mismatch to an error. The source continues to use the historical GTK2 callback ABI correctly, but the default configure flags do not apply the compatibility demotion already used by packaging.

### Verify

The default build failed repeatedly at GTK2 signal registrations. Reconfiguring the same worktree with the narrow compatibility flag completed the build, `make check`, and `make distcheck`.

Verified root cause: the default contributor build lacks the compiler compatibility flag already present in Debian packaging.

Risk level: Medium — the fix touches compiler detection and shipped generated configure output but should not alter runtime behavior.

## TDD Fix Plan

1. **RED**: Add a shell contract test proving the generated contributor build flags include a supported narrow compatibility demotion when the compiler treats GTK2 callback pointer mismatches as errors.
   **GREEN**: Add a configure-time compiler-option probe and append the flag only when accepted.
   **verify**: `tests/test-package-recipes.sh "$PWD"`

2. **RED**: Demonstrate that a fresh documented configure/build succeeds under GCC 15 without caller-supplied `CFLAGS`.
   **GREEN**: Synchronize the authoritative configure input and shipped generated configure output.
   **verify**: `./configure --disable-esd && make -j"$(nproc)"`

3. **RED**: Prove source-distribution builds retain the same compatibility behavior.
   **GREEN**: Ensure the generated configure behavior survives the source archive boundary.
   **verify**: `xvfb-run --auto-servernum make distcheck`

**REFACTOR**: Keep the compatibility probe localized to compiler flag selection; do not cast or rewrite historical GTK2 callbacks across plugins.

## Acceptance Criteria

- [ ] The documented configure/build commands pass under GCC 15 without caller-supplied compatibility flags.
- [ ] Older supported compilers reject or ignore no unsupported option through the configure probe.
- [ ] Debian packaging retains equivalent compatibility behavior.
- [ ] The full Xvfb-backed test suite passes.
- [ ] Source-distribution verification passes.

## Resolution

<!-- filled in by validate-fix -->
