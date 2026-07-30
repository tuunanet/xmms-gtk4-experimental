# e05s03: Prove Meson test, install, gettext, and distribution parity

**type:** feat
**risk:** P0
**context:** test and distribution infrastructure

## Context

Compiled binaries alone do not establish replacement readiness. Meson must run
the full test inventory, reproduce installation and translation layout, and
provide a project-owned clean source-distribution verification path.

## Requirements

#### ADDED: Meson parity gates

Meson registers every existing test, provides required build-tree paths and
Xvfb setup, installs the current public layout, and proves clean source archive
build/test/install behavior.

## Steps

1. Register all current tests in Meson with isolated environments → verify: `xvfb-run --auto-servernum meson test -C build-meson --print-errorlogs`
2. Reproduce gettext and staged install layout → verify: `tests/verify-meson-install-layout.sh build-meson`
3. Add clean Meson source-distribution verifier → verify: `tools/verify-meson-dist.sh`

## Test traceability

- SC-e05s03-P0-01
- SC-e05s03-P0-02

## Acceptance criteria

- Given the Meson build, when the complete test suite runs, then no legacy Make
  target is needed to execute it.
- Given a Meson source archive, when extracted in a clean directory, then it
  configures, compiles, tests, and installs successfully.

## Out of scope

Debian package and release workflow conversion follows in e05s04.
