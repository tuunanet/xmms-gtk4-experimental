# Contributing to XMMS GTK4 Experimental

Thank you for helping preserve XMMS. Changes should keep the classic XMMS
experience intact while improving compatibility, reliability, security, or
maintainability on current systems.

## Before starting

- Search [existing issues](https://github.com/tuunanet/xmms-gtk4-experimental/issues).
- For a substantial behavior change, open an issue before writing code.
- Keep each change focused; avoid mixing formatting, refactoring, and behavior
  changes. Apply the same rule when a pull request is required.

## Build and test

Install the complete canonical preflight environment on Debian-family systems:

```sh
sudo apt install build-essential git pkg-config gettext libasound2-dev libgl-dev \
  libgtk2.0-dev libgtk-3-dev libmikmod-dev libsm-dev libvorbis-dev \
  libxxf86vm-dev zlib1g-dev meson ninja-build python3 cppcheck xvfb xauth \
  dpkg-dev debhelper lintian binutils tar
```

The package gate uses every dependency above. OpenGL, Vorbis, and MikMod are
optional only for an iterative Meson build that explicitly disables their
features. See the [README](README.md#requirements) for details.

Run the canonical preflight from the repository root:

```sh
tools/preflight.sh
```

The command configures an isolated no-download Meson build, compiles XMMS,
runs Xvfb-backed tests and plugin checks, runs Cppcheck, builds and verifies
Debian packages, and verifies the Meson source distribution. It never installs
tools, downloads dependencies, or elevates privileges. It runs from a dirty
worktree and verifies a local snapshot of the current working source; install
every prerequisite as a system package first. From an extracted source archive
without `.git`, pass its original archive as
`DEB_SOURCE_ARCHIVE=/path/to/xmms-VERSION.tar.gz tools/preflight.sh`.

If a change affects UI or audio behavior, record the manual runtime testing in
its verification evidence and in the pull request when one is used.

## C static analysis

Install Cppcheck as a system package, then run the same regression gate used
by canonical preflight:

```sh
tools/run-c-lint.sh
```

Ubuntu 24.04's packaged Cppcheck is the authoritative CI environment. The gate
analyzes maintained C sources and headers from the Meson build tree. It enables defect-oriented warning, performance, and portability
checks rather than style-only diagnostics.

Fix new findings whenever practical. If a finding is confirmed as existing,
intentional, or a false positive, add only a narrow
`diagnostic-id:path:line` entry to the suppression baseline at
`tools/cppcheck-suppressions.txt`, explain it in the review evidence or pull
request, and rerun `tools/run-c-lint.sh`. Do not add project-wide diagnostic suppressions
or refresh the baseline merely to make CI green. Baseline changes must receive
the same review as source changes.

The repository currently tracks no push- or pull-request build workflow and no
path classifier. Run `tools/preflight.sh` locally before integration. The only
tracked GitHub Actions workflow, `.github/workflows/package-release.yml`, is a
manual release-packaging workflow described in [docs/releases.md](docs/releases.md).

## Local dual-agent review

Maintainers using Pi can run the project-local dual-blind review gate before
integration. Start Pi from a trusted checkout; Pi installs the exact package
version declared in `.pi/settings.json` into the ignored `.pi/npm/` cache.
Review the package source before approving a new version.

After `audit-code` passes, invoke:

```text
/dual-review
```

Pi asks for explicit approval before running the repository-controlled
`xmms-reviewer-a` and `xmms-reviewer-b` roles. The prompt starts both isolated
reviewers in parallel with identical briefs and passes only when both report
zero must-fix findings and scores of at least 94. Do not enable unconfirmed
project agents or commit package caches, credentials, sessions, or reports.

The static wiring contract runs through `tools/preflight.sh`. Model-backed review stays
local and interactive; CI does not receive model credentials.

## Project conventions

- Follow the style of the surrounding C code; do not reformat unrelated lines.
- Add a regression test for bug fixes when practical.
- Treat compiler and Cppcheck warnings as defects. Do not silence a diagnostic
  without explaining why it is safe.
- Add user-visible changes to the `Unreleased` section of
  [`CHANGELOG.md`](CHANGELOG.md).
- Update documentation in the same change as the behavior it describes.
- Use focused commit messages such as `fix: restore playback after ALSA seek`.

## Meson build definitions

Meson is the sole build and delivery toolchain. Modify `meson.build`,
`meson_options.txt`, or the relevant subdirectory `meson.build` source
definition, then verify the change with `tools/preflight.sh`.

Do not commit generated build output, source archives, package artifacts, or
Meson wrap downloads.

## Releases

Merges to `main` are not automatically published. Maintainers collect changes,
build manually tested candidates from short-lived `release/*` branches, and
publish official releases from annotated version tags. See the
[release process](docs/releases.md) for the complete checklist.

## Maintainer integration

Maintainers use the [Solo Git workflow](specs/WORKFLOW-solo-git.md) by default.
Develop in an isolated worktree, pass the verification and audit gates, and
commit the reviewed changes. Then use `release-branch` in `solo-local` mode.
Land only through:

```sh
bash scripts/land-branch.sh <branch> "<conventional-message>"
```

Use a pull request explicitly for external contributions or when remote branch
protection requires one. The land command never opens a pull request itself.

## Pull requests

An external or explicitly selected pull request should explain:

- what problem it solves;
- why the chosen approach fits this preservation-focused fork;
- how it was tested; and
- any compatibility or packaging impact.

By contributing, you agree that your contribution is provided under the
project's [GPL-2.0-or-later license](COPYING).
