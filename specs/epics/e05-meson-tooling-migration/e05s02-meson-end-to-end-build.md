# e05s02: Establish a Meson end-to-end build slice

**type:** feat
**risk:** P0
**context:** build graph

## Context

Meson needs an end-to-end proof through the core library, player, dock app,
plugins, and existing GTK3 migration proof before broad delivery contracts can
trust it. Autotools remains available solely as the parity baseline.

## Requirements

#### ADDED: Meson build authority in transition

A clean out-of-tree Meson build resolves only system dependencies and produces
all core binaries/modules with the same names and GTK-major isolation as the
legacy build.

## Steps

1. Map legacy feature probes to Meson project options and generated configuration → verify: `meson setup build-meson --wrap-mode=nodownload && meson configure build-meson`
2. Add core, plugin, and GTK3-proof build graph → verify: `meson compile -C build-meson && tests/verify-meson-output-contract.sh build-meson`
3. Compare options and outputs to the frozen legacy baseline → verify: `tools/verify-build-parity.sh build-meson`

## Test traceability

- SC-e05s02-P0-01
- SC-e05s02-P0-02

## Acceptance criteria

- Given a fresh build directory, when Meson is configured with no download
  mode, then all required core outputs compile.
- Given the GTK3 proof, when linked by Meson, then it links GTK3 and not GTK2.

## Out of scope

No official packages or releases switch to Meson in this story.
