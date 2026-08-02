# BUG-2026-08-02T120106: Restore libxmms SONAME parity for Meson packages

**type:** fix
**risk:** P0
**context:** Meson library ABI and Debian packaging

## Problem

The Meson-built Debian runtime package cannot satisfy the established
`libxmms.so.1` runtime-library contract. Debian package assembly stops before
producing artifacts because the staged Meson install provides a different
SONAME.

Reproduce with:

```sh
tools/package-deb.sh
```

Security impact: NONE — no security exploit path was identified. The package
assembly fails closed before producing or publishing an invalid artifact.

## Root Cause Analysis

### Reproduce

A clean Meson source archive configures, builds, and tests successfully. Debian
assembly then rejects the required runtime-library pathname because the staged
installation has no matching library.

### Isolate

The historical library version declaration uses libtool's
`current:revision:age` convention, whose ABI SONAME is derived from
`current - age`. The Meson declaration instead treated the three libtool
components as a direct library filename version and changed the ABI SONAME.

### Hypothesize

1. **The Debian package manifest is obsolete.** Falsification: compare the
   established runtime library contract with the historical version-info
   semantics.
2. **The Meson version mapping is incorrect.** Falsification: derive the
   libtool ABI SONAME from the preserved version-info tuple and compare it with
   the Meson install output.
3. **The static development library is the only mismatch.** Falsification:
   inspect both the runtime and development staged package paths.

### Verify

The historical version-info calculation yields runtime ABI SONAME `1`, while
Meson emits ABI SONAME `4`. The development static archive is present; only the
shared-library version mapping is incompatible. The verified root cause is an
incorrect direct translation from libtool version-info to Meson library version
fields.

Risk level: High. `libxmms` is a public compatibility surface, and changing its
SONAME breaks existing runtime package and plugin-linking expectations.

## TDD Fix Plan

1. **RED**: Require the Meson install and output contracts to expose the
   historical `libxmms.so.1` ABI library name.
   **GREEN**: Map the preserved libtool version-info semantics to Meson's
   shared-library version and soversion fields without changing the public API.
   **verify**: `meson setup /tmp/xmms-soname-build --wrap-mode=nodownload && meson compile -C /tmp/xmms-soname-build && tests/verify-meson-install-layout.sh /tmp/xmms-soname-build`

2. **RED**: Build the Debian packages from a clean Meson source archive and
   observe the missing runtime-library contract.
   **GREEN**: Re-run the package helper after the corrected install layout and
   verify both package payloads.
   **verify**: `tools/package-deb.sh && tests/verify-debian-package-contract.sh deb-artifacts`

**REFACTOR**: Keep the library version mapping explicit and confined to the
Meson library target.

## Acceptance Criteria

- [x] Meson installs `libxmms` with ABI SONAME `1`.
- [x] The runtime package contains the required `libxmms.so.1` library.
- [x] The development package retains headers, linker name, static archive, and
  plugin build macro.
- [x] Full Meson and Debian package verification pass.

## Resolution

**Fixed:** 2026-08-02

**Root cause confirmed:** Meson directly translated libtool's `4:1:3`
version-info tuple, emitting ABI SONAME `4` instead of the historical
`current - age` SONAME `1`.

**Fix applied:** `libxmms/meson.build` now declares version `1.3.1` and
`soversion` `1`, preserving the existing shared-library ABI name.

**Hardening added:** The Meson output and staged-install contracts require
`libxmms.so.1.3.1`; the Debian payload contract checks the runtime SONAME,
development linker name, static archive, headers, and plugin macro.

**Generalize-fix:** Searched all `**/meson.build` files for direct
`version: '4.1.3'` or `soversion: '4'` mappings; match count: 0. The
repository does not provide the generic `verify-generalize-sweep.sh` helper.

**Evidence:** `tools/package-deb.sh &&
tests/verify-debian-package-contract.sh deb-artifacts` passed from a clean
Meson source archive (27 Meson tests); `./configure --disable-esd && make
-j"$(nproc)" && xvfb-run --auto-servernum make check` also passed.

**Commit:** `3c248ed fix(meson): preserve libxmms ABI SONAME`
