# BUG-2026-07-30T101400: Meson ESD feature option is a no-op

## Problem

`-Desd=enabled` is accepted by Meson but neither resolves eSound nor creates
the legacy `libesdout.so` output module. A declared feature option must either
build its supported module or fail clearly when its system dependency is not
available.

Reproduce with:

```sh
meson setup /tmp/xmms-esd . --wrap-mode=nodownload -Desd=enabled
meson introspect /tmp/xmms-esd --targets
```

Expected: a system eSound dependency is required and `libesdout.so` is a
configured target when it is available; otherwise forced enable fails with an
actionable dependency error.

Actual: setup exits zero and target introspection contains no ESD module.

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

On the supported dependency image, which has no eSound development package,
forced ESD enable succeeds and emits no ESD target.

### Isolate

The legacy build probes eSound and conditionally includes its established
output module. The Meson project declares the option but never reads it to
resolve a dependency or enter the ESD target directory.

### Hypothesize

1. **The option is disconnected from the Meson graph.** Falsification: search
   the Meson definitions for ESD dependency and target references.
2. **The plugin is intentionally unsupported.** Falsification: compare the
   frozen baseline and legacy feature contract, which retain ESD as an
   optional output feature.

### Verify

There is no Meson ESD dependency or target reference, while the baseline and
legacy contract retain the optional feature. The verified root cause is a
no-op Meson option.

Risk level: Medium. Forced feature enable silently produces a different
plugin inventory. The fix is limited to the optional output target and does
not change the plugin ABI, playback implementation, or default
`--disable-esd` package policy.

## TDD Fix Plan

1. **RED**: Add a configuration contract that forces ESD enabled. When eSound
   is unavailable, it must fail rather than silently omit the module; when it
   is installed, it must compile `libesdout.so` and export `get_oplugin_info`.
   **GREEN**: Wire the `esound` system dependency and ESD shared module under
   the existing feature option.
   **verify**: `tests/test-meson-configure-contract.sh "$PWD"`

2. **RED**: Re-run the full supported default Meson build after the ESD wiring
   is added.
   **GREEN**: Keep default auto behavior compatible with the supported
   dependency image and retain all other output modules.
   **verify**: `meson compile -C build-meson && tests/verify-meson-output-contract.sh build-meson`

## Acceptance Criteria

- [ ] `-Desd=enabled` never succeeds without an ESD module or dependency.
- [ ] A system eSound dependency is the only ESD dependency source.
- [ ] When available, the ESD module preserves `get_oplugin_info`.
- [ ] Default supported builds and legacy Xvfb tests pass.

## Resolution

Wired the feature to the system `esound` dependency and the established ESD
shared module. Forced enable now fails when eSound is absent; when available,
the configuration contract requires `libesdout.so` and `get_oplugin_info`.
Default Meson output and baseline parity contracts pass.
