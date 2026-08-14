# BUG-2026-08-14T090939: Dirty Meson release archive omits version metadata

**type:** fix
**risk:** P0
**context:** Release preparation and Meson source distribution

## Problem

Preparing an authorized new release version updates the Meson and changelog
version authorities in a dirty release worktree. The canonical preflight then
builds a source archive that retains the committed version instead of the
prepared version. Debian package metadata reports the new version, but the
extracted player reports the old version.

Reproduce:

```sh
tools/check-release-version.sh 0.0.2
tools/preflight.sh --strict
```

Expected: the source archive, package metadata, and extracted player report
`0.0.2`.

Actual: the archive and player report `0.0.1`, and release-artifact smoke
verification fails.

Security impact: LOW. No security exploit path is identified. The defect can
mislabel or block a maintainer-authorized release.

## Root Cause Analysis

### Reproduce

The release-version validator accepted the updated Meson and changelog
metadata. Strict preflight then failed the extracted-package version smoke
check after package metadata declared the new version.

### Isolate

The configured build header contained the new version, while the generated
source archive and a clean build from that archive contained the previously
committed version. After source snapshotting corrected that archive, package
reconfiguration without its source root reset the configured version to the
committed value and again paired it with the new archive.

### Hypothesize

1. Dirty distribution creation uses the committed source revision rather than
   the working-tree metadata.
   Falsification: inspect the archived Meson version after changing it without
   committing.
2. Package reconfiguration without an explicit source root resets the Meson
   version to the committed value.
   Falsification: configure a dirty release version, then reconfigure with and
   without the source root.
3. Debian packaging rewrites the player version independently.
   Falsification: compare the fresh archive build before Debian packaging.

### Verify

The first two falsifications confirmed their hypotheses; the third was
rejected. The configured dirty header was `0.0.3`; before correction the
archive and fresh archive player were `0.0.2`. Source snapshotting produced
`0.0.3`, then a source-less reconfigure reset packaging to `0.0.2`. Supplying
the source root preserved `0.0.3` through archive, package, extracted-player,
and no-Git source preflight verification.

The root cause is a two-step dirty-worktree handoff: preflight created a
committed-source archive, and package reconfiguration omitted the source root
needed to retain the dirty Meson version.

## TDD Fix Plan

1. **RED**: Add a preflight contract test that changes the Meson release
   version in a dirty Git fixture and requires the package source archive and
   extracted player to report that changed version.
   **GREEN**: Make dirty-worktree preflight create a verified Meson source
   snapshot containing the current working tree before package verification,
   and reconfigure package builds with their explicit source root.
   **verify**: `tests/test-preflight.sh "$PWD" && tools/preflight.sh --strict`

2. **RED**: Require the release-artifact smoke contract to compare the
   extracted player's version with the release-version authority for a dirty
   prepared release.
   **GREEN**: Retain the existing extracted-artifact verifier and pass it the
   source snapshot produced by the corrected preflight path.
   **verify**: `tools/check-release-version.sh 0.0.2 && tools/preflight.sh --strict`

**REFACTOR**: Keep a single no-download archive path for clean, dirty, and
extracted sources, with no Autotools fallback.

## Acceptance Criteria

- [x] Dirty release metadata is present in the verified Meson source archive.
- [x] The archive's fresh player build reports the authorized version.
- [x] Debian package metadata and extracted player versions agree.
- [x] Strict preflight and release-artifact verification pass.
- [x] Existing clean and extracted-source preflight coverage remains green.
- [x] Tracked deletions are absent from the snapshot, while dangling symlinks remain representable.
- [x] Unsupported untracked file types fail clearly without blocking snapshot creation.

## Resolution

**Status:** fixed

Preflight snapshots dirty source into a temporary local Git repository before
Meson creates the no-download archive. It omits paths deleted from the working
tree, preserves symlinks (including dangling links), and rejects non-ignored
special files such as FIFOs before build work starts. Package reconfiguration
receives its explicit source root, so Meson retains the snapshot version.

**Evidence:** `tools/check-release-version.sh 0.0.2`,
`tools/preflight.sh --strict`, `tools/verify-meson-dist.sh`,
`tools/package-deb.sh && tools/verify-release-artifacts.sh deb-artifacts`, and
`tests/verify-preflight-clean-environment.sh` all passed.
