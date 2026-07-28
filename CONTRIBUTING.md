# Contributing to XMMS Classic

Thank you for helping preserve XMMS. Changes should keep the classic XMMS
experience intact while improving compatibility, reliability, security, or
maintainability on current systems.

## Before starting

- Search [existing issues](https://github.com/tuunanet/xmms-classic/issues).
- For a substantial behavior change, open an issue before writing code.
- Keep pull requests focused; avoid mixing formatting, refactoring, and behavior
  changes.

## Build and test

Install a C toolchain, `pkg-config`, GTK2/GLib2 development packages, and zlib.
ALSA, OpenGL, Vorbis, and MikMod development packages enable their respective
plugins. See the [README](README.md#requirements) for details.

```sh
./configure --disable-esd
make -j"$(nproc)"
make check
```

`make check` runs the regression tests. The file-browser tests require an X11
display; in a headless environment, run them through Xvfb:

```sh
xvfb-run --auto-servernum make check
```

On Ubuntu 24.04 or a compatible Debian build environment, build the same
runtime and development packages checked by CI with:

```sh
make deb
```

This creates `deb-artifacts/*.deb`, runs the package test suite, and checks the
packaged MP3 plugin linkage. It never installs dependencies or elevates
privileges; required build dependencies must already be installed.

If a change affects UI or audio behavior, also describe the manual runtime
testing performed in the pull request.

Pull requests that only touch documentation and other non-build metadata still
report the required `build-and-test` check, but CI skips the full configure,
build, test, distcheck, and Debian package steps. Skipped paths currently
include `docs/**`, top-level prose (`README.md`, `CHANGELOG.md`,
`CONTRIBUTING.md`, `CONTRIBUTORS.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`,
`COPYING`, `ABOUT-NLS`), editor/VCS metadata (`.gitignore`, `.gitattributes`,
`.editorconfig`), and GitHub issue/PR templates under `.github/` (workflow
YAML is **not** skipped). Any other path keeps the full suite.

Pushing new commits while a run is in progress cancels the previous run on the
same ref (`cancel-in-progress`). The cancelled run’s required gate fails with
`cancelled`; that is expected—only the latest commit’s checks matter for merge.

## Project conventions

- Follow the style of the surrounding C code; do not reformat unrelated lines.
- Add a regression test for bug fixes when practical.
- Treat compiler warnings as defects. Do not silence a warning without
  explaining why it is safe.
- Add user-visible changes to the `Unreleased` section of
  [`CHANGELOG.md`](CHANGELOG.md).
- Update documentation in the same pull request as the behavior it describes.
- Use focused commit messages such as `fix: restore playback after ALSA seek`.

## Autotools files

This repository ships generated Autotools files so users can build directly
from a checkout without bootstrapping old macro dependencies. The build system
predates current Autoconf and Automake releases and cannot yet be regenerated
unchanged by a modern `autoreconf`.

When modifying build metadata:

- update the authoritative `.am` or `.in` source;
- update its shipped generated counterpart in the same pull request; and
- verify both a clean `./configure && make` build and `make distcheck`.

Do not run `autoreconf --force --install` and commit its broad generated diff
unless the pull request is specifically migrating the Autotools stack.

## Releases

Merges to `main` are not automatically published. Maintainers collect changes,
build manually tested candidates from short-lived `release/*` branches, and
publish official releases from annotated version tags. See the
[release process](docs/releases.md) for the complete checklist.

## Pull requests

A pull request should explain:

- what problem it solves;
- why the chosen approach fits this preservation-focused fork;
- how it was tested; and
- any compatibility or packaging impact.

By contributing, you agree that your contribution is provided under the
project's [GPL-2.0-or-later license](COPYING).
