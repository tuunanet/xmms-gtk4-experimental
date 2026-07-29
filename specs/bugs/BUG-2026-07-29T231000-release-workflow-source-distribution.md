# BUG-2026-07-29T231000: Source distribution omits release workflow

## Problem

`make distcheck` fails after the release-workflow contract is added. The source
tree contains the workflow, but the extracted distribution tree does not, so
`tests/test-package-recipes.sh` reports the missing file and its required
release safeguards.

**Expected:** a source archive includes every checked-in delivery contract that
runs from `make check`.

**Security impact:** LOW. No exploit path was identified. The omission blocks a
release-quality gate rather than widening token, artifact, or runtime access.

## Root cause analysis

### Reproduce

Run `xvfb-run --auto-servernum make distcheck`. The generated distribution
build reaches the package-contract test, which fails only the release-workflow
assertions.

### Isolate

The workflow exists in the working source tree but is absent from the extracted
distribution tree. The top-level source-distribution manifest enumerates
architecture and specification additions but has no entry for the new workflow.

### Hypothesize

1. **Confirmed:** the source-distribution manifest was not updated when the new
   checked-in workflow was introduced.
2. **Rejected:** the workflow contract test has an invalid path; it succeeds
   against the working source tree.
3. **Rejected:** the workflow itself is malformed; failure occurs before its
   contents can be inspected in the distribution tree.

### Verify

Manifest inspection finds no workflow entry, while the working source file is
present and the distribution tree contains none. This proves the missing
manifest entry is the single root cause.

## TDD fix plan

1. **RED:** Extend the existing package-contract test to require the workflow
   in the source-distribution manifest. The test fails because the manifest
   omits it.
   **GREEN:** Add the workflow to authoritative and shipped distribution
   manifests.
   **verify:** `tests/test-package-recipes.sh "$PWD" && xvfb-run --auto-servernum make distcheck`

## Acceptance criteria

- [ ] Static package contracts require the workflow in source distribution.
- [ ] Source archives contain the workflow and package contracts pass in the
      isolated distcheck build.
- [ ] Full distcheck passes without committing generated artifacts.

## Resolution

Fixed by adding the workflow to both source-distribution manifests and extending
the package contract. `tests/test-package-recipes.sh` and the full
`xvfb-run --auto-servernum make distcheck` gate pass.
