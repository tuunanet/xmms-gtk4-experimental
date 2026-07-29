# e02s05: Use the equalizer and docked window group under GTK4 X11

<!-- story: e02s05 -->

**type:** feat

**risk:** P0

**context:** domain

**bcps:** 8

## 1. Summary

Port the equalizer and production X11 adapter so all three skinned GTK4 windows shape, move, snap, dock, shade, scale, persist, and restore like classic XMMS.

## 2. User

XMMS users adjusting equalization and arranging the classic window group.

## 3. Problem

GTK4 removes window movement, shape, and several WM APIs, while the equalizer depends on fixed controls, presets, plugin callbacks, and synchronized window geometry.

## 4. Value

The complete recognizable XMMS window group behaves correctly on X11 and audio equalization remains usable.

## 5. Context

ADR-0001 confines deprecated GDK XID access and Xlib/XShape to one adapter. e02s01 proves feasibility; this story turns that proof into tested production behavior.

## 6. In Scope

- Equalizer bands, preamp, presets, enable/auto, volume mirroring, drawing, shade, and persistence.
- X11 adapter for shape, movement, docking, grouping, hints, scale, and error reporting.
- Group behavior across main, playlist, and EQ windows.

## 7. Out of Scope

- DSP redesign or plugin callback changes.
- Wayland fallback.
- Desktop decoration pixel parity outside XMMS-owned content.

## 8. Dependencies

- **[OK] Xlib/Xext/XShape:** approved native operations.
- **[REPLACE] `gdk_x11_surface_get_xid`:** deprecated but approved and isolated by ADR-0001.
- e02s01–e02s04.

## 9. Module Purpose

The equalizer maps fixed controls to existing EQ state; the X11 adapter owns all native window IDs and classic WM policy.

## 10. Callers

Main, playlist, equalizer, dock/group logic, config restore, skin mask changes, and double-size transitions.

## 11. Contracts

- `InputPlugin.set_eq` and persisted EQ values remain unchanged.
- No module outside the adapter obtains an XID.
- Invalid/unrealized surfaces are rejected safely.
- Classic coordinates, snap distances, masks, shade, and 2× geometry remain exact.

## 12. Requirements

### MODIFIED: Equalizer UI

**Before:** GTK2 custom controls and direct drawing manage EQ state.

**After:** GTK4 controls/drawing preserve the same state and plugin callback contract.

### MODIFIED: Native window policy

**Before:** GTK2/GDK and scattered X11 access move and shape windows.

**After:** One GTK4 X11 adapter owns native shape, move, group, hint, and geometry operations.

## 13. Design

Expose XMMS-specific window operations rather than raw XIDs. **Reason for Depth:** GTK4 lacks required backend-neutral semantics, but containing X11 prevents deprecated/native access from infecting ordinary UI code.

## 14. Files and Data

- Equalizer modules and presets.
- `dock.c` and a new focused X11 adapter module/header.
- X11 query helper, shape fixtures, and window-group tests.
- Existing config keys remain unchanged.

## 15. Error Handling

Non-X11 backend, unrealized surface, missing XShape, stale XID, and failed native requests produce actionable recoverable errors or startup rejection; no unchecked native handle is retained.

## 16. Security

Native IDs are sensitive process state. Validate ownership/lifetime, avoid arbitrary XID input, check arithmetic for doubled geometry, and keep Xlib calls on the UI thread.

## 17. Acceptance Criteria

### SC-e02s05-P0-01: Equalizer behavior matches

```gherkin
Given equivalent EQ state in GTK2 and GTK4
When bands, preamp, presets, enable, auto, and volume mirror change
Then persisted values and InputPlugin callbacks match
And rendered controls occupy identical skin coordinates
```

### SC-e02s05-P0-02: Classic window group works

```gherkin
Given all three GTK4 windows under X11
When they are shaped, moved, snapped, docked, shaded, and doubled
Then queried native masks and geometry match classic rules
And restart restores the same group state
```

### SC-e02s05-P0-03: Invalid native state fails safely

```gherkin
Given an unrealized or destroyed surface or unavailable XShape
When a native operation is requested
Then the adapter rejects it with context
And no stale XID is used
```

## 18. Implementation Steps

1. Add equalizer contracts → verify: `xvfb-run --auto-servernum tests/test-gtk4-equalizer-window.sh "$PWD"`
2. Port equalizer controls and drawing → verify: `xvfb-run --auto-servernum tests/test-gtk4-equalizer-parity.sh "$PWD"`
3. Implement the contained X11 adapter (ref: ADR-0001) → verify: `xvfb-run --auto-servernum tests/test-gtk4-x11-window-contracts.sh "$PWD"`
4. Prove complete group behavior → verify: `xvfb-run --auto-servernum tests/test-gtk4-window-group.sh "$PWD"`
5. Run both build modes → verify: `tests/test-gtk-build-modes.sh "$PWD" --story e02s05`

## 19. Verification Script

1. Exercise every EQ control and preset with a recording Input plugin fixture.
2. Query native shape extents and geometry under Xvfb.
3. Move/dock each window combination at 1×/2× and shade/unshade.
4. Restart with saved state and compare.
5. Run manually under a representative stacking X11 WM and record UAT.

## 20. Risks

- Deprecated XID access may disappear in a later GTK baseline.
- WM behavior differs beyond Xvfb; manual X11 WM UAT is mandatory.
- Geometry overflow or rounding can corrupt double-size docking.
