# Impact: e05s06 Meson cutover (local completion; v0.0.2 preparation pending)

## Result

`e05s06` removed the retired Autotools/libtool delivery tree without changing
public UI, plugin ABI, socket, configuration, or skin contracts. Meson is the
sole supported build, test, distribution, package, and release-artifact path.

The cutover removed generated and source build artifacts, root and nested
Autotools makefiles, configure/libtool support, obsolete gettext rule inputs,
and retired delivery tests. Translation catalogs (`po/*.po`, `po/*.gmo`, and
`po/LINGUAS`) remain because Meson packages them directly.

## Current dependents

- `tools/preflight.sh`, `tools/package-deb.sh`,
  `tools/verify-meson-dist.sh`, and `tools/verify-release-artifacts.sh` define
  the no-download Meson delivery path. Package builds require a Meson source
  archive outside Git; no legacy fallback exists.
- `packaging/debian/rules` selects Meson and runs the supplied-source-archive
  validator before package output can hide forbidden inputs.
- `tests/verify-no-autotools-artifacts.sh` rejects retired build, libtool,
  gettext, test, and output artifacts from tracked Git trees and extracted
  source archives. Its fixture test covers regular files and symlinks.
- `tests/meson.build` is the sole live test registration surface. It retains
  intentional `.libs` fixture directories only as Meson test data, not
  libtool output, and tests direct Meson plugin targets separately.
- Uninstalled plugin discovery uses an absolute Meson build root and direct
  `{Input,Output,…}/<target>/lib*.so` targets; `.libs` remains fixture fallback
  only. Actual Meson mpg123 and ALSA modules are integration-tested.
- Current contributor, architecture, release, package, and workflow guidance
  names Meson commands. Historical manuals, changelogs, and the Solaris plugin
  guide are explicitly marked historical.

## Story effect

- **e05s02–e05s05:** Meson build, distribution, Debian package, release, and
  preflight contracts remain green under the final cutover.
- **e05s06:** Owns source-tree retirement and its regression contract.
- **e06:** Can begin from a single-toolchain, no-download baseline.

## Verification coverage

- `tools/preflight.sh --strict` proves no-download configuration, build,
  33/33 Xvfb-backed tests, Cppcheck, Debian package verification, and release
  artifacts.
- `tools/verify-meson-dist.sh` proves a clean Meson source archive builds,
  tests, and staged-installs, including public `xmms-config` query behavior.
- `tests/verify-preflight-clean-environment.sh` proves clean Git, dirty Git,
  and extracted-source paths use declared system tooling only.
- The forbidden-artifact test exercises Git and extracted-archive fixtures for
  every retired artifact class before the full preflight runs.

## Residual risk and acceptance

The change has high fan-in across build, package, distribution, release,
tests, and documentation, but the final strict local gates pass. Renewed
independent review passed with zero must-fix findings after the Meson build-tree
plugin remediation. The maintainer authorized v0.0.2; landing the cutover and
preparing that release's metadata remain required before tagged draft-release
acceptance.
