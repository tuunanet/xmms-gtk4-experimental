---
bug_id: BUG-2026-07-29T160826
status: open
severity: high
scope: input-vorbis-build
title: Restore GCC 15 build compatibility for Vorbis GTK callbacks
---

# BUG-2026-07-29T160826: Restore GCC 15 build compatibility for Vorbis GTK callbacks

## Problem

A clean GCC 15 build fails in the Vorbis input plugin because three GTK2 signal handlers are passed without the callback-boundary cast used by neighboring registrations.

Reproduce with:

```sh
./configure --disable-esd && make -j"$(nproc)"
```

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

GCC 15 reports incompatible pointer types as errors at two configuration-window signal registrations and one file-info key-event registration.

### Isolate

The failures are limited to three `gtk_signal_connect` call sites. Other callbacks in the same modules compile because they use GTK2's established `GTK_SIGNAL_FUNC` boundary conversion.

### Hypothesize

1. Callback implementations have incorrect runtime signatures. Falsification: compare each handler's parameters with its GTK signal contract; they match the expected event arguments.
2. The registrations omit the compatibility cast required by the legacy GTK signal API. Falsification: compile after applying the same boundary conversion used by adjacent registrations.

### Verify

Compiler diagnostics point directly to the unconverted third argument, and neighboring equivalent registrations use `GTK_SIGNAL_FUNC`. The verified root cause is omission of that boundary conversion at three call sites.

Risk level: Low. The callback implementations and runtime behavior remain unchanged.

## TDD Fix Plan

1. **RED**: Cleanly configure and build with GCC 15, observing incompatible-pointer errors at the three registrations.
   **GREEN**: Wrap each handler argument with the established `GTK_SIGNAL_FUNC` conversion.
   **verify**: `make -C Input/vorbis clean all`

2. **RED**: Exercise the full clean build and regression suite.
   **GREEN**: Make no further source changes unless another reproducible callback-boundary error appears.
   **verify**: `make -j"$(nproc)" && xvfb-run --auto-servernum make check`

## Acceptance Criteria

- [ ] The Vorbis plugin builds with GCC 15.
- [ ] Only signal registration boundary conversions change.
- [ ] The complete build and Xvfb-backed regression suite pass.

## Resolution

Applied the established GTK signal callback boundary conversion at the three failing registrations. The focused Vorbis build, full GCC 15 build, and Xvfb-backed regression suite pass.
