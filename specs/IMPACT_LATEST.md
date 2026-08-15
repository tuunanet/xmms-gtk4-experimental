# Impact: v0.0.4 trusted container workspace repair

## Target

`.github/workflows/package-release.yml` target-container checkout setup.

## Dependents (5)

- `tools/package-deb.sh`: requires usable Git metadata to create the Meson
  source archive for the checkout build.
- `tests/test-package-recipes.sh`: statically protects package-workflow
  dependencies, ordering, and release behavior.
- `tests/test-meson-migration-contracts.sh`: validates the release lifecycle
  state for the active e05 repair.
- `docs/architecture/build-and-test.md`: tells maintainers how container
  release builds obtain a source archive.
- `e05s06` lifecycle records: own the P0 cutover acceptance criterion.

## Affected Stories

- `e05s06`: Meson final Autotools removal; its release-acceptance task remains
  in progress until both package targets and the draft release succeed.

## Test Coverage

- `tests/test-package-recipes.sh` covers Git installation and dependency-before-
  checkout ordering.
- Gap: no contract requires a container user to trust the exact checked-out
  workspace before Meson requests Git metadata.
- External evidence: `v0.0.3` workflow run `31870919715` reached Meson on both
  targets but failed because Git rejected the workspace as dubiously owned.

## Risk: High

The change is small but affects the protected release path and every supported
container target. A broad safe-directory setting would weaken Git's ownership
protection, so the repair must trust only `${GITHUB_WORKSPACE}` and prove that
it runs after checkout and before package construction.

## Recommended action

Add the focused static contract first, then configure the one workspace as
trusted and retain the existing tag validation, pinned actions, no-download
Meson configuration, and release permissions. Re-run strict preflight and a
new authorized tagged draft-release workflow before closing e05s06.
