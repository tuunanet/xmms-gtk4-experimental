# XMMS GTK4 Experimental — Claude Code

Read `CONVENTIONS.md` before any GitHub or Git operation.
Read `specs/` before planning or implementation.

<!-- BEGIN bigpowers:project -->
## Project

XMMS GTK4 Experimental is a community-maintained preservation fork of XMMS 1.2.11.
Keep the classic audio player usable on modern Linux.

Stack: C, GTK2, GLib2, POSIX threads, Meson, Ninja, Linux, and X11.

## Commands

| Action | Command |
| --- | --- |
| Configure | `meson setup build-meson --wrap-mode=nodownload` |
| Run | `build-meson/xmms/xmms` |
| Test | `xvfb-run --auto-servernum meson test -C build-meson` |
| Build | `meson compile -C build-meson` |
| Lint | `tools/run-c-lint.sh` |
| Preflight | `tools/preflight.sh` |
| Strict gate | `tools/preflight.sh` |
| Integrate | `release-branch` → `bash scripts/land-branch.sh <branch> "<message>"` |
| CI | No push/PR build workflow is tracked; the manual `.github/workflows/package-release.yml` workflow is used only for tagged release packaging. |

## Architecture

The GTK application in `xmms/` coordinates playlist, UI, configuration, and plugin lifecycle.
Input plugins decode audio into Output plugins.
Enabled Effect plugins transform PCM.
Visualization plugins consume a timed side-channel.
`libxmms` exposes Unix-socket remote control.

Read `specs/tech-architecture/tech-stack.md` for the complete architecture map.
Read `docs/architecture/` for subsystem diagrams and maintainer guidance.

## Conventions

- Preserve public plugin, socket, configuration, and skin contracts.
- Use subsystem-prefixed `snake_case` C names.
- Follow nearby GLib ownership and error patterns.
- Keep GTK operations on the main thread.
- NEVER hold playlist locks across slow I/O.
- Add focused `g_test` regression tests for behavior changes.
- Edit Meson source definitions; do not commit generated build output.
- Use Conventional Commits.

## Never

- NEVER break the plugin ABI or `libxmms` API unintentionally.
- NEVER renumber existing control-socket commands.
- NEVER replace core technologies without an approved migration plan.
- NEVER commit binaries, package artifacts, or Repomix output.
- NEVER perform GTK work from worker threads.
- NEVER use fatal `g_error` for recoverable failures.
- NEVER edit historical codec code without explicit task scope.
- NEVER ignore reproducible test or CI failures.

## Agent Rules

- MUST route work through the appropriate bigpowers skill.
- MUST use `survey-context` when project state is unclear.
- MUST plan feature work in `specs/` before implementation.
- MUST use `develop-tdd` or `execute-plan` for implementation.
- MUST use `investigate-bug` before fixing reported defects.
- MUST start implementation through `kickoff-branch`.
- MUST follow `specs/WORKFLOW-solo-git.md` for integration.
- MUST integrate through `release-branch` in `solo-local` mode.
- MUST let `scripts/land-branch.sh` make the only task commit on `main`.
- MUST evaluate every new path against workflow triggers, path filters, packaging manifests, release automation, and ignore rules.
- MUST update affected `.github/` workflows when new paths change CI classification or delivery behavior.
- MUST keep Preflight and CI green.
- MUST provide verification evidence before declaring completion.
- MUST write the minimum code that solves the approved scope.
- MUST ask one clarifying question instead of encoding an uncertain assumption.

## Autonomous Epic Execution

- The maintainer authorizes autonomous execution for every approved story in
the active epic. MUST continue through every approved story in the active epic
until it is complete or reaches a declared terminal state.
- MUST use `specs/workflows/autonomous-epic.yaml` and invoke `build-epic` or
`execute-plan` in autonomous mode. MUST NOT request routine confirmation after a green task, story, or gate.
- MUST investigate and repair a reproducible failure within approved scope, then
resume the active epic without a checkpoint.
- Human feedback is required only for an unresolved scope or ambiguity,
destructive operation, credentials or sensitive data, immutable tag or release
authorization, or an external blocker after bounded retries are exhausted.
<!-- END bigpowers:project -->

<!-- BEGIN bigpowers:context-routing -->
## Context Routing

| Path | Read first |
| --- | --- |
| `xmms/**` | `docs/architecture/ui-interaction.md`, then the relevant subsystem document |
| `Input/**`, `Output/**`, `Effect/**`, `Visualization/**` | `docs/architecture/processing-pipeline.md`, `docs/architecture/plugin-system.md` |
| `General/**`, `libxmms/xmmsctrl*`, `xmms/controlsocket*` | `docs/architecture/external-control.md` |
| `xmms/playlist*`, streaming code | `docs/architecture/playlist-and-streaming.md` |
| Build, tests, CI, packaging | `docs/architecture/build-and-test.md`, `CONTRIBUTING.md` |
| New files or directories | `.github/workflows/`, packaging manifests, release tooling, `.gitignore` |
| Planning and lifecycle state | `specs/README.md`, `specs/state.yaml` |
<!-- END bigpowers:context-routing -->

<!-- BEGIN bigpowers:learned-preferences -->
## Learned User Preferences

- Use Conventional Commits.

## Workspace Facts

- Use the `solo-git` workflow mode.
- Treat local and remote `main` as protected.
- Land verified work with `scripts/land-branch.sh`.
- Select a pull request explicitly when remote protection requires one.
- Project-local external-agent wiring is disabled.
<!-- END bigpowers:learned-preferences -->
