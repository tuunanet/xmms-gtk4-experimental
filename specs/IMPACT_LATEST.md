# Impact: generic release-packaging workflow

## Target

- New `.github/workflows/package-release.yml`, adapted from
  `../xmms-gtk2/.github/workflows/package-linux-mint.yml`.
- Existing release documentation, package contract test, and package build
  prerequisites.

## Dependents

1. **Maintainers** manually dispatch the workflow from a matching annotated
   release tag and inspect the resulting draft-release assets.
2. **`tools/check-release-version.sh`** validates that the requested version,
   `configure.in`, checked-in `configure`, and `CHANGELOG.md` agree.
3. **`tools/extract-release-notes.sh`** produces the draft-release notes.
4. **`tools/build-deb.sh`** consumes the source archive, per-target Debian
   distribution/revision variables, and writes the `xmms` and `libxmms-dev`
   packages that the workflow inspects and installs.
5. **`packaging/debian/rules`** runs the Xvfb-backed package test gate; the
   workflow environment must provide both GTK2 and GTK3 development headers.
6. **`docs/releases.md`** is the maintainer-facing contract for workflow name,
   targets, tag requirement, draft-release behavior, and artifact review.
7. **`tests/test-package-recipes.sh`** is the existing static package-delivery
   contract and is the appropriate shell-test location for workflow invariants.

## Affected stories

- **e04s01 — Port generic release-packaging workflow:** new release-delivery
  path with no player, plugin ABI, socket, configuration, or skin behavior
  change.
- **e03s03 — GTK3 Play-button proof:** indirectly exercised because the package
  environment must install `libgtk-3-dev` and `packaging/debian/rules` runs
  `make check`.

## Test coverage

- `tests/test-release-tools.sh` already validates release-version and
  release-notes helper failure paths.
- `tests/test-package-recipes.sh` already guards Debian recipe and package-tool
  contracts; extend it with static workflow assertions.
- `xvfb-run --auto-servernum make check` builds the GTK3 proof and executes all
  package/release shell contracts.
- GitHub Actions itself cannot be run locally; static assertions cover the
  dispatch, tag, target, dependency, artifact, and permission contract, while
  a maintainer-dispatched annotated tag is the production integration check.

## Risk: High

The workflow can create release assets and invokes the complete source and
Debian package path across two external container images. Incorrect tag guards,
permissions, dependencies, or target metadata could produce an invalid draft
release or prevent release packaging.

## Recommended action

Port only the donor's release-packaging workflow under a generic filename;
adapt fork branding and GTK3 dependencies; add static shell contracts; document
manual dispatch and draft-only behavior; require review before workflow use.
