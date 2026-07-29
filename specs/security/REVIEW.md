# Security Review

- Generated: 2026-07-28
- Branch: `plan/gtk4-migration`
- Base: `origin/main`
- Reviewed baseline: `73d8efd`
- Repository: `tuunanet/xmms-gtk4-experimental`
- Scope: GTK4 migration scope, impact analysis, architecture decisions, test design, story specifications, task plans, and lifecycle metadata

## Verdict

PASS — no reportable findings with confidence 8 or higher.

This pull request changes planning documents only. It adds no executable code,
build logic, workflow behavior, package script, runtime dependency, credential,
or user-data path.

## Threat Model for Planned Implementation

The plan identifies the security-sensitive boundaries that later implementation
reviews must trace:

- untrusted skin archives, BMP dimensions, masks, and extracted paths;
- filenames, URIs, playlist drops, chooser results, and displayed metadata;
- asynchronous dialog callbacks that can outlive their owning widgets;
- native X11 surface IDs, XShape buffers, geometry arithmetic, and GLX handles;
- dynamically loaded in-process plugin code and plugin-owned UI lifetimes;
- GTK calls crossing audio, visualization, playlist, or worker-thread boundaries;
- optional plugin build gaps that could escape CI and packaging inspection.

## Assessment

- ADR-0001 confines deprecated/native X11 access to one adapter and requires
  surface-lifetime, backend, capability, XShape, movement, and failure tests.
- ADR-0002 prohibits loading GTK2 and GTK4 in one process and requires dynamic
  dependency inspection throughout the transition.
- Every task touching native X11, asynchronous ownership, file/DnD input, skin
  rendering, plugin UIs, OpenGL, or release packaging is marked for security
  review.
- The test plan requires invalid/destroyed surface handling, parent-destruction
  chooser cases, main-thread checks, optional-plugin classification, installed
  SONAME inspection, and external-style plugin verification.
- Story contracts prohibit fatal handling for recoverable failures, slow I/O
  under playlist locks, UI work outside the main context, and arbitrary native
  XID access.
- No secrets, authentication state, SQL, HTTP endpoints, unsafe deserialization,
  shell execution, or privileged operations are introduced by this diff.

## Findings

None.

## Residual Risks

- The deprecated GTK4 X11 XID accessor is unavoidable under the approved exact
  behavior requirement; feasibility failure blocks implementation.
- Exact window-manager behavior cannot be proven by Xvfb alone, so final release
  requires recorded UAT under a representative stacking X11 window manager.
- Historical optional plugins can evade compilation when dependencies are
  absent; each plugin must be classified as built/tested or unavailable for an
  explicit dependency reason.
- Concrete implementation requires a fresh security review; this planning
  review does not approve future C, build, workflow, or packaging changes.
