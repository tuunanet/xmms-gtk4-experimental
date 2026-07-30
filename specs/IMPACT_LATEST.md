# Impact: Meson tooling migration

## Target

Replace the repository's Autotools/libtool build and delivery contract with
Meson, including build definitions, developer/agent commands, tests, Debian
packaging, source distribution, release packaging, documentation, and current
lifecycle specifications.

## Dependents

- **33 Autotools source manifests**: root and subsystem `configure.in` and
  `Makefile.am` files define feature probes, generated headers, build order,
  plugin modules, install paths, tests, and source distribution.
- **34 tracked generated build artifacts**: `configure` and `Makefile.in`
  files must remain consistent during the temporary parity phase, then be
  removed atomically with their sources.
- **Packaging and release**: `packaging/debian/rules`, `tools/build-deb.sh`,
  `tools/check-release-version.sh`, `tools/extract-release-notes.sh`, and the
  manual package-release workflow all invoke or inspect the legacy build.
- **Tests**: `tests/Makefile`, `test-package-recipes.sh`,
  `test-release-tools.sh`, plugin-linkage checks, and C/GTK test binaries
  depend on Make targets, source-tree locations, or generated configuration.
- **Agent and contributor contracts**: `CLAUDE.md`, `CONTRIBUTING.md`,
  `README.md`, build-and-test architecture, release documentation, and
  non-historical specs contain legacy commands or assumptions.
- **Compatibility-sensitive outputs**: `xmms`, `wmxmms`, `libxmms`, plugin
  module names/layout, gettext catalogs, installed headers/man pages,
  configuration defaults, package names, and source archives.

## Affected stories

- **e05s01**: baseline/state reconciliation and decision ledger.
- **e05s02**: Meson graph/options and temporary dual-build parity.
- **e05s03**: test, install, gettext, lint, plugin, and distribution parity.
- **e05s04**: Debian package and release workflow conversion.
- **e05s05**: agent preflight, contributor commands, workflow contracts, and
  architecture/specification updates.
- **e05s06**: final legacy-toolchain removal.
- **e03s03 / ADR-0001**: GTK3 proof must remain separately linked and
  observable through the replacement test graph.
- **e04s01**: package workflow must preserve tagged source, target matrix,
  checksum, and draft-only release guarantees while changing build commands.

## Test coverage

- `tests/test-package-recipes.sh` currently asserts Makefile/configure and
  Debian-rule text; it must be redesigned as observable Meson/package/release
  contracts before legacy removal.
- `tests/test-release-tools.sh` currently creates `configure.in` fixtures;
  version extraction and release metadata need a Meson-era public source of
  truth plus backward-compatible release semantics.
- GLib C tests and plugin-linkage shell checks exercise compiled outputs, but
  require a Meson test environment that supplies plugin paths and Xvfb for
  GTK-bearing tests.
- There is no current Meson parity, install-tree, or source-archive contract.
  Those are mandatory new gates before deleting the legacy toolchain.

## Risk: High (10/10)

The change has repository-wide fan-in across build, package, release, agent,
and source-distribution contracts. A partial migration can silently alter
plugins, install layout, optional feature availability, translation behavior,
or release artifacts; it therefore needs staged parity and explicit cutover
criteria.

## Recommended action

Proceed only through the e05 staged epic: capture current baselines; spike
Meson mappings for feature probes, gettext, libtool/plugin modules, and source
distribution; require observable parity; then update delivery and agent
contracts before one atomic legacy-toolchain removal slice.
