# e07s02: Exercise the GTK3 transport-control slice

<!-- story: e07s02 -->

**type:** feat

**risk:** P0

**context:** UI migration

**bcps:** 5

## 1. Summary

Extend the GTK3 tracer with a small transport-control slice that consumes the toolkit-neutral control boundary, reports state changes, and proves activation without starting playback.

## 2. User

Maintainers who need evidence that more than one classic transport action can cross the migration boundary without coupling GTK3 to the GTK2 player core.

## 3. Problem

The e03 Play-button proof demonstrates one control, but a main-window slice also needs a repeatable state and activation contract for the neighboring transport path.

## 4. Value

The tracer can expose redraw, pressed-state, valid activation, and invalid activation regressions before transport callbacks are connected to production playback.

## 5. Context

The production UI routes transport actions through playlist and input facades. This story deliberately stops at the shared control contract so the GTK3 process cannot load plugins or open the control socket.

## 6. In Scope

- A bounded set of transport states represented by the toolkit-neutral boundary.
- GTK3 event translation for valid primary activation, release, and invalid pointer/button input.
- Exactly-once activation and no-playback assertions in a deterministic test process.

## 7. Out of Scope

- Starting or simulating audio playback.
- Loading input/output/effect/visualization/general plugins.
- Changing playlist, input, control-socket, plugin ABI, or remote API behavior.
- Porting every main-window control or implementing GTK4 behavior.

## 8. Dependencies

- **GTK3 >= 3.24 — [OK]:** existing migration-proof system dependency.
- Existing `ui_control` boundary and `ui_gtk3_control` adapter.
- e07s01 shell fixture for the control surface and e03 Play-button behavior evidence.

## 9. Module Purpose

The transport adapter translates GTK3 pointer events into the established toolkit-neutral control result. It does not own playback state or call the production controller.

## 10. Callers

The isolated GTK3 transport test calls the adapter. The future GTK3 shell may consume its result. The production GTK2 callbacks and remote-control clients remain outside this story.

## 11. Contracts

- Valid primary activation produces one activation result after the matching press/release sequence.
- Invalid coordinates, buttons, or releases produce no activation.
- Redraw results are observable without invoking playback.
- The test process has no plugin-loader, socket, or audio-device path.

## 12. Requirements

### ADDED: GTK3 transport-control boundary

The GTK3 tracer shall translate the approved transport-control pointer sequence through the toolkit-neutral boundary and expose redraw and activation results for deterministic assertions.

### ADDED: Non-playing isolation

Transport tests shall prove that valid activation does not start playback, load a plugin, read user configuration, or open the control socket.

## 13. Design

Reuse the existing control-result enum and inject a test callback or activation counter at the tracer boundary rather than calling playlist APIs. **Reason for Depth:** a callback-free test seam proves GTK3 event behavior while preserving the production transport and plugin contracts.

## 14. Files and Data

Expected changes are a focused transport fixture or adapter extension, GTK3 g_test coverage, Meson registration, and documentation of the non-playing boundary. No playlist or plugin source is changed.

## 15. Error Handling

Invalid event objects, unsupported buttons, out-of-bounds coordinates, and unmatched releases return the existing no-op result. Test setup failures fail the test with actionable assertions; runtime playback errors are not applicable because playback is forbidden.

## 16. Security

The test uses in-memory events and counters only. It has no network, file, archive, plugin, credential, or privilege-sensitive path.

## 17. Acceptance Criteria

### Scenario SC-e07s02-P0-01: Valid transport activation is bounded

```gherkin
Given a GTK3 transport control with an injected activation counter
When a valid primary press and release occurs inside its bounds
Then the control reports the expected redraw and one activation
And the activation counter changes without starting playback
```

### Scenario SC-e07s02-P0-02: Invalid transport activation is rejected

```gherkin
Given a GTK3 transport control
When an unsupported button, out-of-bounds coordinate, or unmatched release occurs
Then the control reports no activation
And no plugin, socket, configuration, or audio path is invoked
```

## 18. Implementation Steps

1. Extend the GTK3 control fixture with the bounded transport states and injected activation observation (ref: ADR-0001-staged-gtk-migration.md) → verify: `tests/test-gtk3-main-window-shell.sh "$PWD" --transport`
2. Add valid, invalid, exactly-once, and non-playing isolation tests to the GTK3 target (ref: e03s03-gtk3-play-button-proof.md) → verify: `xvfb-run --auto-servernum meson test -C build-meson gtk3-main-window-transport`

## 19. Verification Script

1. Build the GTK3 transport test target.
2. Run it under Xvfb.
3. Confirm valid press/release produces one activation and expected redraw result.
4. Confirm invalid input produces no activation.
5. Confirm the test has no dependency or call path to the production plugin loader, control socket, or audio device.

## 20. Risks

- Reusing production callbacks could start playback or cross the process boundary; use an injected observation seam.
- Event-sequence tests can pass while duplicate activation remains possible; assert the counter after repeated release events.
- Adding too many controls would hide the boundary under a broad port; keep the slice bounded and fixture-driven.
