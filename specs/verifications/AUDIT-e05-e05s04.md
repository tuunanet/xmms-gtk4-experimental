# Audit: e05s04 Meson packaging and release artifacts

**Reviewed range:** `45165fb...e7b3d50`
**Result:** PASS

## Checklist

- [x] Scope is limited to Meson Debian packaging, the manual release workflow,
  release-artifact verification, their distribution manifests, and required
  lifecycle evidence.
- [x] The workflow retains manual annotated-tag dispatch, both declared target
  images, per-target and aggregate checksum checks, least-privilege release
  permissions, and draft-only publication.
- [x] The workflow adds system Meson and Ninja packages and calls the shared
  `tools/package-deb.sh`; it does not configure or create archives through
  Autotools.
- [x] The shared helper requests Meson's gzip archive format and selects the
  exact `xmms-VERSION.tar.gz` result, avoiding stale alternative archives.
- [x] Debian metadata, `dpkg-buildpackage`, runtime/development package names,
  public headers, static archive, linker name, macro, icons, manuals, and
  plugin payload remain covered by the package contract.
- [x] The `libxmms` Meson target restores historical ABI SONAME `1` from the
  retained libtool `4:1:3` version-info semantics; output, install, and package
  checks cover the public runtime name.
- [x] The release verifier extracts packages under `mktemp`, smoke-tests the
  extracted binary with a scoped `LD_LIBRARY_PATH`, and checks target and
  aggregate SHA-256 manifests. It does not invoke `sudo`, `apt-get`, or
  `dpkg -i`.
- [x] New package and release tools are source-distributed and registered in
  both retained Autotools and Meson test suites.
- [x] Static release contracts, package payload verification, and a fresh
  Meson package build passed. The source archive ran 28/28 Meson tests before
  Debian assembly.
- [x] Local Preflight passed: `make -j"$(nproc)" && xvfb-run --auto-servernum
  make check`; `make lint` also passed with Cppcheck 2.19.0.
- [x] Security review found no unaddressed HIGH-confidence finding:
  `specs/security/REVIEW-e05s04.md`.
- [x] No plugin ABI, libxmms API, control-socket value, configuration path,
  skin format, package name, target matrix, or draft-only policy changed.

## Tool availability

The repository does not provide `scripts/bp-churn-rank.sh` or ShellCheck. The
full merge-base diff was reviewed in churn-priority order by changed size; POSIX
syntax checks and all project gates passed.

## Fowler smell review

No Mysterious Name, Feature Envy, Data Clumps, Primitive Obsession, Message
Chains, Middle Man, dead code, or commented-out code was introduced. The new
release verifier has one responsibility: validate locally generated release
artifacts without changing the host package database.

## Red flags

None. Missing optional review helpers are recorded rather than treated as a
pass.

## Next gate

Request an independent review of the e05s04 branch diff before release-branch
integration.
