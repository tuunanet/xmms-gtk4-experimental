# Impact assessment: GTK migration foundation

## Target

The first migration seam around `xmms/widget.[ch]`, `xmms/pbutton.[ch]`, and `xmms/skin.[ch]`, plus the compatibility policy governing GTK-linked plugin dialogs and later toolkit replacement.

## Dependents (6 groups)

- **Skinned widget engine:** at least 40 `xmms/*.[ch]` files use `GdkPixmap` or `GdkGC`; `Widget` embeds GTK2/GDK event callback types and drawing objects used by every custom control.
- **Three classic windows:** `xmms/main.c`, `xmms/playlistwin.c`, and `xmms/equalizer.c` own backing pixmaps, masks, hit-tested widget lists, redraw dispatch, windowshade, doublesize, and docking behavior.
- **Skin pipeline:** `xmms/bmp.c`, `xmms/skin.c`, default skin assets, masks, color tables, and fixed sprite coordinates feed every custom widget.
- **Dialogs and utility UI:** preferences, file selection, popup menus, fonts, about/skin windows, and `libxmms` UI helpers use removed or substantially changed GTK2 APIs.
- **Plugin families:** repository scanning finds GTK includes in Input, Output, Effect, General, and Visualization plugins. The plugin vtables expose toolkit-neutral `about`/`configure` callbacks, but implementations execute GTK-linked UI inside the player process.
- **Build and delivery:** `configure.in`, core/libxmms/wmxmms/plugin `Makefile.am` files, Debian dependencies, tests, generated Autotools output, and source-distribution manifests propagate GTK compile/link settings.

## Affected Stories

- **e03s01 — migration compatibility contract:** owns the GTK staging strategy and the accepted rule that GTK2-linked plugin UI is not loaded into the future GTK4 process.
- **e03s02 — UI behavior baselines:** owns representative skin rendering, geometry, hit-target, pressed-state, doublesize, and mask regression evidence.
- **e03s03 — first skinned-control boundary:** owns the narrow `Widget`/`PButton`/skin seam while preserving current GTK2 behavior.
- Later toolkit, window, dialog, and plugin-port epics depend on e03 but are explicitly outside this initiative.

## Test Coverage

Existing coverage:

- `tests/test-popup-position.c`: exercises GTK2 popup placement and `GtkItemFactory`; useful as migration behavior evidence but tied to APIs absent from GTK4.
- `tests/test-font-load.c`: exercises legacy `GdkFont` behavior; documents a future replacement contract but is not rendering coverage.
- `tests/test-filebrowser.c`: exercises the GTK2 file-selection flow.
- `tests/test-pluginenum.c` and fixture plugins: cover build-tree plugin discovery without validating toolkit-link compatibility.
- `tests/test-package-recipes.sh`, `tests/test-plugin-linkage.sh`, and `make distcheck`: cover build/distribution propagation.

Gaps requiring tests before production toolkit changes:

- No automated pixel or draw-command baseline for main-window skin composition.
- No focused tests for `PButton` normal/pressed source rectangles, pointer-inside transitions, callback dispatch, or boundary coordinates.
- No automated mask, windowshade, doublesize, playlist resize, docking, keyboard, or drag-and-drop parity suite.
- No plugin loader check that diagnoses or excludes plugins linked to an incompatible GTK major version.
- No GTK3 or GTK4 build target exists.

## Risk: High

The migration touches a shared UI base type with more than ten dependents, a renderer embedded throughout three large windows, GTK-linked shared objects loaded into one process, and behavior that currently has sparse automated coverage.

## Recommended action

Proceed only as small vertical increments. First accept an ADR and compatibility matrix, then add behavior baselines, then introduce one narrow skinned-control boundary while the production GTK2 player remains green. Do not change the production toolkit dependency or plugin ABI in e03. Require a design review before any process-level GTK3/GTK4 switch.
