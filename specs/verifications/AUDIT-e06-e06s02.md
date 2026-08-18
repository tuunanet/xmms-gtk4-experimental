# Audit: e06s02 directional subsystem dependencies

**Reviewed range:** `main...HEAD`
**Result:** PASS

## Churn-first review

1. `tests/meson.build` — frequently changed test registration; reviewed first.
2. `tests/test-gnome-c-foundations.sh` — managed contract harness; reviewed second.
3. `docs/architecture/gnome-c-foundations.md` — policy source of truth; reviewed third.

## Checklist

- [x] **Correctness:** the contract checks the approved policy, explicit GTK2
  compatibility allowlist, permitted adapter edge, and forbidden cross-layer
  include edges in the fixed managed production set.
- [x] **Scope:** it deliberately excludes the historic source tree, plugin ABI,
  socket, configuration, skin, and production GTK2 paths.
- [x] **Compatibility:** no production source, public API, plugin, socket, or
  configuration contract changed.
- [x] **Security:** fixed path and literal include scans prevent command/text
  evaluation; no credential, dependency, network, or external-input path was
  introduced. Security review has no HIGH finding.
- [x] **F.I.R.S.T:** the focused shell and Meson tests are fast, independent,
  repeatable, and self-validating. Each behavior was committed RED then GREEN.
- [x] **Style and quality:** no broad parser, glob-based scope, duplicated
  policy file, mutable global, or dead code was added; `git diff --check` is
  clean.

## Verification evidence

- Direct `--dependency-contract` check passed.
- `gobject-boundaries` suite passed 3/3 under Xvfb.
- `tools/preflight.sh --strict` passed 36/36, including source distribution,
  Debian packaging, lint, and artifact gates.

## Rationalization check

None. The only unavailable lifecycle helper was the optional red-commit helper
script; each red state was manually run, committed test-only, and shown to fail
before its separate green commit.
