# Audit: v0.0.2 release preparation

**Range:** `ab8d044...b8c4fa7`
**Result:** PASS — ready for independent review

## Checklist

- [x] Scope is limited to authorized `0.0.2` metadata and the discovered P0
  dirty-source release regression.
- [x] The regression is documented in `BUG-2026-08-14T090939`; its test proves
  a dirty version reaches the source archive, Debian package, extracted player,
  and no-Git preflight; tracked deletions are omitted and a FIFO fails clearly.
- [x] No public plugin, socket, configuration, skin, ABI, or package payload
  contract changed.
- [x] Dirty source snapshotting is local, no-download, temporary, and cleaned
  on exit; it preserves symlinks, omits deleted paths, rejects non-ignored
  special files, and package reconfiguration receives an explicit source root.
- [x] No new dependency, network client, secret, `gh` call, REST call, or
  unquoted untrusted shell input was added.
- [x] `tools/check-release-version.sh 0.0.2`, strict preflight, clean Meson
  distribution, default package/artifact verification, and dirty/extracted
  environment proof passed with 33 tests.
- [x] Tests are isolated, self-validating integration checks. The additional
  nested build is deliberate P0 release-integrity coverage.
- [x] `git diff --check` passes; the branch is clean.
- [x] Renewed dual review passed at 96/100 and 97/100 with zero must-fix
  findings after deletion and special-file hardening
  (`DUAL-REVIEW-598093329685.md`).

## Design and smells

The source-snapshot functions have cohesive responsibilities: validate special
entries, then materialize current local source as a normal Meson archive. The
embedded Python uses file APIs to preserve symlinks and modes without
shell-evaluating paths. No Fowler smell requiring refactoring was found. The
temporary snapshot is necessary because Meson distribution archives are
VCS-based.

## Security

See `specs/security/REVIEW-v0.0.2-release-preparation.md`. No HIGH finding was
identified.

## Rationalizations checked

None. The release-blocking preflight failure was investigated, regression-
tested, and fixed rather than bypassed or deferred.
