# Security review: v0.0.2 release preparation

**Range:** `ab8d044...b8c4fa7`
**Scope:** Dirty-source Meson snapshotting and package reconfiguration
**Result:** PASS — no reportable findings

## Data flow

`tools/preflight.sh` reads the developer-controlled Git working tree, rejects
non-ignored special files before build work, and copies tracked plus non-ignored
regular files/symlinks into a `mktemp` directory. Deleted tracked paths are
omitted and dangling symlinks are preserved. It initializes a local Git
repository only in that temporary directory, creates a Meson source archive
without downloads, then passes that archive to the existing package helper.
`tools/package-deb.sh` reconfigures only the selected local source root.

No network client, user-supplied command evaluation, credential handling, or
new privilege boundary is introduced. Temporary paths come from `mktemp`; file
names come from Git's local index and are copied as data, not evaluated by a
shell.

## Assessment

- **Command injection:** none. Fixed commands receive quoted local paths; the
  embedded Python process uses file APIs rather than shell interpolation.
- **Path traversal:** no external input crosses a trust boundary. Git-indexed
  paths are local developer-controlled repository entries.
- **Secrets exposure:** no secret source, logging, or new dependency exists.
- **Archive integrity:** the snapshot is committed locally before Meson creates
  the archive, so package metadata and source contents share one version;
  deletion and special-file behavior are regression-tested.
- **Residual risk:** LOW operational cost from an extra temporary Meson setup
  on dirty worktrees. Cleanup runs on normal exit and signals.

No HIGH finding with confidence at least 8/10 was identified.
