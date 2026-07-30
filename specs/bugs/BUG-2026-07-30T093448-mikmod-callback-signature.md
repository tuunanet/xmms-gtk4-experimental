# BUG-2026-07-30T093448: Restore modern libmikmod callback compatibility

## Problem

When Meson enables the installed MikMod input plugin, GCC 15 rejects the XMMS
output-driver callback table because one callback has an incompatible function
pointer type. The supported plugin should compile and export its established
XMMS input-plugin entry point when system libmikmod is available.

Reproduce with:

```sh
rm -rf build-meson
meson setup build-meson --wrap-mode=nodownload -Dmikmod=enabled
meson compile -C build-meson
```

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

The Meson build finds system libmikmod 3.3.13 and compiles the MikMod module.
GCC 15 stops at the output-driver callback table because the command-line
callback receives a mutable string pointer while the installed library contract
requires a pointer to const data.

The legacy configure probe reports libmikmod unavailable and therefore does not
compile this module, which hid the source incompatibility from the previous
Autotools baseline.

### Isolate

The failure is limited to the static command-line callback supplied to the
libmikmod driver table. The callback is empty, does not mutate its argument,
and is not part of the exported XMMS plugin ABI.

### Hypothesize

1. **Stale callback constness.** Falsification: compile the same module with
   only the callback parameter made const-correct.
2. **Meson selected an incompatible C language standard.** Falsification:
   compile a minimal assignment under both GNU C17 and GNU C23.
3. **The libmikmod driver-table layout has otherwise diverged.**
   Falsification: compile the entire source object after correcting only the
   callback parameter.

### Verify

The mutable callback fails under both GNU C17 and GNU C23, so language-standard
selection is not causal. A temporary source copy with only a const-qualified
callback parameter compiles successfully using the exact Meson object command;
all remaining driver-table fields type-check. The verified single root cause is
stale constness at the libmikmod callback boundary.

Risk level: Low. The callback is static and empty; aligning its parameter type
with the installed library changes neither behavior nor the XMMS plugin ABI.

## TDD Fix Plan

1. **RED**: Force-enable the system MikMod dependency, compile its Meson module,
   and require the resulting shared object to export the established XMMS input
   plugin entry point.
   **GREEN**: Make the empty command-line callback accept the const-qualified
   argument required by modern libmikmod.
   **verify**: `tests/test-mikmod-build-contract.sh "$PWD"`

2. **RED**: Run the complete supported Meson plugin output contract.
   **GREEN**: Make no additional source changes unless another independently
   reproducible plugin build failure appears.
   **verify**: `meson compile -C build-meson && tests/verify-meson-output-contract.sh build-meson`

**REFACTOR**: None. Keep the compatibility change at the external callback
boundary and avoid edits to MikMod decoding or playback behavior.

## Acceptance Criteria

- [ ] A clean Meson build with MikMod forced enabled produces `libmikmod.so`.
- [ ] The module exports `get_iplugin_info` unchanged.
- [ ] No MikMod decode, playback, or XMMS plugin-vtable behavior changes.
- [ ] All new and existing Meson output-contract tests pass.
- [ ] The existing Autotools/Xvfb regression suite remains green.

## Resolution

<!-- filled in by validate-fix -->
