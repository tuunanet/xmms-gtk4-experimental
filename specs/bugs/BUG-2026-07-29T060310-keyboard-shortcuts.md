# BUG-2026-07-29T060310: Keyboard shortcuts do not activate commands

## Problem

XMMS receives keyboard input while its main window is focused, but menu-defined
shortcuts such as Ctrl+P (Preferences), Ctrl+Q (Exit), and the classic playback
keys do not activate their commands. These shortcuts should invoke the same
callbacks as the corresponding menu items.

Reproduction environment:

- GTK+ 2.24.33 on X11 under Xvfb
- clean temporary XMMS home and control-socket directory
- current `main` build

Minimal reproduction:

1. Start XMMS with the main window focused.
2. Press Ctrl+P.
3. Observe that the Preferences window does not open.
4. Press Ctrl+Q.
5. Observe that XMMS remains running.

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

A clean Xvfb session reproduced the report. Synthetic X11 key press/release
events were delivered to the visible main player window. Ctrl+P did not create
a Preferences window, and Ctrl+Q did not terminate XMMS. The process remained
responsive and mouse-driven UI startup completed normally.

### Isolate

The failure is isolated to the main-window keyboard event boundary. Menu items
successfully register accelerators in the main accelerator group, and the group
is attached to the main GTK window. Playlist and equalizer windows forward
unhandled keys to the same main-window event path, so this boundary affects all
three classic windows.

The main-window key handler implements arrow-key volume and seek behavior, but
reports every key event as handled, including keys it does not recognize. Under
GTK2 signal dispatch, that handled result prevents the window's normal
accelerator processing from running.

### Hypothesize

1. **Main handler consumes unrecognized events before GTK accelerator dispatch.**
   Falsification: verify that the handler returns handled for its default case
   and that registered shortcuts fail while the event reaches the focused main
   window.
2. **Accelerators were never registered or attached.**
   Falsification: inspect menu construction and window setup for creation,
   population, and attachment of the shared accelerator group.
3. **The window does not receive keyboard events.**
   Falsification: deliver events directly to the mapped main window and verify
   that its custom keyboard path is connected.

### Verify

Hypothesis 1 is confirmed. Runtime evidence shows two independently registered
accelerators fail despite delivery to the mapped main window. Code-path evidence
shows the accelerator group is both populated and attached, falsifying
hypothesis 2. The connected main-window handler receives the same event route
used by the reproduction, falsifying hypothesis 3. Its unconditional handled
result is therefore the single root cause.

This is a long-standing GTK2 compatibility regression rather than a new feature
or a recurrence of a registered project bug.

Risk level: Low. The correction is confined to keyboard event delegation and
must preserve the custom arrow-key volume/seek behavior.

## TDD Fix Plan

1. **RED**: Add an Xvfb-backed GTK regression test that sends an unrecognized-by-
   the-custom-handler key matching a registered main-window accelerator and
   observes that the accelerator callback runs.
   **GREEN**: Delegate the main handler's default case to the attached main
   accelerator group while continuing to consume keys handled by custom logic.
   **verify**: `xvfb-run --auto-servernum make -C tests -f Makefile check`

2. **RED**: Extend the behavioral test to verify that a shortcut forwarded from
   another classic window reaches a main-window accelerator, while an arrow key
   remains handled by the existing custom path.
   **GREEN**: Make only the minimum event-forwarding adjustment needed for the
   three classic windows to share the corrected main shortcut behavior.
   **verify**: `xvfb-run --auto-servernum make check`

**REFACTOR**: Remove any duplicated test setup, keep GTK operations on the main
thread, and retain the historical shortcut definitions and callbacks unchanged.

## Acceptance Criteria

- [x] Main-window shortcuts invoke their existing menu callbacks.
- [x] The same main shortcuts continue through the shared main-window accelerator path when forwarded by the playlist or equalizer window.
- [x] Existing arrow-key volume, seek, playlist navigation, and equalizer control branches remain unchanged.
- [x] Mouse/menu behavior and historical shortcut bindings remain unchanged.
- [x] The focused GTK regression tests pass under Xvfb.
- [x] `make lint` passes.
- [x] `make -j"$(nproc)" && xvfb-run --auto-servernum make check` passes.
- [ ] Manual runtime checks cover Ctrl+P, Ctrl+Q, X/C/V, and arrow keys.
- [x] Source and test paths continue to trigger the existing full CI workflow; no workflow path-filter change is required.

## Resolution

The main-window handler now declines keys outside its custom arrow-key controls,
allowing GTK2 to activate the existing menu accelerators. An isolated X11
regression test launches the real player and observes both Preferences and Exit
shortcuts. Focused RED/GREEN evidence and the full lint, build, and Xvfb-backed
test suite passed on 2026-07-29.
