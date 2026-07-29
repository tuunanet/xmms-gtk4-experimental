# Test Design: e04 release-packaging workflow

## Risk matrix

| Scenario ID | Behavior | Risk | Test level | Evidence |
| --- | --- | --- | --- | --- |
| SC-e04s01-P0-01 | The generically named workflow is manual-only, requires a version input, and rejects a ref that is not its matching annotated `vVERSION` tag. | P0 | Static workflow contract | `tests/test-package-recipes.sh` |
| SC-e04s01-P0-02 | Both donor targets install the full GTK2/GTK3 package toolchain, build from a source archive, run the existing Debian package tests, inspect metadata, and install-smoke-test `xmms` plus `libxmms-dev`. | P0 | Static workflow contract + local package contracts | `tests/test-package-recipes.sh`, `make check` |
| SC-e04s01-P0-03 | Artifact checksums are verified before a least-privilege release job creates or resumes a draft; the workflow rejects published release mutation. | P0 | Static workflow contract | `tests/test-package-recipes.sh` |
| SC-e04s01-P1-01 | Maintainer documentation names the generic workflow, explains matching-tag dispatch, declared targets, and draft-only publication. | P1 | Documentation contract | `tests/test-package-recipes.sh` |

## Fixtures and isolation

- Static shell assertions inspect checked-in workflow text; local tests never require a GitHub token, a tag, containers, or network release mutation.
- Existing release-helper fixtures remain responsible for malformed version and changelog failure paths.
- GitHub-hosted execution is the integration environment for the externally hosted target images and draft-release API; it is invoked only by an explicit maintainer dispatch.

## NFR evidence

| Dimension | Requirement | Verification |
| --- | --- | --- |
| Security | Default token is read-only; only the draft-release job receives `contents: write`; published releases are immutable. | `tests/test-package-recipes.sh "$PWD"` |
| Reliability | Every package target checks OS identity, architecture, expected libc, package metadata, package installation, and checksums. | `tests/test-package-recipes.sh "$PWD"` |
| Operability | Workflow name is distribution-neutral and the release guide gives exact dispatch/review steps. | `tests/test-package-recipes.sh "$PWD"` |
| Regression | Existing local build, test, lint, source-distribution, and package contracts stay green. | `make lint && xvfb-run --auto-servernum make check && xvfb-run --auto-servernum make distcheck` |

## Manual acceptance

1. Prepare and push an annotated `vVERSION` tag from `main` only after normal release review.
2. In GitHub Actions, select **Linux packages and release**, choose that tag, and supply the matching version.
3. Confirm validation, both target package jobs, and draft-release assembly succeed.
4. Download the draft assets and verify their recorded checksums before deciding whether to publish.

## Out of scope

- Push/pull-request CI, Dependabot, templates, automatic publication, release-tag creation, and package targets outside Linux Mint 22.3 and Ubuntu 26.04.
