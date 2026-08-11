# XMMS GTK4 Experimental

> A community-maintained preservation fork of XMMS 1.2.11, keeping the classic
> player usable on modern Linux systems.

![License](https://img.shields.io/badge/license-GPL--2.0--or--later-blue)
![Language](https://img.shields.io/badge/language-C-555555)
![Toolkit](https://img.shields.io/badge/toolkit-GTK2%20%E2%86%92%20GTK4-729fcf)
![Platform](https://img.shields.io/badge/platform-Linux-4c9e2f)

![The classic XMMS interface](docs/images/xmms.png)

*The classic XMMS interface. Screenshot by
[ShadowDragon](https://en.wikipedia.org/wiki/User:ShadowDragon), licensed under
[GPL-2.0-or-later](docs/images/README.md), via
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:XMMS_(1).png).*

---

## About

XMMS (X Multimedia System) is a lightweight, skinnable audio player with a
plugin architecture for input, output, effect, general, and visualization
plugins. It supports MP3, Ogg Vorbis, WAV, module formats (MOD, XM, S3M, IT and
others via libmikmod), CD audio, and HTTP/Icecast/Shoutcast streaming.

XMMS GTK4 Experimental is based on the last upstream release, **XMMS 1.2.11**.
Its target is a GTK4-based player, reached through a deliberate **GTK2 → GTK3
→ GTK4** migration that preserves classic behavior and compatibility.

The production player currently uses GTK2 / GLib2. A separately linked GTK3
Play-button proof establishes the first migration seam; GTK4 is not yet the
production UI. The `xmms` executable, source-package name, configuration
paths, and plugin interfaces retain their historical identifiers.

---

## Project lineage and credits

This is **not** the original XMMS project. Upstream development ended with the
1.2.11 release in 2007, and the original `xmms.org` website is no longer
online. The current fork maintainers resumed active maintenance in 2026.

Repository history falls into three periods:

1. The original XMMS authors and contributors developed XMMS from 1997 to 2007.
2. Oleg Pudeyev imported XMMS 1.2.11 into Git in 2015 and created the initial
   GTK2 / GLib2 port preserved in this repository's history.
3. Current fork maintenance continues from 2026, focusing on compatibility and
   preservation alongside other independent XMMS forks and related projects.

Current maintenance priorities include:

- Advancing the staged GTK2 → GTK3 → GTK4 UI migration while preserving classic
  UI behavior and skin compatibility
- Keeping the current GTK2 player buildable and usable until its GTK3 and GTK4
  successors achieve equivalent behavior
- Fixing **GCC 15** build blockers and modern compiler warnings
- Defaulting audio output to **ALSA** on modern Linux (OSS as a legacy option)
- Fixing plugin discovery and ALSA playback and volume behavior
- Maintaining regression tests, source distributions, documentation, and
  GitHub project infrastructure

The goal is preservation and modernization: keeping a piece of desktop
multimedia history usable on today's systems.

**Original creators:**

- Peter Alm — main programming
- Håvard Kvålen — additional programming
- Thomas Nilsson — homepage, graphics, documentation & support
- Olle Hällnäs — documentation & support

Many additional contributors shaped XMMS over the years. The full credited
list is preserved in [CONTRIBUTORS.md](CONTRIBUTORS.md). If you are (or
represent) one of those contributors and would like a correction or additional
credit, please open an issue. See also the [changelog](CHANGELOG.md) and git
history for fuller attribution.

> ℹ️ The original `http://www.xmms.org` website, its bug tracker
> (`bugs.xmms.org`), and the historical `@xmms.org` contact addresses are no
> longer active. For this fork, please use the
> [GitHub issue tracker](https://github.com/tuunanet/xmms-gtk4-experimental/issues)
> instead.

---

## Features

- Skinnable WinAmp 2.x-compatible interface (`.wsz`, zip, tar archives)
- Plugin system: Input, Output, Effect, General, Visualization
- Supported formats: MP1/2/3, Ogg Vorbis, WAV, MOD/XM/S3M/IT/… (via libmikmod), CD audio
- Streaming: HTTP, Icecast, Shoutcast (1.0/1.1) with title streaming
- Graphic equalizer with WinAmp EQF preset import/export
- Playlist editor with queue manager, jump-to-file, and sort options
- Visualization: blur scope, OpenGL spectrum analyzer, simple spectrum
- Doublesize, winshade, and dock-app (Window Maker / GNOME / AfterStep) modes

The complete feature list is in the [user manual](docs/manual.md#5-features).

---

## Installing a release package

The [GitHub Releases](https://github.com/tuunanet/xmms-gtk4-experimental/releases)
provide native x86-64 packages alongside the source archive:

- DEB packages target Linux Mint 22.3 and Ubuntu 26.04 (`amd64`).

Download the runtime package and `SHA256SUMS` from the release, verify the
checksum, then install the package matching your distribution:

```sh
# Linux Mint 22.3
sudo apt install ./xmms_0.0.1-1.linuxmint22.3_amd64.deb

# Ubuntu 26.04
sudo apt install ./xmms_0.0.1-1.ubuntu26.04_amd64.deb
```

The optional `libxmms-dev` DEB contains headers and linker files for plugin
development. Packages for other distributions should be built from source
rather than forced onto an incompatible system.

---

## Building from source

XMMS uses Meson for current builds. Install the declared system tools before
building; the project never bootstraps them or downloads Meson wraps.

### Requirements

**Required:**

- A C compiler (GCC or Clang)
- `pkg-config`
- **GTK+ ≥ 2.0** and **GLib ≥ 2.0** (with `gthread`) for the current production player
- **GTK+ 3 ≥ 3.24** for the separately linked migration proof (when enabled)
- POSIX threads (`pthread`)
- `zlib`
- ALSA development headers for the required Linux output plugin
- Meson ≥ 1.3.2, Ninja, Python 3, Cppcheck, Xvfb, and `xauth` as system packages
- Debian packaging tools: `dpkg-dev`, `debhelper`, `lintian`, `binutils`, and `tar`

For the canonical `tools/preflight.sh` gate on Debian-family systems, install
the complete package-build environment:

```sh
sudo apt install build-essential git pkg-config gettext libasound2-dev libgl-dev \
  libgtk2.0-dev libgtk-3-dev libmikmod-dev libsm-dev libvorbis-dev \
  libxxf86vm-dev zlib1g-dev meson ninja-build python3 cppcheck xvfb xauth \
  dpkg-dev debhelper lintian binutils tar
```

GTK4 is the migration target, not yet a production build dependency.

**Optional (enable additional plugins in an iterative Meson-only build):**

- `libmikmod` ≥ 3.1.5 — module format support (MOD, XM, S3M, IT, …)
- `libvorbis` — Ogg Vorbis input plugin
- OpenGL (`libGL` or Mesa) — OpenGL spectrum analyzer visualization
- ESD development headers — eSound output plugin (legacy)

These feature libraries are required by the default Debian package build above;
they are optional only when an iterative Meson build explicitly disables the
corresponding feature.
- OSS / Sun audio — platform output plugins

### Build

```sh
tools/preflight.sh
```

This canonical command configures a no-download Meson build, compiles XMMS,
runs the Xvfb-backed regression, plugin, lint, package, and source-distribution
gates, and writes unsigned `xmms` and `libxmms-dev` packages to
`deb-artifacts/`. It does not install dependencies or elevate privileges. It
runs from a dirty worktree, but the Meson source archive is the committed
snapshot; commit all release inputs before release verification. In an
extracted source archive without `.git`, supply that archive explicitly:
`DEB_SOURCE_ARCHIVE=/path/to/xmms-VERSION.tar.gz tools/preflight.sh`.

For an iterative build, use `meson setup build-meson --wrap-mode=nodownload`,
`meson compile -C build-meson`, and `xvfb-run --auto-servernum meson test -C
build-meson`. To install a verified build, run `meson install -C build-meson`.

### Useful Meson options

| Option | Description |
| --- | --- |
| `-Dprefix=PATH` | Installation prefix (default `/usr/local`) |
| `-Dopengl=disabled` | Disable the OpenGL visualization plugin |
| `-Dvorbis=disabled` | Disable the Ogg Vorbis input plugin |
| `-Dmikmod=disabled` | Disable the MikMod input plugin |
| `-Done-plugin-dir=true` | Use a single plugin directory |
| `-Duser-plugin-dir=false` | Disable per-user plugin directories |
| `-Ddev-dsp=PATH` | Path to OSS DSP device (default `/dev/dsp`) |
| `-Ddev-mixer=PATH` | Path to OSS mixer device (default `/dev/mixer`) |

Run `meson configure build-meson` for the full list.

---

## Documentation

- **[User manual](docs/manual.md)** — the complete XMMS manual (controls,
  playlist editor, equalizer, preferences, and every bundled plugin),
  converted from the original `README`.
- **[Keyboard shortcuts](docs/manual.md#311-key-bindings)** — full key binding
  reference.
- **[Architecture](docs/architecture/README.md)** — UI, processing pipeline,
  plugins, external control, playlist/streaming, build/test, and skin format.
- **[CHANGELOG.md](CHANGELOG.md)** — curated release history for this fork.
- **[Release process](docs/releases.md)** — candidate builds, manual testing,
  version tags, and draft GitHub Releases.
- **[CONTRIBUTORS.md](CONTRIBUTORS.md)** — original project credits and later
  maintenance attribution.
- **[Upstream history](docs/history/README.md)** — archived release notes,
  detailed changelog, GTK1-era FAQ, and developer TODO list from 1997–2007.
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — development workflow, tests, and
  pull-request expectations.
- **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** — participation and enforcement
  standards.
- **[SECURITY.md](SECURITY.md)** — supported versions and vulnerability
  reporting guidance.

---

## Related projects

These independent projects also preserve or reinterpret the classic XMMS and
Winamp experience using modern technologies. They are not affiliated with this
repository and have different compatibility goals.

- **[xubamp](https://github.com/hec-ovi/xubamp)** — a from-scratch Rust
  reimplementation of the classic Winamp 2.9x player for Ubuntu 26.04, using
  native Wayland and PipeWire while supporting classic `.wsz` skins.
- **[XMMS Resuscitated](https://gitlab.com/cschalle/xmms-resuscitated)** — a
  modern XMMS reimplementation built with GTK 4 and GStreamer, preserving
  Winamp 2.x skin compatibility and providing Flatpak releases.

---

## Contributing

Contributions are welcome. This is a preservation-focused fork, so changes that
keep XMMS building and running on modern systems—without altering its classic
behavior—are the priority.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for the build, test, commit, and pull
request workflow. Use the structured
[GitHub issue forms](https://github.com/tuunanet/xmms-gtk4-experimental/issues/new/choose)
for bug reports and compatibility proposals.

---

## License

XMMS is free software licensed under the
**GNU General Public License version 2 or later** ([COPYING](COPYING)). It is
provided “as is,” without warranty of any kind.
