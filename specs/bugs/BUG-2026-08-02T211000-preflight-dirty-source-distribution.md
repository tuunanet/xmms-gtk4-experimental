---
bug_id: BUG-2026-08-02T211000
status: fixed
severity: high
scope: meson-preflight
title: Canonical preflight rejects ordinary dirty worktrees
---

# BUG-2026-08-02T211000: Canonical preflight rejects ordinary dirty worktrees

## Problem

`tools/preflight.sh` configures, compiles, and tests the project, but then
fails at its Meson source-distribution gate whenever the contributor has
uncommitted work. A developer must be able to run the documented preflight on
the changes they are about to verify.

**Security impact: NONE.** The failure is local and introduces no exploit path.

## Root Cause Analysis

### Reproduce

Run `tools/preflight.sh` from a worktree with uncommitted changes. Meson rejects
the final source-distribution command because it excludes uncommitted content.

### Isolate

The build, test, and lint gates complete. The final wrapper distribution call
and the VCS path inside the package helper both invoke Meson distribution.
Both reject the ordinary dirty worktree the preflight is intended to verify.

### Hypothesize

Meson's default distribution policy intentionally rejects a dirty repository.
The wrapper must create one explicit dirty-worktree source archive, then pass
that archive to the existing package helper instead of allowing the helper to
create a second VCS-bound archive.

### Verify

`meson dist --help` documents `--allow-dirty`; the observed failure requests
that option. After the wrapper's final distribution call received that option,
the package helper reproduced the same failure through its own VCS path. This
confirms that the wrapper must supply its archive to the package gate.

## TDD Fix Plan

1. **RED:** Extend the preflight contract test to require an explicit
   generated source archive for package verification.
   **GREEN:** Create one Meson dirty-worktree archive and pass it to the
   existing package helper.
   **verify:** `tests/test-preflight.sh "$PWD" && tools/preflight.sh`

## Acceptance Criteria

- [x] Preflight completes its package and distribution gates from a dirty worktree.
- [x] The source-distribution gate remains a Meson no-download build.
- [x] Missing Meson and Ninja still produce actionable system-package errors.
- [x] The full preflight passes.

## Resolution

**Fixed:** 2026-08-02
**Root cause confirmed:** Package verification attempted a second VCS-bound
Meson distribution after preflight had created its source archive.
**Fix applied:** Preflight creates one `--allow-dirty` Meson archive and passes
it through the existing explicit archive interface to package verification.
**Hardening added:** `tests/test-preflight.sh` requires the explicit archive
handoff and the dirty-worktree distribution mode.
**Evidence:** `tools/preflight.sh` passed from the dirty task worktree.
**Commit:** `fix(preflight): package the verified source archive`
