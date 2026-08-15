# Impact: release-container test portability repair

## Target

Target-container source distribution in `tools/package-deb.sh`, plus its
portable shell and C-lint contracts.

## Dependents (6)

- `.github/workflows/package-release.yml`: invokes `tools/package-deb.sh` in
  the Linux Mint and Ubuntu release containers.
- `tools/preflight.sh`: uses the same package helper and is the canonical local
  release proof.
- `tests/test-package-recipes.sh`: protects package-helper release behavior.
- `tests/test-autonomous-epic-workflow.sh`: is run from generated source trees
  during Meson distribution testing.
- `tools/run-c-lint.sh` and `tools/cppcheck-suppressions.txt`: define the
  reviewed legacy diagnostic baseline for every supported build image.
- `e05s06`: remains blocked on a successful tagged container draft release.

## Affected Stories

- `e05s06`: final Meson cutover; its tagged release acceptance must work in
  both declared target containers.

## Test Coverage

- External `v0.0.4` run `31877965751` reproduces all three defects in the real
  release images.
- Gap 1: package source-distribution tests are not wrapped in Xvfb.
- Gap 2: the autonomous policy contract imports optional PyYAML.
- Gap 3: the reviewed Cppcheck baseline lacks one known narrow diagnostic from
  Linux Mint's Cppcheck 2.13.

## Risk: High

All changes affect the protected release path and two different container
images. The runtime application is untouched; each correction must remain
narrow and have a direct regression contract.

## Recommended action

Add one TDD slice per defect: run Meson distribution under Xvfb, remove the
nonstandard Python dependency from the policy test, and add a line-specific
Cppcheck suppression. Re-run the actual target containers locally where
possible, then obtain authorization for a new immutable patch tag.
