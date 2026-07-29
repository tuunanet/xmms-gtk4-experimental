# e02s04: Manage the playlist through its GTK4 X11 window

<!-- story: e02s04 -->

**type:** feat

**risk:** P0

**context:** domain

**bcps:** 8

## 1. Summary

Deliver the classic playlist window under GTK4 with matching rendering, selection, queueing, scrolling, resizing, shading, drag-and-drop, persistence, and remote-control behavior.

## 2. User

XMMS users organizing and navigating playback queues.

## 3. Problem

The playlist UI combines direct GDK drawing, legacy events, menus, DnD, custom scrollbars, dynamic geometry, and a lock-sensitive shared model.

## 4. Value

Users can perform the complete playlist workflow in GTK4 without changing playlist files, control commands, or streaming behavior.

## 5. Context

Playlist model operations must not hold locks across I/O. The fixed skin geometry and socket API remain compatibility boundaries.

## 6. In Scope

- List, selection, queue, position, scrolling, keyboard, menus, and popups.
- DnD, resize increments, shade state, visibility, coordinates, and persistence.
- UI/socket behavioral parity and lock-safety tests.

## 7. Out of Scope

- Playlist data model or format redesign.
- Streaming, metadata, or socket protocol changes.
- Window-group docking, completed in e02s05.

## 8. Dependencies

- **[OK] GTK4 controllers and DnD APIs:** supported event/transfer path.
- e02s02 rendering and e02s03 lifecycle/widget adaptation.

## 9. Module Purpose

`playlistwin.c` presents the shared playlist model through fixed skin geometry and translates user actions into existing playlist APIs.

## 10. Callers

Users, main-window actions, playlist callbacks, control-socket commands, file loaders, and configuration restore.

## 11. Contracts

- Playlist model and socket semantics remain unchanged.
- No slow I/O occurs while playlist locks are held.
- Selection, queue, scroll, resize, and persisted state match GTK2.
- GTK work remains on the main thread.

## 12. Requirements

### MODIFIED: Playlist presentation

**Before:** GTK2/GDK events and direct window drawing present the playlist.

**After:** GTK4 controllers and Cairo present identical playlist state and interactions.

### MODIFIED: Playlist drag-and-drop

**Before:** Legacy GTK2 selection and DnD APIs add entries.

**After:** GTK4 DnD preserves accepted inputs, ordering, and error behavior.

## 13. Design

Keep the playlist model intact and port only the presentation/controller boundary. **Reason for Depth:** UI replacement must not disturb the lock and streaming invariants that protect playback responsiveness.

## 14. Files and Data

- `xmms/playlistwin*`, playlist custom controls, menus, DnD adapters.
- GTK4 playlist, parity, geometry, and persistence fixtures.
- Existing playlist/config formats remain unchanged.

## 15. Error Handling

Invalid drops, unreadable entries, vanished rows, callback races, and impossible saved geometry fail or degrade exactly as existing recoverable paths do; no fatal `g_error`.

## 16. Security

Dropped URIs and filenames are untrusted. Preserve normalization and input boundaries, avoid shell evaluation, and maintain lock discipline around asynchronous work.

## 17. Acceptance Criteria

### SC-e02s04-P0-01: Playlist interactions match

```gherkin
Given equivalent GTK2 and GTK4 playlist state
When selection, queue, scroll, resize, shade, keyboard, and popup operations run
Then rows, highlights, current position, dimensions, and persisted values match
```

### SC-e02s04-P0-02: UI and socket operations agree

```gherkin
Given a populated playlist
When equivalent add, remove, move, select, and position operations use UI and socket paths
Then the resulting model and visible state are identical
And no playlist lock spans slow I/O
```

### SC-e02s04-P0-03: Window state restores

```gherkin
Given saved playlist visibility, shade, size, and coordinates
When GTK4 XMMS restarts
Then the playlist window restores the same state and skin-aligned geometry
```

## 18. Implementation Steps

1. Add playlist rendering and interaction contracts → verify: `xvfb-run --auto-servernum tests/test-gtk4-playlist-window.sh "$PWD"`
2. Port list drawing and input dispatch → verify: `xvfb-run --auto-servernum tests/test-gtk4-playlist-window.sh "$PWD" --interactions`
3. Port menus, DnD, resize, shade, and persistence → verify: `xvfb-run --auto-servernum tests/test-gtk4-playlist-window.sh "$PWD" --window-contracts`
4. Prove UI/socket parity → verify: `xvfb-run --auto-servernum tests/test-gtk4-playlist-parity.sh "$PWD"`
5. Run both build modes → verify: `tests/test-gtk-build-modes.sh "$PWD" --story e02s04`

## 19. Verification Script

1. Start both modes with identical isolated playlist/config fixtures.
2. Exercise selection, queue, keyboard, wheel, popup, DnD, resize, and shade.
3. Repeat model operations over the control socket.
4. Restart and compare geometry and visibility.
5. Run thread/lock instrumentation and both-mode preflight.

## 20. Risks

- GTK4 DnD is asynchronous and may reorder or outlive owner widgets.
- List redraw or lock changes can stall playback.
- Resize rounding can break skin alignment.
