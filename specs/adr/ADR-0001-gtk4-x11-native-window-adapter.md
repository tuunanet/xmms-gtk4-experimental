# ADR-0001: Use GTK4 windows with a contained X11 native-window adapter

- Status: Accepted for planning
- Date: 2026-07-28
- Initiative: Direct GTK2-to-GTK4 migration

## Context

XMMS Classic must preserve the exact X11 behavior of its skinned main,
playlist, and equalizer windows: native shape masks, absolute positioning,
docking, group movement, stacking hints, shading, and double-size geometry.
GTK4 intentionally removed backend-neutral move, restack, shape, and several
window-manager APIs. Its migration guide directs applications that still need
such controls to backend APIs or Xlib.

GTK 4.22 still exposes the native XID through
`gdk_x11_surface_get_xid()`, but GTK deprecated that accessor in 4.18 and does
not identify a supported replacement capable of applying XShape or direct X11
movement. This creates a deliberate tension between using GTK4 top-level
widgets and preserving exact classic X11 behavior.

## Decision

Use GTK4 `GtkWindow`/`GdkSurface` objects for the visible XMMS windows and
contain all native backend access in one X11 adapter module. The adapter may:

- verify that the active GDK backend is X11;
- obtain the native XID through the GTK 4.22 GDK X11 API;
- apply XShape regions, direct movement, grouping, stacking, and required EWMH
  or ICCCM hints through Xlib/Xext;
- translate failures into actionable startup or window-operation diagnostics;
- expose only XMMS-specific geometry and window-policy operations to callers.

No other module may obtain or manipulate a native XID directly. The adapter's
use of deprecated GDK X11 access is an approved, documented exception and must
be covered by compile, Xvfb, and runtime behavior tests.

## Reason for Depth

Exact classic window-manager behavior is a product requirement that GTK4 does
not model, so isolating unavoidable backend-specific operations prevents X11
and deprecated API details from spreading throughout the UI migration.

## Alternatives considered

### Raw X11 skinned windows plus GTK4 dialogs

Rejected. It avoids deprecated GDK XID access but means the three primary
windows are not GTK4 widgets, contrary to the approved migration goal, and
creates a second event/window ownership model.

### GTK4-only backend-neutral behavior

Rejected. GTK4 deliberately leaves absolute movement, restacking, and shaping
to the compositor or native backend; that cannot guarantee the selected exact
X11 behavior.

### Wayland-compatible redesign

Rejected as out of scope. The project explicitly chooses X11-only behavior.

### GTK3 intermediate stage

Rejected by decision. The migration is direct from GTK2 to GTK4.

## Consequences

- The application must reject non-X11 GDK backends clearly and early.
- GTK4 X11 and Xext/XShape become explicit build and runtime requirements.
- One deprecated GTK4 backend accessor is tolerated behind a narrow boundary.
- A GTK upgrade that removes the accessor requires revisiting this ADR before
  increasing the minimum GTK version.
- X11 behavior must be tested under Xvfb and manually under representative
  window managers; compile success is insufficient.
- All ordinary widgets, drawing areas, dialogs, input controllers, and main-loop
  integration still use supported GTK4 APIs.

## Verification obligations

Before the core cutover is approved, a throw-away spike must prove:

1. a GTK4 window can expose its XID on the Ubuntu 26.04/GTK 4.22 baseline;
2. XShape applies normal and shaded masks correctly;
3. Xlib movement and group docking preserve configured coordinates;
4. Cairo skin drawing remains pixel-stable at normal and double size;
5. click, drag, key, and motion controllers coexist with direct X11 movement;
6. the proof runs under Xvfb and fails clearly under a non-X11 backend.

## Sources

- https://docs.gtk.org/gtk4/migrating-3to4.html
- https://docs.gtk.org/gdk4-x11/method.X11Surface.get_xid.html
- `docs/architecture/ui-interaction.md`
- `docs/architecture/skins.md`
- `xmms/dock.c`
- `xmms/skin.c`
