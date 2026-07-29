# e02s03: Run the classic main player as a GTK4 X11 window

<!-- story: e02s03 -->

**type:** feat

**risk:** P0

**context:** domain

**bcps:** 8

## 1. Summary

Deliver an experimental GTK4 main player window whose transport, displays, custom controls, menus, heartbeat, and remote-control behavior match the GTK2 release path.

## 2. User

XMMS users exercising the primary player controls and maintainers validating the first end-to-end GTK4 product slice.

## 3. Problem

The main composition root uses legacy signals, mutable event structs, GtkItemFactory, gtk_main, GTK timers, direct windows, and GTK2 redraw behavior.

## 4. Value

A user can play and control audio through the classic GTK4 window, proving the migration reaches the unchanged playback pipeline rather than only compiling UI helpers.

## 5. Context

The main UI is a skinned facade over playlist/input/output APIs. GTK4 replaces event signals with controllers and removes gtk_main; remote control already reaches the same core operations.

## 6. In Scope

- Main window shell and fixed skin output.
- Transport, seek, volume, balance, title, time, built-in status and menus.
- Pointer, motion, wheel, key, focus, redraw, timer, and shutdown behavior.
- UI-versus-control-socket parity.

## 7. Out of Scope

- Playlist, equalizer, preferences, and plugin dialogs beyond safe disabled placeholders.
- Changing playback algorithms, commands, or skin coordinates.

## 8. Dependencies

- **[OK] GtkGestureClick/EventControllerMotion/EventControllerKey:** supported GTK4 input APIs.
- **[OK] GMainContext/GApplication APIs:** supported GTK4 lifecycle replacement.
- e02s01 feasibility and e02s02 rendering/build foundations.

## 9. Module Purpose

`xmms/main.c` composes the process and main window; custom widget modules draw fixed controls and translate hit-tested interactions into core calls.

## 10. Callers

Users, control-socket commands, playlist/input callbacks, timers, skin reload, plugin status, and application startup/shutdown.

## 11. Contracts

- Existing core APIs and control commands remain unchanged.
- GTK calls and UI mutations remain on the owning main context.
- The ~10 ms heartbeat retains EOF, output-failure, visualization, and socket semantics.
- Custom hit regions and callback boundaries remain identical.

## 12. Requirements

### MODIFIED: Main player toolkit

**Before:** The classic main player is a GTK2 window using legacy signals, pixmaps, item factories, and gtk_main.

**After:** The same user-visible window and core behavior run through GTK4 drawing, controllers, actions, and main-context lifecycle.

### MODIFIED: Custom widget events

**Before:** Raw GTK2 button/motion events are dispatched into widget lists.

**After:** GTK4 controllers preserve the same coordinates, state transitions, drags, and callbacks.

## 13. Design

Adapt the existing custom widget list rather than replace it with stock GTK buttons. **Reason for Depth:** fixed WinAmp skin geometry and hit testing are compatibility contracts already isolated from playback logic.

## 14. Files and Data

- `xmms/main.[ch]`, `widget.[ch]`, control modules, menu/action helpers.
- GTK4 main-window, event, lifecycle, and parity fixtures.
- Existing config fields and skin assets remain unchanged.

## 15. Error Handling

Unsupported backend, failed native surface creation, timer registration, missing action targets, and playback errors remain actionable and nonfatal where currently recoverable. Shutdown must be bounded.

## 16. Security

No new external data boundary is added. Event coordinates and action identifiers must be validated, and native X11 operations remain confined to ADR-0001's adapter.

## 17. Acceptance Criteria

### SC-e02s03-P0-01: Main controls reach unchanged core behavior

```gherkin
Given GTK4 XMMS with a playable fixture track
When the user operates transport, seek, volume, balance, menus, and keyboard controls
Then the same core APIs and configuration values are observed as in GTK2 mode
```

### SC-e02s03-P0-02: Custom hit testing remains exact

```gherkin
Given every documented main-window control boundary
When clicks, drags, motion, and wheel events occur inside and outside each region
Then only the expected widget state and callback changes
```

### SC-e02s03-P0-03: Remote and UI transport agree

```gherkin
Given GTK4 XMMS is running
When equivalent operations arrive from the main window and control socket
Then playback, time, volume, and visible state transitions are identical
```

### SC-e02s03-P0-04: Heartbeat and shutdown remain safe

```gherkin
Given playback, EOF, output failure, visualization data, and queued socket commands
When the GTK4 main context processes the heartbeat and shutdown
Then each condition follows the established order on the main thread
And cleanup terminates without an unbounded nested loop
```

## 18. Implementation Steps

1. Add main-window interaction contracts → verify: `xvfb-run --auto-servernum tests/test-gtk4-main-window.sh "$PWD"`
2. Adapt custom widget event dispatch → verify: `xvfb-run --auto-servernum tests/test-gtk4-widget-events.sh "$PWD"`
3. Port main shell, actions, heartbeat, redraw, and lifecycle → verify: `xvfb-run --auto-servernum tests/test-gtk4-main-window.sh "$PWD" --full`
4. Prove UI/socket transport parity → verify: `xvfb-run --auto-servernum tests/test-gtk4-transport-parity.sh "$PWD"`
5. Run both build modes → verify: `tests/test-gtk-build-modes.sh "$PWD" --story e02s03`

## 19. Verification Script

1. Start the experimental GTK4 build under X11 with an isolated config.
2. Load a fixture track and operate every main control by mouse and keyboard.
3. Repeat transport and volume operations through `libxmms` remote calls.
4. Exercise shade and double-size states and reload the skin.
5. Trigger EOF and a controlled output failure, then quit and confirm clean shutdown.

## 20. Risks

- Event-controller propagation can subtly alter drag/click behavior.
- Main-loop replacement can reorder plugin cleanup or socket work.
- Disabled unported windows must not silently mutate persisted visibility state.
