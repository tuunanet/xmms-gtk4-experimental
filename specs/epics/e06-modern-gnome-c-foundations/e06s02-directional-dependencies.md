# e06s02: Enforce directional subsystem dependencies

**type:** architecture
**risk:** P1
**depends on:** e05, e06s01

## Context

The staged UI migration needs boundaries that prevent rendering, storage, and
source code from acquiring reverse dependencies through convenience globals or
public-header leakage.

## Requirements

#### ADDED: Dependency-direction contract

Document and validate the allowed directions among UI, domain, storage,
rendering, and source/plugin dependencies. New modules must depend only toward
stable lower-level contracts; dependencies that cross a layer require an
explicit facade or ADR.

#### ADDED: Boundary verification

Add a focused, source-level verification that rejects new prohibited dependency
edges while allowing documented historical compatibility paths unchanged.

## Acceptance criteria

- Given a new UI module, when it needs player state, then it depends on a
  domain-facing contract rather than storage or renderer internals.
- Given a rendering or storage module, when it is compiled, then it does not
  acquire a reverse dependency on a UI module.
- Given a documented historical compatibility edge, when boundary verification
  runs, then it is retained only as an explicit allowlist entry.

## Out of scope

Re-layering every existing source file, changing plugin loading behavior, or
removing established global state without a behavior-preserving migration plan.
