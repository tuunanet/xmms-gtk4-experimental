# Audit: e05s06 release build-parity timeout repair

**Reviewed range:** `main...HEAD`
**Result:** PASS — release accepted and cutover complete

## Current repair checklist

- [x] Scope is limited to the Linux Mint `v0.0.5` package-job timeout and its
  release evidence. No runtime, ABI, socket, configuration, skin, dependency,
  workflow, or packaging-interface behavior changed.
- [x] The root cause is recorded in
  `BUG-2026-08-15T115821-release-build-parity-timeout.md`: a full isolated
  build had Meson's implicit 30-second test limit, while the failed target
  invocation reached 30.03 seconds.
- [x] The implementation sets only a bounded 120-second test timeout. The
  adjacent suite contract rejects absence of that explicit bound; the existing
  isolated inventory and negative-output checks remain intact.
- [x] F.I.R.S.T: the new assertion is deterministic and self-validating; it
  uses the suite's temporary build directory and adds negligible time. The
  intentionally full build stays serialized and bounded because it validates
  release output parity.
- [x] The v0.0.6 release preparation updates the two release version
  authorities, changelog, and lifecycle contract together; the release checker
  rejects a mismatch.
- [x] `tools/preflight.sh --strict` passed on the prepared v0.0.6 tree: all 34
  tests, Meson distribution, Debian package, lint, and local artifact
  verification succeeded.
- [x] Workflow `31886668793` passed release-tag validation, Linux Mint 22.3
  and Ubuntu 26.04 package jobs, and draft assembly for the exact annotated
  v0.0.6 commit. All 11 checksum entries verified before publication.
- [x] `git diff --check`, secret scan, Conventional Commit history, and
  no-attribution checks passed.
- [x] Security review is current in `specs/security/REVIEW.md`; it finds no
  reportable vulnerability or exception.

## Smells and rationalizations

No Fowler or Clean Code smell is introduced: no function, public interface,
or duplicated branch was added. No gate failure was dismissed; immutable
`v0.0.5` remains unchanged and the explicitly authorized `v0.0.6` release is
published.

## Historical cutover audit

# Audit: e05s06 final Meson cutover

**Reviewed range:** `main...HEAD`
**Result:** PASS — local technical gates
**External release acceptance:** PENDING_RELEASE_PREPARATION (v0.0.2 authorized)

## Checklist

- [x] Scope implements only the approved final removal: legacy build sources,
  generated artifacts, delivery fallbacks, stale current contracts, and their
  Meson replacements.
- [x] The runtime player, plugin ABI, libxmms API, control socket, skins, and
  package names remain unchanged. `xmms-config` remains installed and tested;
  actual Meson-built mpg123 and ALSA modules load from the absolute build root.
- [x] The forbidden-artifact verifier covers Git and extracted source trees,
  rejects every legacy source/test/support class—including configure support,
  autom4te and `.deps` output, libtool `.la`/`.lo`/`.lai`, gettext rule inputs,
  all removed delivery tests, output-like paths, and symlinks—and scans every
  supplied Meson package archive root before Debian build output exists.
- [x] Extracted source packages require the verified `DEB_SOURCE_ARCHIVE`; no
  Autotools fallback, downloader, privilege escalation, or network client was
  introduced.
- [x] `--strict` is accepted by canonical preflight and executes the same
  no-download full gate required by the story.
- [x] Debian packaging retains Meson's debhelper backend and
  `--wrap-mode=nodownload`; build dependencies cover all locally invoked tools.
- [x] Release validation now uses only `meson.build` and `CHANGELOG.md`.
- [x] Current contributor, architecture, package, release, traceability, and
  test-plan records are Meson-only. Delivery status remains pending until its
  tagged acceptance completes; state and verification evidence record that
  v0.0.2 is authorized while post-landing release preparation remains pending.
  The installed xmms-config public compiler,
  linker, data, and plugin-directory queries are source-archive tested.
  Historical manuals/changelogs and the Solaris plugin guide are explicitly
  preserved as historical material.
- [x] Tests are self-validating, use isolated temporary paths with cleanup,
  prove checkout and source-archive behavior through public scripts, and
  prevent ignore rules from masking retired gettext/header outputs.
- [x] `tools/preflight.sh --strict`, `tools/verify-meson-dist.sh`,
  `tools/verify-release-artifacts.sh deb-artifacts`, and
  `tests/verify-preflight-clean-environment.sh` passed with 33 tests after the
  build-tree plugin discovery remediation.
- [x] `git diff --check`, shell syntax checks, Conventional Commit checks, and
  secret-pattern scan passed.
- [x] Renewed independent dual review passed at 98/100 and 100/100 with zero
  must-fix findings after the build-tree plugin remediation
  (`DUAL-REVIEW-1d0557cb25d0.md`).

## Security

No added network fetch, shell evaluation of untrusted input, credential path,
or privilege escalation exists in the final range. Maintainer environment
variables and source-archive paths remain quoted. No reportable HIGH finding
was identified by this audit. The reviewed range is `main...HEAD` so evidence
remains current through its own commit and review-remediation commits.

## Smells and rationalizations

No Fowler smells were detected in the small shell contracts. The nested archive
fixture initially required Git metadata and the source scan initially observed
Debian build output; both were reproduced, test-covered, and fixed. No failing
gate was dismissed as out of scope.

## External acceptance pending

The tagged draft-release workflow is intentionally not dispatched by this audit:
v0.0.2 is authorized, but this cutover must land and a release/0.0.2 branch
must synchronize release metadata before an annotated tag on `main` can create
or resume a GitHub draft release.
