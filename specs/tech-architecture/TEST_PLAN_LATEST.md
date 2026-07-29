# Test Design: e02 GTK4 X11 migration

## 1. Strategy

This epic is P0 because it replaces the complete desktop UI across 121 source
files while preserving public plugin, skin, socket, configuration, and X11
behavior. Tests must establish contracts before migration and run at the
lowest useful level, with Xvfb integration and recorded manual UAT reserved for
native window-manager behavior.

During migration, every relevant contract runs in isolated GTK2 and GTK4 build
trees. No test process may load both toolkit majors. The final story deletes
the GTK2 side of the matrix and turns absence checks into release blockers.

## 2. Risk matrix and scenarios

| Scenario ID | Behavior | Risk | Level | Planned target |
| --- | --- | --- | --- | --- |
| SC-e02s01-P0-01 | Every plugin struct size, field offset, callback type, and entry point matches the frozen baseline | P0 | compile/integration | `tests/test-plugin-abi.sh`, ABI fixture C files |
| SC-e02s01-P0-02 | GTK4 X11 fixture obtains a native XID, shapes and moves a window, draws pixels, and receives pointer/key events | P0 | integration | `tests/test-gtk4-x11-feasibility.sh` |
| SC-e02s01-P0-03 | Non-X11 backend fails clearly before native operations | P0 | integration | feasibility fixture with `GDK_BACKEND` override |
| SC-e02s01-P1-04 | Migration inventory detects drift in GTK2 usage and compatibility surfaces | P1 | policy | `tests/test-gtk-migration-contracts.sh` |
| SC-e02s02-P0-01 | GTK2 and GTK4 configurations build separately and no artifact links both toolkits | P0 | integration | `tests/test-gtk-build-modes.sh` |
| SC-e02s02-P0-02 | Default and representative skins produce approved pixels at normal, shaded, and double size in both modes | P0 | golden | `tests/test-skin-goldens.sh` |
| SC-e02s02-P0-03 | Missing, clipped, RLE, mask, and fallback skin assets retain classic behavior | P0 | unit/integration | `tests/test-skin-rendering.sh` |
| SC-e02s03-P0-01 | GTK4 main transport, seek, volume, balance, title, time, and menus invoke unchanged core APIs | P0 | integration | `tests/test-gtk4-main-window.sh` |
| SC-e02s03-P0-02 | GTK4 gesture/controller coordinates preserve every custom-widget hit region and drag boundary | P0 | component | `tests/test-gtk4-widget-events.sh` |
| SC-e02s03-P0-03 | UI and control-socket transport produce identical playback state | P0 | integration | `tests/test-gtk4-transport-parity.sh` |
| SC-e02s03-P0-04 | Main-loop heartbeat handles time, EOF, output failure, visualization, socket work, and bounded shutdown on the main thread | P0 | integration | GTK4 lifecycle fixture |
| SC-e02s04-P0-01 | Playlist rendering, selection, queue, scrolling, resize steps, shade state, and keyboard behavior match GTK2 | P0 | integration/golden | `tests/test-gtk4-playlist-window.sh` |
| SC-e02s04-P0-02 | Pointer, popup, DnD, and socket operations mutate the same playlist model without violating locks | P0 | integration | `tests/test-gtk4-playlist-parity.sh` |
| SC-e02s04-P0-03 | Playlist position, dimensions, and visibility persist and restore exactly | P0 | integration | temporary config fixture |
| SC-e02s05-P0-01 | Equalizer controls preserve band, preamp, preset, volume-mirror, and `InputPlugin.set_eq` behavior | P0 | integration | `tests/test-gtk4-equalizer-parity.sh` |
| SC-e02s05-P0-02 | Main, playlist, and EQ windows shape, move, snap, dock, shade, scale, and restore as a group under X11 | P0 | Xvfb/E2E | `tests/test-gtk4-x11-window-contracts.sh`, `tests/test-gtk4-window-group.sh` |
| SC-e02s05-P0-03 | Native X11 adapter rejects invalid surfaces and unavailable XShape without crashing | P0 | component | adapter failure fixtures |
| SC-e02s06-P0-01 | Preferences enumerate, select, configure, enable, and disable every plugin family through unchanged core calls | P0 | integration | `tests/test-gtk4-preferences.sh` |
| SC-e02s06-P0-02 | Async open/save/multiple/folder flows preserve accepted, cancelled, and destroyed-owner outcomes | P0 | component/integration | `tests/test-gtk4-file-dialogs.sh` |
| SC-e02s06-P0-03 | GTK-independent libxmms symbols remain compatible and GTK-facing source changes are explicitly inventoried | P0 | ABI/policy | `tests/test-libxmms-api.sh` |
| SC-e02s06-P1-04 | Dialog ownership, transient parenting, repeated open/close, and shutdown are leak- and crash-free | P1 | integration | `tests/test-gtk4-dialogs.sh` |
| SC-e02s07-P0-01 | Every bundled Input/Output UI opens, applies, cancels, persists, and closes under GTK4 | P0 | fixture/integration | `tests/test-gtk4-io-plugin-uis.sh` |
| SC-e02s07-P0-02 | Input/Output plugin ABI and non-UI playback/device callbacks remain unchanged | P0 | ABI/regression | plugin ABI and existing audio tests |
| SC-e02s07-P0-03 | Every available Input/Output `.so` links exactly one selected GTK major | P0 | binary policy | `tests/test-gtk-plugin-dependencies.sh` |
| SC-e02s08-P0-01 | Every bundled Effect/General UI opens, applies, cancels, persists, and closes under GTK4 | P0 | fixture/integration | `tests/test-gtk4-effect-general-plugin-uis.sh` |
| SC-e02s08-P0-02 | Effect transforms, General sessions, and remote-control behavior remain unchanged | P0 | ABI/regression | plugin fixtures and socket tests |
| SC-e02s08-P0-03 | Every available Effect/General `.so` links exactly one selected GTK major | P0 | binary policy | dependency scanner |
| SC-e02s09-P0-01 | Visualization discovery injects fields and preserves init/start/render/stop/cleanup/disable ordering | P0 | fixture/integration | `tests/test-visualization-plugin-contract.sh` |
| SC-e02s09-P0-02 | PCM and frequency callbacks retain exact shapes, channel conversion, timing, and bounded runtime | P0 | integration/performance | `tests/test-visualization-timing.sh` |
| SC-e02s09-P0-03 | Blur Scope, Simple Spectrum, and OpenGL Spectrum render and configure under GTK4/X11 | P0 | Xvfb/E2E | `tests/test-gtk4-visualizations.sh` |
| SC-e02s09-P0-04 | Visualization `.so` files preserve ABI and contain no GTK2/GDK2 dependency in GTK4 mode | P0 | ABI/binary policy | ABI and dependency scanners |
| SC-e02s10-P0-01 | No active GTK2 include, configure flag, package, workflow, document, or SONAME remains | P0 | policy/integration | `tests/test-gtk-migration-contracts.sh --phase final` |
| SC-e02s10-P0-02 | Clean Ubuntu 26.04 build, lint, check, distcheck, Debian package, install, and smoke path passes with GTK4 only | P0 | release E2E | `tools/verify-gtk4-release.sh` |
| SC-e02s10-P0-03 | Installed executables and all bundled `.so` files depend on GTK4/GDK4 and never GTK2/GDK2 | P0 | package E2E | `tests/test-installed-gtk-dependencies.sh` |
| SC-e02s10-P0-04 | A representative third-party plugin recompiles against the frozen interface and loads in GTK4 XMMS | P0 | compatibility E2E | external-style fixture plugin |

## 3. Fixture architecture and isolation

### Build trees

- `_build-gtk2/`: temporary legacy release configuration during migration.
- `_build-gtk4/`: isolated experimental GTK4 configuration.
- `_build-package/`: clean source-archive and Debian verification.
- Scripts must delete or recreate their own build roots and never consume
  objects from another toolkit mode.

### Plugin fixtures

- Add one fixture for each plugin family exporting the established
  `get_*plugin_info` symbol.
- Add a visualization fixture that records every lifecycle call and validates
  PCM/frequency buffers.
- Compile ABI probes against a checked-in manifest of sizes, offsets, and
  function-pointer compatibility for supported architectures.
- Build an external-style fixture outside the in-tree plugin directories to
  prove the public headers remain sufficient.

### Skin fixtures

- Built-in default skin.
- One complete classic WinAmp-compatible skin.
- One incomplete skin to exercise fallback assets.
- One shaped `region.txt` skin with normal/shaded and 1×/2× goldens.
- Store deterministic PNG or raw RGBA goldens only when their provenance and
  regeneration command are documented; do not use screenshots as unverifiable
  manual evidence.

### X11 fixtures

- Xvfb for deterministic surface IDs, shape extents, geometry, events, and
  basic group movement.
- Temporary isolated `HOME` and `~/.xmms/config` per test.
- A small X11 inspection helper using Xlib/XShape queries rather than trusting
  GTK object state alone.
- Recorded manual UAT under at least one stacking X11 window manager for snap,
  move, focus, shade, and stacking behavior that Xvfb alone cannot prove.

### Dialog fixtures

- Inject callbacks around asynchronous `GtkFileDialog` results.
- Cover accept, cancel, parent destruction, repeated invocation, and shutdown.
- Do not automate native portal interaction; isolate state transitions below
  the chooser and retain one manual acceptance step.

## 4. NFR verification

| NFR | Requirement | Verification command |
| --- | --- | --- |
| Compatibility | No plugin ABI drift | `tests/test-plugin-abi.sh "$PWD"` |
| Dependency purity | One toolkit per process; final build has no GTK2 SONAME | `tests/test-installed-gtk-dependencies.sh "$PWD"` |
| Rendering fidelity | Approved skin pixels and masks match at 1×/2× and shade states | `tests/test-skin-goldens.sh "$PWD" --toolkit-matrix` |
| Responsiveness | Main heartbeat and visualization callbacks remain within documented local budgets | `xvfb-run --auto-servernum tests/test-visualization-timing.sh "$PWD" --toolkit-matrix` |
| Reliability | Repeated create/show/hide/destroy cycles do not crash or retain invalid callbacks | `xvfb-run --auto-servernum tests/test-gtk4-dialogs.sh "$PWD" --repeat 100` |
| Thread safety | GTK calls execute only on the owning main context | `xvfb-run --auto-servernum tests/test-gtk4-main-thread.sh "$PWD"` |
| Operability | Non-X11 backend and missing native capabilities fail with actionable diagnostics | `tests/test-gtk4-backend-errors.sh "$PWD"` |
| Delivery | Release-equivalent clean build and package path passes | `tools/verify-gtk4-release.sh "$PWD"` |

Performance budgets must be measured from the current GTK2 baseline in
`e02s01` before numeric thresholds are frozen. The migration may not relax a
measured budget without explicit approval.

## 5. Manual UAT matrix

Each GTK4 window story records evidence for:

- default and representative external skin;
- normal, shaded, and double-size modes;
- independent and docked window movement;
- pointer click, drag, wheel, keyboard accelerator, and popup interaction;
- close/reopen and persisted restart state;
- playback active, paused, stopped, EOF, and output-failure states where
  applicable.

Final UAT additionally verifies all bundled plugin dialogs and visualizers on
Ubuntu 26.04 under the X11 backend.

## 6. Out of scope

- Wayland and portal behavior beyond a clear unsupported-backend diagnostic.
- Pixel parity for desktop decorations outside XMMS-owned shaped content.
- Historical GTK2 binary plugin loading.
- Codec quality, hardware audio fidelity, or unrelated network behavior except
  regression coverage already present.
