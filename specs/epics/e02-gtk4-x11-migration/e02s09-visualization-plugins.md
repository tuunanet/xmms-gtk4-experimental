# e02s09: Run bundled visualization plugins under GTK4

<!-- story: e02s09 -->

**type:** feat

**risk:** P0

**context:** domain

**bcps:** 8

## 1. Summary

Port Blur Scope, Simple Spectrum Analyzer, and OpenGL Spectrum to GTK4 while freezing `VisPlugin`, callback lifecycle, data shapes, timing, discovery, settings, and identifiers.

## 2. User

XMMS users running bundled visualizations and third-party visualization authors.

## 3. Problem

All bundled visualizer binaries directly depend on GTK2 and removed GDK drawing/thread APIs, yet visualization callbacks are timing-sensitive and externally extensible.

## 4. Value

Every bundled visualizer remains available in the GTK4 release and third-party source plugins retain the same programming interface.

## 5. Context

`get_vplugin_info` is loaded dynamically and runtime fields are injected. Data contracts are `gint16[2][512]` PCM and `gint16[2][256]` frequency. Old GTK2-linked binaries are not supported.

## 6. In Scope

- Visualization discovery/lifecycle/data fixture.
- Cairo GTK4 ports of Blur Scope and Simple Spectrum.
- GTK4-compatible OpenGL Spectrum X11/GLX lifecycle.
- Timing, main-thread, ABI, dependency, config, and identifier verification.

## 7. Out of Scope

- Visualization ABI changes.
- New render algorithms or redesigned appearance.
- Supporting old GTK2 `.so` files or Wayland GL.

## 8. Dependencies

- e02s01 ABI baseline and e02s05 X11 adapter policy.
- **[OK] GTK4/Cairo:** 2D visualizer rendering.
- **[OK] OpenGL/GLX on X11:** preserved optional OpenGL path.

## 9. Module Purpose

The core provides timed audio data to dynamically loaded visualization plugins; each plugin renders its own window without blocking playback.

## 10. Callers

Plugin enumeration, visualization core, audio callbacks, preferences, shutdown, CI, packaging, and users.

## 11. Contracts

- `VisPlugin` layout and `get_vplugin_info` remain unchanged.
- PCM/frequency array shapes and channel semantics remain exact.
- Lifecycle order, disable callback, discovery paths, and identifiers remain stable.
- GTK rendering occurs on the main context and callbacks stay within measured budgets.

## 12. Requirements

### MODIFIED: Bundled visualizer toolkit

**Before:** Three bundled visualizers use GTK2/GDK2 drawing and thread APIs.

**After:** All three build and run with GTK4/X11 without changing plugin contracts or visible intent.

### ADDED: Visualization compatibility fixture

The suite SHALL verify discovery, runtime field injection, lifecycle order, data shapes, timing, and unload behavior.

## 13. Design

Keep core visualization ABI and timing untouched; port plugin-owned windows in place. **Reason for Depth:** the clean interface is already GTK-independent, so source recompilation is safer than introducing an adapter or ABI revision.

## 14. Files and Data

- `Visualization/blur_scope`, `sanalyzer`, and `opengl_spectrum` GTK-facing sources/build files.
- `xmms/visualization.c` tests only where needed for existing contracts.
- Recording fixture plugin and deterministic PCM/frequency samples.

## 15. Error Handling

Unavailable GLX, failed context/window creation, plugin unload, destroyed windows, and callback overruns disable the affected visualizer recoverably without crashing playback.

## 16. Security

Plugins execute in-process. Validate dimensions/lifetimes, avoid stale GL/X11 handles, keep GTK on the main thread, and preserve bounded copies of fixed audio arrays.

## 17. Acceptance Criteria

### SC-e02s09-P0-01: Lifecycle contracts remain exact

```gherkin
Given a recording visualization fixture
When XMMS discovers, enables, renders, disables, and unloads it
Then entry points, injected fields, callback order, and disable behavior match
```

### SC-e02s09-P0-02: Data and timing remain compatible

```gherkin
Given repeated deterministic PCM and frequency frames
When visualization callbacks consume them
Then buffers retain exact dimensions and channel semantics
And callback budgets and main-thread ownership are not regressed
```

### SC-e02s09-P0-03: Bundled visualizers render under GTK4

```gherkin
Given deterministic audio fixtures and the GTK4 X11 backend
When Blur Scope, Simple Spectrum, and OpenGL Spectrum are enabled and configured
Then each renders, persists settings, and closes cleanly
```

### SC-e02s09-P0-04: ABI and dependencies comply

```gherkin
Given the produced visualization shared objects
When ABI and dynamic dependencies are inspected
Then the frozen interface is unchanged
And no GTK2/GDK2 dependency exists in GTK4 mode
```

## 18. Implementation Steps

1. Add visualization lifecycle/data fixture → verify: `xvfb-run --auto-servernum tests/test-visualization-plugin-contract.sh "$PWD"`
2. Port Blur Scope and Simple Spectrum → verify: `xvfb-run --auto-servernum tests/test-gtk4-visualizations.sh "$PWD" --plugins blur-scope,sanalyzer`
3. Port OpenGL Spectrum → verify: `xvfb-run --auto-servernum tests/test-gtk4-visualizations.sh "$PWD" --plugins opengl-spectrum`
4. Prove timing and thread safety → verify: `xvfb-run --auto-servernum tests/test-visualization-timing.sh "$PWD" --toolkit-matrix`
5. Check ABI and dependencies → verify: `tests/test-plugin-abi.sh "$PWD" && tests/test-gtk-plugin-dependencies.sh "$PWD" visualization`

## 19. Verification Script

1. Feed deterministic PCM/frequency fixtures through the recording plugin.
2. Start/configure/stop each bundled visualizer repeatedly.
3. Exercise missing GLX and window-destruction paths.
4. Measure callback budgets and main-thread ownership.
5. Inspect exports and GTK dependencies of all visualizer `.so` files.

## 20. Risks

- OpenGL context lifecycle differs substantially in GTK4.
- Render scheduling can block or race playback.
- Headless GL availability can hide optional path failures; CI must classify it explicitly.
