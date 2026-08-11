# Audit: e05s05 Meson preflight contract

**Reviewed range:** `main...166be7f`
**Result:** PASS

## Checklist

- [x] Scope is limited to the approved Meson preflight, its tests, source
  manifests, and operational documentation.
- [x] No plugin ABI, libxmms API, socket, skin, runtime, or packaging interface
  changed.
- [x] New shell paths are quoted, fail fast, avoid downloads and privilege
  escalation, and use only trusted script-derived paths, maintainer settings,
  or a checked explicit source-archive path.
- [x] No secrets, remote network client, direct GitHub API, or unapproved
  dependency was added.
- [x] `tools/preflight.sh` has one responsibility: orchestrate the documented
  gates. Its test scripts isolate contract, missing-tool, and clean-checkout
  behavior.
- [x] The discovered dirty-worktree packaging defect was logged, fixed, and
  guarded by the explicit source-archive handoff test.
- [x] Tests are self-validating, independently create temporary directories,
  clean them with traps, and exercise the public command rather than internals.
- [x] Shell syntax and whitespace checks pass.
- [x] Full clean-checkout preflight completed build, Xvfb test, lint, package,
  and Meson distribution gates from both a tracked-dirty Git checkout and an
  extracted source archive without Git metadata.
- [x] Required Meson, Ninja, Git (for a Git checkout), Xvfb, xauth, and Python
  tools fail fast with actionable system-package messages before build work
  starts.
- [x] A custom `DEB_OUTPUT_DIR` controls package creation and verification
  without leaving default package artifacts.
- [x] Both the outer preflight and Debian's inner Meson configure enforce
  `--wrap-mode=nodownload`; package Build-Depends cover Git, xauth, and
  lintian used by package tests.
- [x] Retained source-distribution manifests include every input required by
  the Meson documentation contract without duplicate entries.
- [x] `scripts/land-branch.sh` fails closed when the executable canonical
  `tools/preflight.sh` is absent, and otherwise always routes through it.
- [x] Security review reports no unresolved HIGH finding.

## Review notes

The new preflight shell script is intentionally linear orchestration rather
than an abstraction layer; splitting its ordered gates would obscure the public
contract. No Fowler smells were detected: no Mysterious Name, Duplicated Code,
Feature Envy, Data Clumps, Primitive Obsession, Message Chains, or Middle Man.

## Rationalizations caught

None. Earlier trailing-whitespace, ignored-artifact, package-output, and
source-archive review findings were corrected and verified.

## Next gate

Run the required dual-blind review of the refreshed final range before release
integration.
