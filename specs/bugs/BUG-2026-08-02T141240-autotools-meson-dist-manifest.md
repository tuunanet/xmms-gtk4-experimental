# BUG-2026-08-02T141240: Synchronize the Autotools Meson distribution manifest

**type:** fix
**risk:** P0
**context:** source distribution and Meson Debian packaging

## Problem

The retained Autotools `make dist-gzip` archive omits Meson build definitions
and Meson test helpers named by `Makefile.am`. An extracted archive therefore
cannot configure Meson or execute the Meson Debian package helper.

Reproduce with:

```sh
make dist-gzip
tar -tzf xmms-0.0.1.tar.gz | grep meson_options.txt
```

The expected file is absent, and `meson setup BUILD extracted-source` fails
because the archive has no `meson.build`.

Security impact: NONE. The failure is local and fails closed before package or
release publication. No security exploit path was identified.

## Root Cause Analysis

### Reproduce

A fresh retained Autotools source archive did not contain
`meson_options.txt`. Meson configuration of the extracted archive failed with
no project definition found.

### Isolate

`Makefile.am` composes `EXTRA_DIST` from `MESON_DIST`, but the tracked generated
`Makefile.in` has an older expanded `EXTRA_DIST` list without most Meson files.
Modern Automake cannot safely regenerate the historical generated file.

### Hypothesize

1. The Meson files are included through another Automake distribution path.
   Falsification: inspect the generated archive for required Meson paths.
2. `Makefile.in` is stale relative to `Makefile.am`.
   Falsification: compare every `MESON_DIST` item with the generated
   `EXTRA_DIST` list.
3. The extracted archive can configure Meson without the omitted paths.
   Falsification: invoke Meson setup on a fresh extracted archive.

### Verify

The archive inspection and Meson setup falsified hypotheses 1 and 3. The
manifest comparison confirmed hypothesis 2: the generated manifest is stale.
The verified root cause is an unsynchronized generated distribution manifest.

Risk level: High. Source archives are a declared public packaging contract;
missing Meson inputs blocks the release package path.

## TDD Fix Plan

1. **RED**: Add a source-distribution contract that requires every
   `Makefile.am` `MESON_DIST` path in the generated `Makefile.in` manifest.
   **GREEN**: Synchronize the generated `EXTRA_DIST` list manually while
   preserving the historical Automake format.
   **verify**: `tests/test-autotools-meson-dist.sh "$PWD"`

2. **RED**: Require a retained `make dist-gzip` archive to contain Meson
   definitions and configure successfully with `--wrap-mode=nodownload`.
   **GREEN**: Re-run the generated-manifest synchronization until the extracted
   archive passes the Meson setup check.
   **verify**: `tests/test-autotools-meson-dist.sh "$PWD"`

**REFACTOR**: Keep the test's manifest parser focused on the public source
archive contract and do not regenerate unrelated historical Autotools output.

## Acceptance Criteria

- [x] All declared `MESON_DIST` paths appear in the generated distribution
  manifest.
- [x] A retained Autotools gzip source archive contains Meson configuration and
  test inputs.
- [x] Meson configures a fresh extracted retained source archive with no
  download mode.
- [x] Packaging, Meson, and retained Autotools gates pass.

## Resolution

**Fixed:** 2026-08-02

The retained root, `libxmms`, and `xmms` generated distribution manifests now
carry Meson build definitions, templates, test helpers, and Meson-only source
inputs. The regression creates a fresh retained archive from a source checkout,
asserts every declared path, and configures Meson without downloads. It clears
inherited make jobserver state so the check also passes from `make check`.

**Evidence:** `tools/package-deb.sh`; `xvfb-run --auto-servernum meson test -C
build-meson --print-errorlogs` (29/29); and `xvfb-run --auto-servernum make
check` passed.
