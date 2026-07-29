# XMMS GTK4 Experimental Project Context

> Derived from the repository on 2026-07-28. This is a map of the architecture
> and observed conventions, not a redesign proposal. The authoritative public
> plugin ABI remains `xmms/plugin.h`; detailed subsystem diagrams live under
> `docs/architecture/`.

## Product and compatibility posture

XMMS GTK4 Experimental is a community-maintained preservation fork of XMMS 1.2.11. It
keeps the classic player usable on modern Linux while preserving historical
identifiers, configuration paths, plugin interfaces, UI behavior, and skin
compatibility. Modernization work therefore has a stronger compatibility
constraint than a typical greenfield media player.

Primary compatibility surfaces:

- `xmms` executable and source-package names
- `~/.xmms/` configuration, plugin, playlist, and skin conventions
- C plugin vtables and exported `get_*plugin_info` symbols in `xmms/plugin.h`
- `libxmms` public headers and `xmms_remote_*` client API
- Unix-domain control-socket command framing and `CMD_*` values
- WinAmp 2 / XMMS skin dimensions, assets, and interaction behavior
- Autotools source-distribution and Debian package workflows

## Stack

### Language and runtime

- Predominantly C with GLib scalar/container types and manual memory ownership.
- GTK+ 2 and GLib 2 remain required by the production player; `configure.in` declares a minimum of 2.0.0.
- GTK+ 3 >= 3.24 is auto-detected for a separately linked Play-button migration proof and can be disabled explicitly for legacy build environments.
- POSIX threads provide decoder, output, playlist-metadata, and control-socket
  concurrency.
- X11 integration covers the desktop UI, docking, session management, and
  optional fullscreen/video-mode behavior.
- GNU gettext supplies localization.
- Shared plugins are loaded at runtime through `dlopen`/`dlsym` on common Unix
  systems, with an HP-UX `shl_*` compatibility path.

### Build and distribution

- GNU Autotools: autoconf, automake, and libtool.
- `configure.in` is the source configure definition; generated `configure`,
  `Makefile.in`, and other distribution artifacts are intentionally present.
- Top-level build order is `intl`, `libxmms`, `xmms`, plugin families,
  `wmxmms`, then `po`.
- Main validation commands:

  ```sh
  ./configure --disable-esd
  make -j"$(nproc)"
  xvfb-run --auto-servernum make check
  xvfb-run --auto-servernum make distcheck
  make deb
  ```

- GitHub Actions runs on Ubuntu 24.04, uses ccache, and executes configure,
  build, Xvfb-backed tests, `distcheck`, and Debian packaging for
  build-affecting changes. Documentation/metadata-only changes can skip the
  full build through a path classifier.

### Dependencies

Required or foundational:

- C compiler (GCC or Clang)
- GTK+ 2, GLib 2 with gthread
- GTK+ 3 >= 3.24 for the enabled migration-proof gate; it is not linked into the production GTK2 process
- POSIX threads
- libtool/dynamic-loader support
- X11 libraries used by GTK and optional session/video integrations
- gettext/iconv

Feature-gated dependencies:

- ALSA >= 0.9 for the preferred modern Linux output plugin
- libmikmod >= 3.1.5 for module formats
- libvorbis/libogg for Ogg Vorbis input
- OpenGL for the spectrum visualization
- ESD, OSS, Sun, and Solaris audio paths for legacy platforms
- zlib for compressed skin/archive support

Notable age constraints: GTK2 is end-of-life, several optional backends are
legacy, and `configure.in` uses historical Autoconf/Automake macros. Changes to
build tooling should preserve generated-source and source-tarball workflows.

## Repository architecture

| Path | Responsibility |
| --- | --- |
| `xmms/` | Main GTK application, playlist model, plugin glue, control socket, skinned widgets, and UI state |
| `libxmms/` | Shared remote-control API plus config, title, formatting, charset, and reusable UI/string helpers |
| `Input/` | File/stream recognition, metadata, decoding, and PCM production |
| `Output/` | Buffering, effects invocation, conversion, volume, and device/file output |
| `Effect/` | Ordered in-place PCM transforms |
| `Visualization/` | PCM/frequency renderers fed by the visualization side-channel |
| `General/` | Non-PCM integrations such as IR, joystick, and song-change commands |
| `wmxmms/` | Separate Window Maker dock client using `libxmms` remote APIs |
| `tests/` | GLib C tests, fixture plugins, and shell integration/packaging checks |
| `docs/architecture/` | Maintainer-facing subsystem maps and data-flow documentation |
| `packaging/`, `tools/` | Debian recipes and release/build helpers |

The design is a historical modular monolith with dynamically loaded plugin
boundaries. It is not layered through dependency injection: modules share
public C headers, global state, callback vtables, GLib lists, and explicit
mutexes.

## Entry points and data flow

### Process entry points

- `xmms/main.c:main` starts the full player, configuration, control socket,
  plugins, skinned windows, GTK timeout heartbeat, and GTK event loop.
- `wmxmms/wmxmms.c:main` starts a separate dock application that controls an
  existing player through `libxmms`.
- Each plugin exports exactly one family entry point:
  `get_iplugin_info`, `get_oplugin_info`, `get_eplugin_info`,
  `get_vplugin_info`, or `get_gplugin_info`.

### Playback path

```text
GTK callback / control socket
  -> playlist_* controller and model
  -> input_play(filename)
  -> first enabled InputPlugin whose is_our_file() succeeds
  -> decoder-owned worker thread
  -> OutputPlugin.open_audio / buffer_free / write_audio
  -> output-owned ring/worker path where applicable
  -> pseudo EffectPlugin dispatches enabled effects in list order
  -> format/rate/channel conversion and optional software volume
  -> audio device or disk writer
```

The Input plugin is the producer and drives back-pressure through the selected
Output vtable. Effects execute output-side. Equalization is a historical
exception: `input_set_eq` calls the current Input plugin's optional `set_eq`
callback rather than an Effect plugin.

### Visualization path

Input plugins call the core-injected `add_vis_pcm` callback. `xmms/input.c`
normalizes a bounded block to native-endian signed 16-bit PCM and queues it
under `vis_mutex`, timestamped against output `written_time`. The GTK
`idle_func` drains due blocks, computes reusable PCM/frequency forms, and
updates enabled visualization plugins and built-in skin visualizers.

### UI and control path

The skinned main, playlist, and equalizer windows use custom hit-tested widget
lists painted from skin pixmaps rather than ordinary GTK buttons. Callbacks
cross into `playlist_*`, `input_*`, output/effect/visualization glue, and
configuration state.

A roughly 10 ms GTK timeout runs `idle_func`, which coordinates playback time,
EOF and output-failure handling, visualization updates, redraws, and queued
control-socket commands. External clients use `libxmms/xmmsctrl.c` over an
`AF_UNIX` stream. The socket reader parses and queues work; `check_ctrlsocket`
applies it on the GTK thread so GTK and playlist operations do not run in the
reader thread.

### Metadata and streaming side paths

- A playlist metadata thread probes missing titles and durations. It copies a
  filename, releases `PL_LOCK` around potentially slow plugin I/O, reacquires
  the lock, and verifies that the entry still exists before mutation.
- HTTP/Icecast support belongs to individual Input plugins (not a shared core
  HTTP service). mpg123 and Vorbis each own network buffering, proxy settings,
  stream metadata, and stop/seek behavior before feeding the common PCM path.

## Plugin contracts

`xmms/plugin.h` defines five mutable C vtables:

- `InputPlugin`: recognize, decode, transport, metadata, optional EQ/volume,
  and core-injected callbacks/output pointer.
- `OutputPlugin`: stream lifecycle, buffered writes, timing, pause/flush, and
  volume.
- `EffectPlugin`: ordered `query_format` and `mod_samples` passes.
- `VisPlugin`: playback lifecycle and bounded PCM/frequency rendering.
- `GeneralPlugin`: lifecycle/configuration plus a control-socket session id.

`xmms/pluginenum.c` scans user plugins first, then an in-tree build location
when no installed plugin directory exists, then installed plugin directories.
Basename de-duplication lets a user plugin shadow a system plugin. Loaded lists
are sorted by description; enabled/current choices are restored from config.

The effect glue preserves the historical single-effect output API with a
pseudo plugin. `effects_enabled()` always returns true, while the pseudo
plugin walks the mutex-protected enabled-effect list. This compatibility
facade is intentional and should not be simplified without auditing all
external output plugins.

## State and persistence

### Durable state

- Main INI-like config: `~/.xmms/config`, parsed through `libxmms/configfile.c`
- User plugins: `~/.xmms/Plugins` and deprecated family subdirectories
- User skins: `~/.xmms/Skins`
- User-managed playlist files and plugin-specific config sections

### Runtime state

- Global `Config cfg` and many global/static GTK widgets in `xmms/main.c` and
  window modules
- Playlist, shuffle, and queue `GList` structures protected by playlist locks
- Current Input/Output pointers and enabled Effect/Vis/General lists
- Per-plugin decode, network, and output worker state
- Mutex-protected visualization and effect lists
- Queued control-socket packets transferred to the GTK thread

## Observed conventions

### C and ownership

- GLib allocation and containers (`g_malloc0`, `g_strdup`, `g_free`, `GList`)
  are preferred around GTK-facing code.
- Modules expose functions through headers but frequently retain process-wide
  state in globals or file-static variables.
- Plugin objects are static structs owned by their shared libraries; the core
  fills runtime fields such as `handle`, `filename`, callbacks, and session id.
- Null callback pointers represent unsupported optional behavior.
- Boolean/status APIs use GLib types where convenient but plugin ABI fields
  also use plain C `int`, `short`, and pointers.

### Naming and API shape

- Functions and persisted config keys use `snake_case`.
- Core subsystem facades use prefixes such as `playlist_*`, `input_*`,
  `effect_*`, `vis_*`, and `xmms_remote_*`.
- This is not an HTTP/REST application. External API shapes are C functions,
  plugin vtables, binary socket packets, and INI-like configuration sections.
- Negative playback times are sentinel statuses: `-1` for EOF and `-2` for
  output failure in the established path.

### Error handling

There is no centralized structured error model. Observed mechanisms include:

- return values and sentinel integers for recoverable operational outcomes
- `g_warning`, `g_message`, and `g_log` for diagnostics
- `fprintf(stderr, ...)`, `perror`, and `dlerror` in lower-level/legacy paths
- GTK dialogs for user-visible playback and configuration failures
- `g_error` in some legacy output code, which terminates the process

Error behavior is subsystem-specific. New code should follow its local API's
return-value convention, avoid introducing fatal `g_error` for recoverable
runtime failures, and keep GTK reporting on the main thread.

### Concurrency

- GTK calls and core UI mutations belong on the main thread.
- Decoder and output plugins commonly own worker threads.
- Shared lists use explicit pthread mutexes (`PL_LOCK`, `vis_mutex`,
  `emutex`, and subsystem-specific locks).
- Slow metadata or network I/O must not occur while holding the playlist lock.
- Visualization callbacks explicitly require fast work.
- Locking is local and manual rather than enforced by types; nearby code is
  the primary source for lock ordering and lifecycle rules.

### Observability

Observability is desktop-oriented and unstructured:

- GLib/stderr messages and user dialogs
- no metrics, tracing, health endpoint, or structured JSON logs
- CI build/test/package evidence is the main automated operational signal

For this local desktop application, absence of a service health check is
expected. Debugging concurrent audio paths relies on local logs, targeted
regression tests, and reproduction against specific plugins/devices.

## Testing strategy

`make check` currently orchestrates thirteen focused C executables and five shell
checks when the GTK3 migration proof is enabled.

- C tests use GLib `g_test_*` and assertions.
- Several tests compile selected production `.c` files directly with section
  garbage collection, keeping tests small without starting the full player.
- Fixture Input/Output shared objects validate build-tree plugin discovery.
- GTK geometry and font tests need an X11 display; CI uses Xvfb.
- Play-button migration tests lock GTK2 behavior, exercise toolkit-neutral state without a display, and prove GTK3 rendering/activation in a separate executable whose linkage rejects GTK2.
- ALSA and mpg123 tests target extracted state/position or fallback behavior.
- Shell tests cover generated i18n sources, plugin linkage, packaging recipes,
  and release tooling.
- `make distcheck` validates a clean source-distribution rebuild in addition
  to the normal suite.

There is no repository-level coverage threshold. Many UI, playlist,
control-socket, streaming, and legacy backend paths remain primarily
integration/manual-test territory. For changes, prefer a focused `g_test`
against a small extracted function or source slice, then run the full Xvfb
suite and `distcheck` when practical.

## Signals and active considerations

### Architectural hotspots

- `xmms/main.c` is a large composition root and UI/state hotspot.
- `xmms/playlistwin.c`, `xmms/equalizer.c`, `xmms/prefswin.c`, and
  `xmms/playlist.c` are also large, stateful modules.
- Plugin ABI structs, `libxmms`, and control-socket commands have broad
  compatibility blast radius.
- Output and Input plugins combine domain logic with thread, device/network,
  buffering, conversion, configuration, and GTK-dialog concerns.
- Shared global state and manual lock discipline make broad refactors risky.

### Consistency gaps and debt

- Error reporting mixes return codes, sentinels, GLib logs, stderr, dialogs,
  and fatal `g_error` calls.
- HTTP/proxy and buffering implementations are duplicated across Input
  plugins; source comments already note the lack of one proxy configuration
  location.
- Optional feature detection and README language should be checked together;
  for example, zlib is described as required in README while `configure.in`
  probes it without an immediate configure-time error.
- Generated build products and configured binaries exist in the working tree,
  so edits must distinguish source-of-truth files from generated artifacts.
- Historical platform/backend code contains known FIXME/TODO paths and may not
  receive the same runtime exercise as ALSA on modern Linux.
- The control client/server contains comments warning that some packet reads
  can wait indefinitely.
- GTK2 and several build macros are obsolete upstream, but replacing them is a
  migration project rather than a routine cleanup because UI and packaging
  behavior are compatibility requirements.

### Planning implications

1. Treat plugin vtables, exported symbols, config keys/paths, socket command
   values, and skin semantics as public contracts unless a task explicitly
   scopes a compatibility break.
2. Make vertical, subsystem-local changes; avoid opportunistic global-state or
   threading rewrites.
3. Trace both direct UI and remote-control entry points when changing transport
   or playlist behavior.
4. Trace local-file and HTTP modes when changing an Input plugin.
5. Verify thread ownership and lock boundaries before adding callbacks or I/O.
6. Add focused tests beside an existing analogous test; keep Xvfb requirements
   explicit.
7. Update `configure.in` and expected generated/distribution files according to
   established Autotools practice rather than editing generated output alone.
8. Run packaging/release checks when changing versions, manifests, generated
   sources, plugin linkage, or install paths.

## Source map for future work

- Architecture overview: `docs/architecture/README.md`
- UI and startup: `docs/architecture/ui-interaction.md`, `xmms/main.[ch]`
- Playlist model: `xmms/playlist.[ch]`
- PCM and threading: `docs/architecture/processing-pipeline.md`
- Plugin ABI/discovery: `xmms/plugin.h`, `xmms/pluginenum.c`
- Remote control: `xmms/controlsocket.[ch]`, `libxmms/xmmsctrl.[ch]`
- Config format: `libxmms/configfile.[ch]`
- Build/test: `configure.in`, `Makefile.am`, `tests/Makefile`,
  `.github/workflows/ci.yml`
- Contributor commands: `CONTRIBUTING.md`
