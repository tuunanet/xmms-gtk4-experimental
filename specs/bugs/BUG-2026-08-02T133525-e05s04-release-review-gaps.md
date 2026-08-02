# BUG-2026-08-02T133525: Close Meson release packaging review gaps

**type:** fix
**risk:** P0
**context:** Meson Debian packaging and release-artifact verification

## Problem

The reviewed Meson release path can publish artifacts whose declared release
version differs from Meson's version, and its normal Debian metadata does not
declare the Meson tools required by the package rules. The release workflow
also installs generated packages into the CI host instead of using the
extracted-artifact verifier. Missing artifact directories make both package
verifiers succeed without checking an artifact. The initial wrapper regression
test can also skip successful verification when a leftover `deb-artifacts`
directory is absent, and neither verifier asserts the runtime library's ELF
SONAME.

Reproduce with:

```sh
# A fixture with configure version 1.3.0 and Meson version 9.9.9 is accepted.
tools/check-release-version.sh 1.3.0 FIXTURE
# The following exits zero although the directory does not exist.
tools/verify-release-artifacts.sh /tmp/missing-artifacts
```

Security impact: LOW. The manually dispatched, annotated-tag workflow has no
identified untrusted input path. Replacing host installation with extraction
reduces avoidable CI-host package-installation exposure.

## Root Cause Analysis

### Reproduce

- `tools/check-release-version.sh` accepted a fixture with matching retained
  Autotools metadata but a mismatched Meson project version.
- `packaging/debian/control` omitted both the required `meson (>= 1.3.2)` and
  `ninja-build` build dependencies.
- The release workflow had no call to `tools/verify-release-artifacts.sh` and
  installed generated packages with `apt-get install`.
- The release-artifact verifier returned success for a nonexistent artifact
  directory.
- The wrapper test conditionally skipped successful artifact verification when
  `deb-artifacts` was unavailable, and package verification checked only the
  runtime library filename rather than its ELF SONAME.

### Isolate

The failures are confined to release metadata validation, Debian build
metadata, workflow smoke verification, optional-artifact shortcuts in package
verifier tests, and an incomplete package ABI assertion. No player, plugin,
or control-socket code is involved.

### Hypothesize

1. The retained release validator is the sole version authority.
   Falsification: add a mismatched Meson version to an otherwise valid fixture.
2. Workflow-installed tooling makes package metadata sufficient.
   Falsification: inspect the package rules and declared build dependencies.
3. Host installation is necessary for release smoke coverage.
   Falsification: run the existing extracted-artifact verifier against the
   generated package directory.
4. A missing artifact directory is an intentional successful test skip.
   Falsification: execute both verifiers with an absent path and inspect the
   exit status.
5. Wrapper coverage provides a real successful verifier execution without
   pre-existing build output.
   Falsification: remove `deb-artifacts` and run the wrapper test.
6. A runtime library filename `libxmms.so.1` proves its ABI SONAME.
   Falsification: package an ELF whose filename is `libxmms.so.1` but whose
   `DT_SONAME` is different.

### Verify

All four falsifications confirmed the hypotheses: the validator ignored Meson,
the Debian metadata omitted Meson/Ninja, the workflow bypassed the existing
extracted-artifact verifier, and absent artifacts exited zero. The root cause
is incomplete migration of the retained release contracts to the Meson
package path.

Risk level: High. A version mismatch or insufficient build metadata can block
or mislabel a release; CI host installation weakens verification isolation.

## TDD Fix Plan

**Round-two addendum:** The original step 3 did not create deterministic
package fixtures. Extend it to construct valid temporary packages and a Meson
source archive for each verifier invocation, including a filename/SONAME
mismatch fixture. Require `readelf -d` to report exactly `libxmms.so.1`.


1. **RED**: Require package-recipe and release-tool contracts to reject absent
   Meson/Ninja build dependencies and a Meson version that differs from the
   requested release version.
   **GREEN**: Declare the tools in Debian metadata and validate the Meson
   project version alongside the retained release metadata.
   **verify**: `tests/test-package-recipes.sh "$PWD" && tests/test-release-tools.sh "$PWD"`

2. **RED**: Require the workflow contract to invoke the extracted-artifact
   verifier and reject installation of generated Debian packages on the CI
   host.
   **GREEN**: Invoke the verifier on the raw package directory before asset
   renaming and remove the host-install smoke step.
   **verify**: `tests/test-package-recipes.sh "$PWD"`

3. **RED**: Require missing package artifact paths to fail and keep the normal
   test suites self-validating when artifacts are unavailable.
   **GREEN**: Make both verifiers fail closed and register focused wrapper
   tests that assert that failure or execute real artifacts when supplied.
   **verify**: `xvfb-run --auto-servernum meson test -C build-meson debian-package-contract release-artifacts --print-errorlogs`

4. **RED**: Require the release verifier to use the caller-selected Meson build
   directory for its source archive.
   **GREEN**: Honor `MESON_BUILD_DIR` with the existing default preserved.
   **verify**: `MESON_BUILD_DIR="$PWD/build-meson" tools/verify-release-artifacts.sh deb-artifacts`

**REFACTOR**: Retain one focused verifier interface and keep lifecycle delivery
status authoritative in `specs/execution-status.yaml`.

## Acceptance Criteria

- [x] Debian metadata declares Meson 1.3.2+ and Ninja.
- [x] Release validation rejects a Meson-version mismatch.
- [x] Release CI verifies raw artifacts without installing generated packages.
- [x] Missing artifact paths fail; core test registrations exercise that result.
- [x] The verifier honors `MESON_BUILD_DIR`.
- [x] Wrapper tests construct deterministic valid artifacts, independent of leftover build output.
- [x] Package verification asserts ELF `DT_SONAME` is exactly `libxmms.so.1`.
- [x] Full packaging, test, lint, and release-artifact gates pass.

## Resolution

**Fixed:** 2026-08-02

The wrapper now builds fresh valid and wrong-SONAME Debian fixtures plus a
selected-build-directory source archive on every run. Package verification uses
`readelf -d` and rejects a filename-compatible library whose `DT_SONAME` is not
exactly `libxmms.so.1`. The prior version, build-dependency, extracted-only,
and fail-closed fixes remain covered.

**Evidence:** `tools/package-deb.sh`, `MESON_BUILD_DIR="$PWD/build-meson"
 tools/verify-release-artifacts.sh deb-artifacts`, Meson 29/29, retained
Autotools checks, and `make lint` passed.
