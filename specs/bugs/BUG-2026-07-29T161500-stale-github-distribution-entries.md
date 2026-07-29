---
bug_id: BUG-2026-07-29T161500
status: open
severity: high
scope: source-distribution
title: Remove stale GitHub metadata distribution entries
---

# BUG-2026-07-29T161500: Remove stale GitHub metadata distribution entries

## Problem

`make distcheck` cannot create the source archive because `EXTRA_DIST` names five GitHub metadata files that are not present in the flattened repository.

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

Run `xvfb-run --auto-servernum make distcheck`; archive assembly stops at the first missing `.github` path.

### Isolate

A complete inventory of `EXTRA_DIST` finds exactly five absent files, all under the missing GitHub metadata tree.

### Hypothesize

1. The files are generated during release assembly. Falsification: no generation rules or source templates exist.
2. Distribution metadata retained entries for files excluded from the flattened repository. Falsification: remove the absent entries and re-run archive assembly.

### Verify

The files are absent from tracked and working-tree content and have no producers. The verified root cause is stale authoritative and shipped distribution metadata.

Risk level: Low.

## TDD Fix Plan

1. **RED**: Run distcheck and observe archive assembly fail on a missing GitHub metadata path.
   **GREEN**: Remove the five absent paths from authoritative and shipped `EXTRA_DIST` lists.
   **verify**: `python3 - <<'PY'
from pathlib import Path
text=Path("Makefile.am").read_text()
block=text.split("EXTRA_DIST = \\\n",1)[1].split("\n\nm4datadir",1)[0]
assert all(Path(line.strip().removesuffix(" \\")).exists() for line in block.splitlines() if line.strip())
PY`

2. **RED**: Re-run source-distribution verification.
   **GREEN**: Make no further changes unless another declared distribution input is absent.
   **verify**: `xvfb-run --auto-servernum make distcheck`

## Acceptance Criteria

- [ ] Every declared `EXTRA_DIST` path exists.
- [ ] Authoritative and shipped Automake metadata agree.
- [ ] Distcheck passes.

## Resolution

Removed the five absent GitHub metadata paths from authoritative and shipped source-distribution lists. Every remaining declared input exists and `make distcheck` completes successfully for `xmms-0.0.1.tar.gz`.
