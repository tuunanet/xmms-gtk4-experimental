# e02s08: Configure Effect and General plugins under GTK4

<!-- story: e02s08 -->

**type:** feat

**risk:** P0

**context:** domain

**bcps:** 5

## 1. Summary

Port every bundled Effect and General plugin UI to GTK4 while preserving PCM transforms, sessions, remote-control behavior, identifiers, and public interfaces.

## 2. User

XMMS users enabling effects and general-purpose integrations, plus plugin authors.

## 3. Problem

These optional plugins mix GTK2 configuration windows with processing, session, and external-control lifecycles; a UI port can accidentally change non-UI behavior.

## 4. Value

Effects and bundled integrations remain available and configurable in the GTK4 release without protocol or ABI drift.

## 5. Context

Effect callbacks run in the audio path; GTK work must never move there. General plugins may integrate sockets or sessions, so UI migration must preserve external-control boundaries.

## 6. In Scope

- Every bundled Effect/General about and configure UI.
- Persisted settings, lifecycle fixtures, ABI tests, dynamic dependency checks.
- Explicit optional-plugin build classification.

## 7. Out of Scope

- Effect algorithm changes.
- General plugin protocol/session redesign.
- Plugin retirement or identifier changes.

## 8. Dependencies

- e02s01 ABI fixtures and e02s06 dialog patterns.
- Existing optional libraries on Ubuntu 26.04.
- GTK 4.22 experimental build mode.

## 9. Module Purpose

Effect plugins transform PCM; General plugins provide ancillary integrations. Their UIs configure those unchanged domain operations.

## 10. Callers

Plugin enumeration/preferences, audio pipeline, session and control integrations, CI, packaging, and users.

## 11. Contracts

- `EffectPlugin`/`GeneralPlugin` layouts, callbacks, entry points, paths, and identifiers remain frozen.
- No GTK work executes from audio or worker callbacks.
- Socket/session semantics and persisted settings remain unchanged.
- Each `.so` links one toolkit only.

## 12. Requirements

### MODIFIED: Effect/General plugin UIs

**Before:** Bundled about/configure windows use GTK2.

**After:** All available bundled windows use GTK4 while non-UI behavior remains unchanged.

### ADDED: Family-wide lifecycle proof

Each available plugin SHALL be loaded, configured, closed, and unloaded through a recording host fixture.

## 13. Design

Port UI files in place and retain domain callbacks. **Reason for Depth:** preserving the existing plugin boundary minimizes audio-thread and protocol risk while fixture hosts expose lifecycle mistakes.

## 14. Files and Data

- GTK-facing files under `Effect/` and `General/`.
- Family host fixtures, settings samples, ABI/dependency checks.
- Relevant Autotools, CI, and package manifests.

## 15. Error Handling

Unavailable services, malformed values, repeated dialogs, plugin unload, and shutdown remain recoverable; UI callbacks must not outlive plugins.

## 16. Security

General plugins may display external data or expose controls. Escape displayed values, preserve authentication/protocol boundaries, and review callback lifetime and thread handoff.

## 17. Acceptance Criteria

### SC-e02s08-P0-01: All available plugin UIs work

```gherkin
Given every available bundled Effect and General plugin
When its GTK4 UI opens, applies, cancels, reopens, and closes
Then settings and lifecycle behavior match GTK2
```

### SC-e02s08-P0-02: Non-UI behavior is unchanged

```gherkin
Given recording audio, session, and socket fixtures
When the GTK4-port plugins run
Then transforms, callbacks, identifiers, and external-control results match the frozen baseline
And GTK calls occur only on the main thread
```

### SC-e02s08-P0-03: Dependencies are pure

```gherkin
Given produced Effect and General shared objects
When symbols and dependencies are inspected
Then public ABI matches and each object links only the selected GTK major
```

## 18. Implementation Steps

1. Add fixture-driven family contracts → verify: `xvfb-run --auto-servernum tests/test-gtk4-effect-general-plugin-uis.sh "$PWD"`
2. Port all Effect UIs → verify: `xvfb-run --auto-servernum tests/test-gtk4-effect-general-plugin-uis.sh "$PWD" --family effect`
3. Port all General UIs → verify: `xvfb-run --auto-servernum tests/test-gtk4-effect-general-plugin-uis.sh "$PWD" --family general`
4. Check ABI and dependencies → verify: `tests/test-plugin-abi.sh "$PWD" && tests/test-gtk-plugin-dependencies.sh "$PWD" effect general`
5. Verify both modes and optional classifications → verify: `tests/test-gtk-build-modes.sh "$PWD" --story e02s08`

## 19. Verification Script

1. Build every available Effect/General plugin in both isolated modes.
2. Exercise all UI lifecycle paths through fixture hosts.
3. Compare transform, session, and socket traces.
4. Inspect exports and dynamic dependencies.
5. Confirm no GTK call occurs on audio/worker threads.

## 20. Risks

- UI state may currently be read directly from audio callbacks.
- Optional integrations can escape normal CI coverage.
- General plugin changes can affect external-control compatibility.
