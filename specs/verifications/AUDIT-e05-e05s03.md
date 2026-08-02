# Audit: e05s03 Meson parity and distribution

**Reviewed range:** `origin/main...269931c`
**Result:** PASS

## Checklist

- [x] Scope is limited to Meson test registration, staged installation, clean source-distribution verification, and regressions discovered by those gates.
- [x] The Meson graph retains system/pkg-config dependencies and `--wrap-mode=nodownload`; no download, subproject, credential, publication, or network capability was added.
- [x] Install rules preserve the `xmms` runtime binary, `libxmms`, public headers, enabled plugin modules, icon, `xmms-config`, and locale catalogue layout. The staged-install contract verifies them from a temporary DESTDIR.
- [x] The distribution verifier operates in a temporary directory, selects only the archive (not a checksum sidecar), extracts it, and proves configuration, build, Xvfb tests, and staged installation.
- [x] The gettext fix isolates Meson configuration from retained Autotools output. `ENABLE_NLS` is numeric for legacy `#if ENABLE_NLS` consumers, with a retained-header collision regression test.
- [x] Source-mutating contracts are marked non-parallel, eliminating the `xmms/i18n.h` create/remove race without imposing execution ordering on independent tests.
- [x] Full Meson suite passed after final fixes: `xvfb-run --auto-servernum meson test -C build-meson --print-errorlogs` — 25/25.
- [x] Clean archive verification passed after final fixes: `tools/verify-meson-dist.sh` — build, 25/25 Xvfb tests, staged installation, and installed public-header compilation.
- [x] Security review found no unaddressed HIGH-confidence finding. No user-controlled input reaches shell execution; new paths are build-system controlled.
- [x] No plugin ABI, libxmms API, control socket, configuration path, skin format, Debian package name, or release-publication behavior changed.

## Tool availability

The repository has no `scripts/bp-churn-rank.sh`; the optional churn heuristic could not run. This does not replace the complete diff and security review above.

## Fowler smell review

No Mysterious Name, Feature Envy, Data Clumps, Primitive Obsession, Message Chains, Middle Man, dead code, or commented-out code was introduced. Repeated plugin declarations remain declarative Meson target metadata. The distribution and install verifiers each retain one focused responsibility.

## Red flags

None. The unavailable optional churn-ranking tool is explicitly recorded rather than treated as a pass.

## Review disposition

Independent reviewers found and the branch corrected gettext include precedence,
source-test isolation, conditional plugin installation, public-header closure,
Autotools distribution inclusion, locale inventory coverage, and Autotools
`xmms-config` template isolation. The final asserted prefix-override defect was
rejected after direct comparison: both the retained configured Autotools script
and the Meson script retain their configured path for `--plugin-dir` after a
runtime `--prefix` override.

## Reconciliation addendum — 2026-08-02

- The prior reviewed e05s03 implementation is present on `main` as stable
  patch-identical commits, while the recorded branch has a different parent
  history and cannot meet the solo-local ancestry precondition.
- The current tree passes a fresh complete Meson suite (26/26) and clean source
  distribution verification, including build, Xvfb tests, staged installation,
  and installed-header compilation.
- The reconciliation changes only lifecycle and investigation records. No
  runtime, packaging, API, ABI, plugin, socket, or release behavior changed.
- Security review found no reportable finding. The source-mutating distribution
  verifier requires a clean tracked tree, so it is re-run after the metadata
  commit rather than against unstaged documentation.

## Next gate

Land the reconciliation metadata through the solo-local workflow, then remove
only the clean local `feat/meson-parity-distribution` worktree and branch.
