# BUG-2026-08-02T201500: Package retained source archives without VCS metadata

**type:** fix
**risk:** P0
**context:** retained source distribution and Meson Debian packaging

## Problem

`tools/package-deb.sh` unconditionally runs `meson dist`. Meson requires a Git
or Mercurial checkout for that operation. A released retained Autotools source
archive has no VCS metadata, so after `./configure --disable-esd`, `make deb`
fails with:

```text
Dist currently only works with Git or Mercurial repos
```

The new Meson source inputs are present in the retained archive, but its
Debian package path is unusable.

Security impact: NONE. The failure is local and fails closed before package
publication. The fallback must retain quoted paths, temporary archive handling,
and no-download Meson configuration.

## Root Cause Analysis

### Reproduce

1. Create a retained `make dist-gzip` archive from a source checkout.
2. Extract it without `.git` metadata.
3. Configure the extraction and run `make deb`.

The package helper configures Meson, then `meson dist` exits because the
extraction is not a VCS repository.

### Isolate

The failure is confined to `tools/package-deb.sh` source-archive creation.
`tools/build-deb.sh` already accepts a versioned archive and produces the
retained Debian packages. The source archive now contains the required Meson
inputs.

### Hypothesize

1. A VCS checkout is available to every retained source-archive build.
   Falsification: package a fresh extracted release archive.
2. `meson dist` has an archive-mode fallback without VCS metadata.
   Falsification: invoke it from the extracted archive.
3. The retained Autotools archive lacks the Meson inputs required by packaging.
   Falsification: configure Meson in that fresh archive.

### Verify

Hypotheses 1 and 2 are false. Hypothesis 3 is false after
BUG-2026-08-02T141240: the extraction configures Meson. The root cause is an
unconditional VCS-only source-archive command in the package helper.

Risk level: High. The public source-tarball Debian packaging workflow is a
compatibility contract.

## TDD Fix Plan

1. **RED**: Add an integration test that builds a retained Autotools archive,
   extracts it without VCS metadata, configures it, and invokes `make deb`.
   **GREEN**: In a VCS checkout retain Meson `dist`; outside one, create the
   versioned retained archive through the configured Autotools distribution
   target and pass it to `build-deb.sh`.
   **verify**: `tests/test-autotools-package-deb.sh "$PWD"`

2. **RED**: Remove the hard-coded source-archive version from the existing
   retained archive regression.
   **GREEN**: Derive the project version and archive root from Meson project
   metadata.
   **verify**: `tests/test-autotools-meson-dist.sh "$PWD"`

**REFACTOR**: Keep the release workflow on the Meson VCS path. Do not restore
an Autotools archive injection to CI; the local non-VCS fallback only preserves
the public retained-source workflow.

## Acceptance Criteria

- [x] A fresh extracted retained source archive can run `make deb` without
  `.git` metadata.
- [x] VCS checkout packaging continues to create the Meson gzip source archive.
- [x] Archive regression derives its version rather than hard-coding `0.0.1`.
- [x] Package, artifact, Meson, retained Autotools, and lint gates pass.

## Resolution

**Fixed:** 2026-08-02

`tools/package-deb.sh` retains Meson `dist --formats=gztar` in a VCS checkout.
When invoked by `make deb` from a configured retained source archive, it creates
the exact versioned retained gzip archive through `make dist-gzip` instead. An
explicit archive remains accepted through `DEB_SOURCE_ARCHIVE`; the release
workflow does not use that local compatibility path.

The integration test creates and extracts a retained source archive without
`.git`, configures it, runs `make deb`, and validates the resulting packages.
The archive test derives the Meson project version dynamically.

**Evidence:** VCS package/artifact verification, source-archive package test,
Meson 30/30, retained Autotools preflight, and lint passed.
