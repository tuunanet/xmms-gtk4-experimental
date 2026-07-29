# Impact Assessment: Direct GTK2-to-GTK4 migration

## Target

Replace the GTK2/GDK2 UI and build dependency across the XMMS process,
GTK-facing `libxmms` helpers, bundled plugin UIs, visualizations, tests,
packaging, CI, and release automation while preserving classic X11 behavior
and all plugin-family interfaces.

## Dependents (121 C/header files)

Direct source inventory found 121 files using GTK/GDK symbols or types:

| Area | Files | Primary impact |
| --- | ---: | --- |
| `xmms/` | 59 | Composition root, three skinned windows, custom widgets, menus, DnD, dialogs, timers, X11 integration |
| `Output/` | 17 | About/configuration dialogs and some user-visible errors |
| `Input/` | 16 | Configuration, metadata, HTTP error, and file-information dialogs |
| `libxmms/` | 8 | Entry subclass, dialog helpers, directory browser, title-format widgets |
| `General/` | 7 | IR, joystick, and song-change configuration/about windows |
| `Visualization/` | 5 | GTK2/GDK2 drawing, configuration dialogs, and X11/GLX rendering |
| `Effect/` | 5 | Effect configuration/about dialogs |
| `tests/` | 3 | GTK-dependent focused tests; two additional UI tests are wired through the test Makefile |
| `wmxmms/` | 1 | Shared GTK-facing include or symbol dependency requiring isolation review |

High-fan-in removed or incompatible API families include:

| API family | Files using it |
| --- | ---: |
| `GdkPixmap` | 45 |
| `GdkGC` | 41 |
| `GtkItemFactory` | 7 |
| `GtkCList` | 3 |
| `GtkFileSelection` | 5 |
| legacy `gtk_signal_*` / `GTK_OBJECT` | 48 |
| `GDK_THREADS_*` | 16 |
| direct `widget->window` access | 28 |
| `gtk_widget_set_usize` | 24 |
| `gtk_window_set_policy` | 25 |
| `gtk_container_add` | 30 |

The current build contract is rooted in `configure.in` through
`AM_PATH_GTK_2_0`, global `GTK_CFLAGS`/`GTK_LIBS`, and direct X11/gthread
linkage. GTK2 packages are repeated in Debian metadata and four GitHub
workflows. Public documentation and architecture diagrams also identify GTK2
as foundational.

## Compatibility blast radius

### Contracts that must not change

- `InputPlugin`, `OutputPlugin`, `EffectPlugin`, `GeneralPlugin`, and
  `VisPlugin` layouts in `xmms/plugin.h`.
- Exported `get_*plugin_info` symbols and loader precedence.
- Core-injected plugin fields and lifecycle/callback ordering.
- Visualization PCM (`gint16[2][512]`) and frequency (`gint16[2][256]`) data.
- `libxmms` remote-control API, control-socket framing and command values.
- `~/.xmms/` paths, config keys, plugin basenames, enabled lists, and skin
  formats.
- GTK main-thread ownership and existing audio/playlist/socket lock boundaries.

### Approved source compatibility change

GTK-facing `libxmms` helpers and plugin UI source may change where GTK4 has no
source-compatible equivalent. Bundled and third-party GTK plugins must be
recompiled. GTK-independent plugin source should continue using the unchanged
XMMS interface.

## Affected stories

- `e02s01`: compatibility contracts and X11 feasibility proof.
- `e02s02`: isolated build modes and skin rendering boundaries.
- `e02s03`: GTK4 main player, input, heartbeat, and transport parity.
- `e02s04`: GTK4 playlist window and model/socket parity.
- `e02s05`: GTK4 equalizer and classic X11 window-group behavior.
- `e02s06`: preferences, async choosers, core dialogs, and `libxmms` helpers.
- `e02s07`: Input and Output plugin UI migration.
- `e02s08`: Effect and General plugin UI migration.
- `e02s09`: visualization plugin migration.
- `e02s10`: build, CI, packaging, documentation, and GTK2 removal.

Every planned story is affected by shared UI or delivery contracts. No story
can waive plugin ABI or skin behavior because those are epic-level invariants.

## Test coverage

Existing focused coverage:

- `tests/test-xentry.c`: custom entry behavior.
- `tests/test-filebrowser.c`: file-browser path behavior.
- `tests/test-font-load.c`: classic font selection/fallback.
- `tests/test-popup-position.c`: popup geometry.
- `tests/test-pluginenum.c`: build-tree plugin loading for Input/Output only.
- shell checks: distribution, packaging, release workflows, and C lint policy.

Material gaps:

- No ABI snapshot covers every plugin struct size, offset, callback signature,
  or exported entry point.
- No visualization fixture exercises `get_vplugin_info`, injected fields,
  enable/disable, render data, or cleanup.
- No automated pixel-golden coverage exists for main/EQ/playlist skin output.
- No automated X11 contract tests cover shaped regions, absolute position,
  docking, group movement, shading, double-size, or focus/stacking behavior.
- No end-to-end UI test covers menus, keyboard accelerators, pointer gestures,
  DnD, preferences, file selection, plugin dialogs, or persistence.
- Optional plugin UIs are largely untested and may be excluded by missing
  backend dependencies.
- CI currently targets Ubuntu 24.04 rather than the approved Ubuntu 26.04
  baseline.

## Risk: High

This is a whole-UI replacement across 121 source files, shared process-global
state, removed drawing/event APIs, public plugin boundaries, X11 window-manager
behavior, and all delivery paths. Test coverage is sparse precisely where the
migration is most behavior-sensitive. Numeric risk score: **10/10** (maximum
fan-in, maximum fan-out, and active UI churn).

## Recommended action

Do not begin a broad mechanical port. Before implementation planning is
approved:

1. Research GTK 4.22 and GDK X11 replacements using official API documentation.
2. Produce an ADR for X11 surface access, native shaping/positioning, rendering,
   event dispatch, and multi-PR integration strategy.
3. Run a throw-away GTK4/X11 spike proving shaped windows, direct movement,
   docking geometry, Cairo skin drawing, pointer input, and headless Xvfb
   execution on Ubuntu 26.04.
4. Add plugin ABI snapshots, a visualization fixture, dynamic GTK2 dependency
   detection, and skin/window acceptance harnesses before the cutover.
5. Use explicit migration inventories and small ownership-oriented stories;
   require a gaps loop for every removed GTK2 API family.

Proceed to research and architecture elaboration, not implementation.
