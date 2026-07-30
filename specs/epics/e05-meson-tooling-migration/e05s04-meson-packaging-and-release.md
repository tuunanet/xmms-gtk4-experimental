# e05s04: Build Debian packages and release artifacts through Meson

**type:** feat
**risk:** P0
**context:** packaging and release infrastructure

## Context

The distribution contract must retain Debian package names, content, target
matrix, checksum verification, tag validation, and draft-only publication while
switching package compilation from Autotools to Meson.

## Requirements

#### MODIFIED: Debian build implementation

**Before:** `debian/rules`, local package helpers, and the manual release
workflow invoke configure/make paths.
**After:** They invoke Meson through retained Debian metadata and produce the
same package/release interfaces.

## Steps

1. Convert Debian rules and expose a Meson-era package helper → verify: `tools/package-deb.sh && tests/verify-debian-package-contract.sh deb-artifacts`
2. Convert release workflow commands and static contracts to Meson artifacts → verify: `tests/test-package-recipes.sh "$PWD"`
3. Validate package/install/checksum release artifacts → verify: `tools/verify-release-artifacts.sh deb-artifacts`

## Test traceability

- SC-e05s04-P0-01
- SC-e05s04-P0-02

## Acceptance criteria

- Given each declared target image, when packaging runs, then `xmms` and
  `libxmms-dev` metadata and smoke tests preserve their current contract.
- Given an annotated tag, when the release workflow runs after cutover, then it
  creates only a verified draft release.

## Out of scope

No new target distro, package name, or automatic publication is introduced.
