# e04s01: Deliver draft Linux packages from an annotated release tag

<!-- story: e04s01 -->

**type:** feat

**risk:** P0

**context:** release infrastructure

**bcps:** 8

## 1. Summary

Port the sibling repository's multi-distribution Linux package-and-draft-release
workflow under the generic name `package-release.yml`.

## 2. User

Release maintainers preparing an XMMS GTK4 Experimental version from an
annotated tag.

## 3. Problem

This fork has local Debian and release helpers but no checked-in GitHub Actions
workflow that runs them in declared target environments and stages release
assets safely.

## 4. Value

A maintainer can produce reproducible, inspectable Linux package assets for a
specific release tag without manually reconstructing each target environment.

## 5. Context

The donor workflow builds Linux Mint 22.3 and Ubuntu 26.04 packages, validates
release metadata, checksums artifacts, and creates or resumes a draft release.
The fork retains that delivery shape but must use its own branding and install
`libgtk-3-dev` for the enabled isolated migration-proof test.

## 6. In scope

- One manual `package-release.yml` workflow.
- Matching annotated-tag/version validation.
- Donor Linux Mint 22.3 and Ubuntu 26.04 package matrix.
- Existing source/archive, Debian package, checksum, smoke-test, and
  draft-release sequence.
- Static workflow contracts and aligned release documentation.

## 7. Out of scope

- PR/push CI, Dependabot, templates, new targets, automatic publication,
  release-tag creation, or packaging recipe redesign.

## 8. Dependencies

- GitHub Actions `workflow_dispatch`, contexts, artifacts, and scoped
  `GITHUB_TOKEN` permissions [OK; official GitHub documentation].
- Donor-pinned `actions/checkout`, `upload-artifact`, and `download-artifact`
  SHAs [OK; adopted from the sibling repository].
- Existing Debian build dependencies plus `libgtk-3-dev` [OK; required by
  `configure.in` when the GTK3 proof is enabled].

## 9. Module purpose

`.github/workflows/package-release.yml` is a release-only orchestration module:
it validates an immutable tag, invokes existing local release/package helpers,
and stages draft assets. It does not change player runtime behavior.

## 10. Callers

A release maintainer manually dispatches the workflow on an annotated
`vVERSION` tag. GitHub Actions calls each job; jobs call
`tools/check-release-version.sh`, `tools/extract-release-notes.sh`, `make`, and
`tools/build-deb.sh` through existing Makefile targets.

## 11. Contracts

- Version input, tag, annotated-tag target, checked-in metadata, and main
  ancestry must agree.
- Default token permission is `contents: read`; only draft-release assembly has
  `contents: write`.
- Published releases are never modified.
- Artifacts are checksummed before upload or draft-release attachment.
- The workflow installs GTK2 and GTK3 development dependencies and retains the
  `xmms` and `libxmms-dev` package names.

## 12. Requirements

### ADDED: Generic draft-release packaging

A manually dispatched generic workflow builds and validates source and Debian
assets for both declared Linux targets, then creates or resumes an unpublished
draft release only for the matching annotated tag.

### ADDED: Static release-workflow contract

The existing package-contract shell test fails if workflow name, trigger,
permissions, tag guards, target matrix, GTK3 dependency, artifact checks, or
fork branding drift.

## 13. Design

Adopt the donor workflow as one file rather than inventing a new abstraction.
Rename it to `package-release.yml`, retain the donor's pinned action SHAs and
matrix, replace repository-specific identity strings, and add the one GTK3
build prerequisite. **Reason for Depth:** workflow orchestration needs a single
reviewable boundary for its tag, privilege, package, artifact, and release
invariants.

## 14. Files and data

- `.github/workflows/package-release.yml`
- `tests/test-package-recipes.sh`
- `docs/releases.md`
- `docs/architecture/build-and-test.md`
- Planning and verification artifacts in `specs/`

Workflow artifacts are source archive, two DEBs per target, metadata, release
notes, and SHA-256 manifests; none are committed.

## 15. Error handling

Use `set -euo pipefail`, explicit tag/type/ancestry assertions, OS and libc
checks, required-file assertions, checksum verification, and fail-closed
artifact actions. A published release causes an explicit failure rather than an
asset replacement.

## 16. Security

No untrusted PR or push trigger is added. The only write credential is scoped
to the final draft-release job after validation and artifact verification. The
workflow pins third-party actions and never logs tokens.

## 17. Acceptance criteria

### Scenario SC-e04s01-P0-01: Manual annotated-tag release only

```gherkin
Given package-release.yml and a requested version
When a maintainer dispatches it on a ref
Then it accepts only the matching annotated vVERSION tag on main
And it validates local release metadata before package work
```

### Scenario SC-e04s01-P0-02: Fork package matrix remains buildable

```gherkin
Given the declared Linux Mint and Ubuntu target images
When each target installs its dependencies and invokes the existing package flow
Then GTK2 and GTK3 proof prerequisites are available
And xmms plus libxmms-dev are built, inspected, installed, and smoke-tested
```

### Scenario SC-e04s01-P0-03: Draft assets are integrity checked and least privileged

```gherkin
Given successful package jobs
When release assets are assembled
Then checksums are verified before upload and attachment
And only the final job has contents write permission
And a published release is never modified
```

### Scenario SC-e04s01-P1-01: Maintainer guidance matches the workflow

```gherkin
Given the generic package-release.yml workflow
When a maintainer follows docs/releases.md
Then the guide names the workflow, matching-tag dispatch, targets, artifacts,
and manual draft publication decision
```

## 18. Implementation steps

1. Add the renamed donor workflow and static contract assertions for
   SC-e04s01-P0-01/P0-03 → verify: `tests/test-package-recipes.sh "$PWD"`
2. Adapt branding and GTK3 dependencies while retaining target package behavior
   for SC-e04s01-P0-02 → verify: `tests/test-package-recipes.sh "$PWD" && xvfb-run --auto-servernum make check`
3. Align release/build documentation for SC-e04s01-P1-01 → verify:
   `tests/test-package-recipes.sh "$PWD" && rg -q 'package-release.yml' docs/releases.md`
4. Run complete local delivery gates → verify: `make lint && xvfb-run --auto-servernum make check && xvfb-run --auto-servernum make distcheck`

## 19. Verification script

1. Run `tests/test-package-recipes.sh "$PWD"`.
2. Run `make lint`.
3. Run `xvfb-run --auto-servernum make check`.
4. Run `xvfb-run --auto-servernum make distcheck`.
5. After release preparation, dispatch the workflow from an annotated matching
tag and inspect the draft assets/checksums before manual publication.

## 20. Risks

- External target images or package repositories can drift; pinned images and
  explicit OS/libc checks fail early.
- A tag/ref or token-scope error could affect releases; static contract tests
  and job-level least privilege catch review-time drift.
- Package dependencies can diverge from the enabled GTK3 proof; explicitly
  require `libgtk-3-dev` and preserve package-test execution.
