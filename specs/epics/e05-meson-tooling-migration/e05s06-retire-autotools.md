# e05s06: Remove the retired Autotools toolchain

**type:** refactor
**risk:** P0
**context:** final build-system cutover

## Context

The approved destination is one Meson toolchain. This final slice may remove
legacy build files only after the Meson build, distribution, packaging, release,
and agent-preflight gates prove parity.

## Delivery status

Local cutover verification is complete. The immutable `v0.0.2` tag's
package workflow failed because its containers checked out before Git was
installed. The maintainer authorized `v0.0.3`; tagged draft-release acceptance
is now `in_progress` while that repair is verified and delivered.

## Requirements

#### REMOVED: Autotools/libtool delivery contract

**Before:** tracked `configure.in`, `configure`, `Makefile.am`, `Makefile.in`,
libtool artifacts, and live command/documentation contracts define the build.
**After:** (removed) Meson definitions and project-owned verification helpers
are the sole supported build and delivery authority.

## Steps

1. Run final Meson parity and delivery gates before deletion → verify: `tools/preflight.sh --strict && tools/verify-meson-dist.sh && tools/package-deb.sh`
2. Delete all legacy build artifacts and replace legacy contract assertions → verify: `tests/verify-no-autotools-artifacts.sh "$PWD"`
3. Run cutover verification including tagged draft-release acceptance → verify: `tools/preflight.sh --strict && tools/verify-meson-dist.sh && tools/verify-release-artifacts.sh deb-artifacts`

## Test traceability

- SC-e05s06-P0-01

## Acceptance criteria

- Given the tracked repository after cutover, when forbidden-path validation
  runs, then no Autotools/libtool/configure/Makefile artifact remains.
- Given a fresh supported host, when preflight, package, distribution, and
  v0.0.3 tagged release validation run, then they need no legacy build command.

## Out of scope

No runtime interface or UI behavior change is authorized by this removal.
