# e05s04 dual-review response: round 3

**Reviewed target:** `8d584b7`
**AND-gate result:** FAIL — Reviewer A reported one source-archive must-fix

## Resolution

| Finding | Disposition | Evidence |
| --- | --- | --- |
| `meson dist` requires VCS metadata, blocking `make deb` from a retained source archive | Fixed | `514f6ee`, `cf43b14`; a fresh configured Autotools archive without `.git` now builds and verifies both Meson Debian packages. |
| Archive regression hard-codes `0.0.1` | Fixed | `cf43b14`; tests derive the Meson project version before locating/extracting archives. |
| Debian package test phase lacks `tools/verify-build-parity.sh` in the retained archive | Fixed | `cf43b14`; it is declared in the root Meson distribution manifest and verified by the archive/package integration test. |

## Verification

- `tools/package-deb.sh` and selected-build-directory artifact verification passed from the VCS checkout.
- `tests/test-autotools-package-deb.sh "$PWD"` built from a fresh retained
  archive with no VCS metadata and passed the Debian payload/SONAME contract.
- `xvfb-run --auto-servernum meson test -C build-meson --print-errorlogs`
  passed 30/30.
- `make -j"$(nproc)" && xvfb-run --auto-servernum make check` and `make lint`
  passed.

The next required gate is a fresh dual-blind review of the updated branch.
