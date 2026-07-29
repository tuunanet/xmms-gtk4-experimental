# Security review: e04 release-packaging workflow

- **Reviewed range:** `58c4f24...0ca0faa`
- **Result:** PASS
- **Unresolved HIGH findings (confidence >= 8):** 0

## Trust and data-flow assessment

- The workflow has only a manual `workflow_dispatch` trigger. It does not run
  on pull requests, pushes, or untrusted fork input.
- The maintainer-provided version is quoted at shell boundaries and validated by
  `tools/check-release-version.sh` before it names package or release assets.
- The workflow additionally requires the matching annotated `vVERSION` tag,
  validates that tag's target against `GITHUB_SHA`, and requires main ancestry.
- Default token permission is `contents: read`; only the final job receives
  `contents: write` to create or update an unpublished draft release.
- A pre-existing published release is rejected. Artifact manifests are checked
  before upload and again before draft-release attachment.
- Third-party actions are pinned to reviewed commit SHAs. Build dependencies are
  system packages installed within isolated target containers.

## Findings

No reportable injection, authorization bypass, secret exposure, unsafe
artifact handling, path traversal, or published-release mutation finding was
identified at confidence 8 or higher. `gh release upload --clobber` is limited
to an already-confirmed draft release; it is required to resume a failed draft
run and is guarded by the published-release rejection.
