# Changelog

All notable changes to this fork are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The historical upstream changelog (1997–2007) is preserved in
[`ChangeLog`](ChangeLog). This file covers the GTK2 fork's work only.

---

## [Unreleased]

### Fixed
- **Clean configure now succeeds.** The pre-generated `configure` script
  requires the `mkinstalldirs` automake auxiliary file, which was never
  committed (not even in the original 1.2.11 import), causing `./configure` to
  fail from a clean checkout with
  `cannot find required auxiliary files: mkinstalldirs`. Added the standard
  automake `mkinstalldirs` helper so the documented `./configure && make` flow
  works without `autoreconf`.
- Removed modern Autoconf `datarootdir` warnings from every generated build
  template while preserving custom `--datarootdir` installation paths. Removed
  the obsolete duplicate `ALL_LINGUAS` declaration; `po/LINGUAS` remains the
  canonical translation list.
- Extended `.gitignore` to cover the `tests/test-alsa-pcm-state` binary, the
  only compiled test not previously ignored.

---

## [GTK2 fork] — 2026-07

The work below completed the GTK2 compatibility and modern-build plan: a
17-task effort to restore GTK2 entry navigation, clear the GCC 15 build
blockers, and port the remaining GTK2 callback and X11 API boundaries so XMMS
1.2.11 builds and runs on contemporary Linux and BSD systems.

### GTK2 / GLib2 port
- Migrated the codebase from GTK1/GLib1 to **GTK 2.0 / GLib 2.0**, including
  `libxmms`, the main UI, and the build system (`AM_PATH_GTK_2_0`,
  `AM_PATH_GLIB_2_0`).
- Switched window/dialog types to GTK2 equivalents and removed GTK1-only
  constructs (e.g. `GtkPacker` in the joystick configuration UI, replaced with a
  supported GTK2 container).
- Ported the custom entry widget (`libxmms/xentry.c`) word-navigation to
  GTK2 public visibility/text APIs and UTF-8 character offsets, preserving
  Alt+F/Alt+B word movement for read-only entries.
- Added display-independent GLib regression tests for entry word-boundary
  navigation, including UTF-8 coverage.

### GCC 15 build compatibility
- Renamed the C23-reserved `bool` parameter in `xmms/controlsocket.c`.
- Corrected the `fts_open()` null-comparator type in `xmms/util.c`.
- Restored native callback signatures for the `sbutton` and `pbutton` custom
  widgets instead of `GTK_SIGNAL_FUNC()` field assignments.
- Cast GTK signal handlers at the `gtk_signal_connect()` boundary across the
  main UI, input dialog, playlist, equalizer, about dialogs, and the OSS,
  mpg123, CD-audio, and tone-generator plugins.
- Converted `GdkAtom` values to X11 `Atom` at Xlib boundaries in `xmms/hints.c`
  and `xmms/main.c`, preserving `GdkAtom` for GDK calls.
- Updated changed GTK2 pointer-grab and accelerator APIs
  (`gdk_pointer_grab()`, `gtk_accel_group_activate()`).

### Output and plugin handling
- Defaulted audio output to **ALSA** on modern Linux, migrating unusable OSS
  defaults to ALSA and preferring the available ALSA output plugin.
- Fixed plugin discovery from development build trees so plugins load correctly
  when running from an uninstalled build.
- Fixed ALSA playback dropout after seek by priming the PCM device.
- Added files from the GTK2 file browser.

### Documentation and project hygiene
- Modernized `README` into a Markdown `README.md` with badges, accurate
  GTK2/GLib2 build instructions, contributing and license sections, and a
  prominent section honoring the original XMMS authors.
- Moved the full original user manual to `docs/manual.md` (Markdown), with
  dead `xmms.org` links annotated and redirected to the fork's GitHub Issues.
- Rewrote `AUTHORS` as UTF-8 (fixing mojibake names), preserving every original
  contributor and adding the fork maintainer.

### Verified
- `./configure && make -j"$(nproc)"` succeeds from a clean checkout.
- `make -C tests check` passes (entry navigation, output-plugin discovery, and
  ALSA PCM state tests).

---

## Original upstream — XMMS 1.2.11 (2007)

The last upstream XMMS release, on which this fork is based. See
[`ChangeLog`](ChangeLog) and [`NEWS`](NEWS) for the full upstream history.

### Original authors
Created by **Peter Alm**, **Håvard Kvålen**, **Thomas Nilsson**, and
**Olle Hällnäs**, with contributions from many others listed in
[`AUTHORS`](AUTHORS).
