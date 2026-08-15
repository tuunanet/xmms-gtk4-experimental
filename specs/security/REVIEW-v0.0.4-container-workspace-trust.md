# Security review: v0.0.4 container workspace trust

**Range:** `0fe8824...b82f90c`
**Scope:** Release-container checkout ownership repair
**Result:** PASS — no reportable findings

## Data flow

`GITHUB_WORKSPACE` is a GitHub Actions runner-provided path. The workflow adds
only that path to Git's safe-directory list after the pinned checkout action
has populated it, then checks that Git can read the repository. The existing
manual version input remains validated against the matching annotated tag on
`main` before package construction.

## Assessment

- **`.github/workflows/package-release.yml:190` — Git trust boundary:** The
  new safe-directory value is a runner-controlled workspace path, not workflow
  input. The static regression contract forbids `safe.directory "*"` and
  requires the trust step before Meson accesses Git metadata.
- **Command injection:** none. The new commands are fixed Git invocations; no
  manual input is interpolated into either command.
- **Authorization:** unchanged. Default workflow permission remains
  `contents: read`; only the existing draft-release job has `contents: write`.
- **Secrets exposure:** none. The diff adds no credential, secret reference,
  logging of secret material, or outbound API call.
- **Supply chain:** unchanged. No action, package source, or runtime dependency
  was added; the existing checkout action remains pinned by commit digest.
- **Misconfiguration:** the repair reduces a release-only ownership failure
  without globally disabling Git's repository-ownership protection.

No HIGH finding with confidence at least 8/10 was identified. No exception is
required.
