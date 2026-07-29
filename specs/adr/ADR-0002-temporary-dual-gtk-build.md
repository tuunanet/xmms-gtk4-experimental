# ADR-0002: Use temporary separate GTK2 and GTK4 build configurations

- Status: Accepted for planning
- Date: 2026-07-28
- Initiative: Direct GTK2-to-GTK4 migration

## Context

The migration must be delivered through multiple pull requests while `main`
remains buildable and releasable. GTK2 and GTK4 cannot safely coexist in one
XMMS process, and a long-lived integration branch would delay full CI and
compatibility feedback until the final merge.

## Decision

During the migration, support two separate configure/build modes:

- the existing GTK2 application remains the release/default path until the
  GTK4 path reaches parity;
- an explicitly selected experimental GTK4 build compiles and runs as a
  separate executable/process using only GTK4;
- shared GTK-neutral behavior and contracts are exercised in both modes;
- no binary links both GTK2 and GTK4;
- the final cutover removes the GTK2 mode, transitional conditionals, packages,
  tests, documentation, and CI jobs.

The exact configure option and executable naming are implementation details to
be finalized in story planning, but selection must be deterministic and
visible in build logs.

## Reason for Depth

A temporary dual-build seam is necessary to land independently reviewable
migration slices without making the protected main branch unreleasable or
mixing incompatible GTK major versions in one process.

## Consequences

- CI temporarily builds and tests both modes on Ubuntu 26.04.
- Migration abstractions must have explicit deletion criteria to prevent a
  permanent compatibility layer.
- Every migration PR must prove the GTK2 release path remains green and the
  GTK4 surface it claims is functional.
- Shared libraries and bundled plugins are built for exactly one selected GTK
  major per build tree; build outputs must not cross-contaminate.
- The final GTK4-only story is blocked until behavior parity, plugin ABI,
  packaging, and dynamic dependency gates pass.

## Alternatives considered

### Dedicated GTK4 integration branch

Rejected. It would permit incomplete intermediate states but defer normal main
branch integration, packaging, and release feedback.

### One cutover pull request

Rejected. The 121-file blast radius is too large for safe review and isolated
regression diagnosis.

### Load GTK2 and GTK4 in one process

Rejected. Shared symbol and type registries make this unsafe, and it conflicts
with complete GTK2 removal.

## Removal criteria

The temporary GTK2 mode and migration scaffolding must be deleted when:

1. all core windows, dialogs, helpers, and bundled plugin UIs pass GTK4 tests;
2. plugin ABI snapshots pass unchanged;
3. classic X11 and skin UAT passes;
4. GTK4 build, distcheck, Debian packaging, install, and smoke tests are green;
5. no project binary in the GTK4 build depends on a GTK2/GDK2 SONAME.
