# XMMS Classic — Claude Code

Read `CONVENTIONS.md` before any GitHub or Git operation.
Read `specs/` before planning or implementation.

<!-- BEGIN bigpowers:project -->
## Project

XMMS Classic is a community-maintained preservation fork of XMMS 1.2.11.
Keep the classic audio player usable on modern Linux.

Stack: C, GTK2, GLib2, POSIX threads, GNU Autotools, libtool, Linux, and X11.

## Commands

| Action | Command |
| --- | --- |
| Configure | `./configure --disable-esd` |
| Run | `./xmms/xmms` |
| Test | `xvfb-run --auto-servernum make check` |
| Build | `make -j"$(nproc)"` |
| Lint | Not configured |
| Preflight | `make -j"$(nproc)" && xvfb-run --auto-servernum make check` |
| Strict gate | `xvfb-run --auto-servernum make distcheck` |
| CI | `gh pr checks` when a pull request exists |

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
- Edit Autotools source files, not generated output alone.
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
- MUST deliver every change through a pull request.
- MUST evaluate every new path against workflow triggers, path filters, packaging manifests, release automation, and ignore rules.
- MUST update affected `.github/` workflows when new paths change CI classification or delivery behavior.
- MUST keep Preflight and CI green.
- MUST provide verification evidence before declaring completion.
- MUST write the minimum code that solves the approved scope.
- MUST ask one clarifying question instead of encoding an uncertain assumption.
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

- Use the `team-pr` workflow mode.
- Treat remote `main` as protected.
- Merge every change through a pull request.
- Project-local external-agent wiring is enabled.
<!-- END bigpowers:learned-preferences -->
