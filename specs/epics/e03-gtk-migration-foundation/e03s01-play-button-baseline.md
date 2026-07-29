# e03s01: Lock Play-button skin and interaction behavior

<!-- story: e03s01 -->

**type:** test

**risk:** P1

**context:** UI migration

**bcps:** 3

## 1. Summary

Add focused regression evidence for the current skinned Play button before changing its toolkit boundary.

## 2. User

Users who expect the classic Play control to look and react exactly as it does before the GTK migration, and maintainers who need a fast parity signal.

## 3. Problem

`PButton` behavior is coupled to GTK2 events and GDK drawing, but no focused test records its sprite rectangles, edge hit-testing, pressed-state transitions, or callback semantics.

## 4. Value

Future renderer and event migrations can fail immediately when they change a representative classic control instead of relying only on manual whole-window inspection.

## 5. Context

The Play button is a thin, representative path through custom hit testing, event dispatch, skin sprite selection, drawing, and a transport callback. Testing it first creates a tracer bullet without changing production behavior.

## 6. In Scope

- Current normal and pressed Play-button sprite requests.
- Current destination geometry and boundary hit behavior.
- Primary-button press, motion, release, and callback semantics.
- Test/build/distribution wiring.

## 7. Out of Scope

- Production widget refactoring.
- Complete main-window pixel snapshots.
- Other controls, windows, masks, doublesize, docking, menus, or playback.

## 8. Dependencies

Existing GLib `g_test`, GTK2/GDK development files, Xvfb, and the repository source-slice test pattern. No new external package.

## 9. Module Purpose

`xmms/pbutton.c` owns momentary skinned-button state, translates pointer activity into pressed feedback and callback activation, and asks the skin facade to copy the correct sprite rectangle.

## 10. Callers

`xmms/main.c`, `xmms/playlistwin.c`, and `xmms/equalizer.c` create PButtons; `xmms/widget.c` dispatches window events and redraws across their widget lists.

## 11. Contracts

- Only primary-button interactions activate a PButton.
- A valid press and release activates its callback once.
- Leaving and re-entering while pressed updates visual state.
- Hit testing preserves the established top/left-inclusive and bottom/right-exclusive rectangle.
- Normal and pressed states use their established skin source rectangles and fixed destination geometry.

## 12. Requirements

### ADDED: Play-button migration baseline

The regression suite records the existing Play-button draw requests, hit boundaries, pointer-state transitions, and callback count without changing production behavior.

### ADDED: Baseline delivery wiring

The baseline runs under the repository test command, cleans correctly, and is present in source distributions.

## 13. Design

Compile the existing production source slice with a test draw capture and callback counter. Keep assertions on observable coordinates, states, and activation counts rather than GTK object internals. **Reason for Depth:** no new production abstraction is introduced; the source-slice harness is the minimum way to observe legacy behavior before refactoring it.

## 14. Files and Data

Expected targets are `tests/test-pbutton-baseline.c`, `tests/Makefile`, top-level distribution manifests, and package contract assertions. Fixtures remain generated in memory.

## 15. Error Handling

Every mismatch is a self-validating `g_test` assertion with the failing state or coordinate. Test setup failure exits non-zero and never skips silently.

## 16. Security

No security boundary, input file, archive, network, privilege, or persistent data changes.

## 17. Acceptance Criteria

### Scenario SC-e03s01-P1-01: Normal and pressed sprites are stable

```gherkin
Given the historical Play-button geometry and skin coordinates
When the released and pressed states are drawn
Then each state requests its established source rectangle
And both target the established Play-button destination
```

### Scenario SC-e03s01-P1-02: Pointer transitions preserve feedback

```gherkin
Given a primary-button press inside the Play control
When the pointer leaves and re-enters before release
Then pressed feedback follows the inside state
And a valid inside release activates once
```

### Scenario SC-e03s01-P1-03: Edge and button filtering are stable

```gherkin
Given coordinates on every Play-button edge
When hit testing and non-primary presses are evaluated
Then top and left are included
And bottom, right, outside, and non-primary activation are rejected
```

### Scenario SC-e03s01-P1-04: Activation is exactly once

```gherkin
Given a valid primary press and release inside the Play control
When activation is dispatched
Then the callback runs exactly once
And invalid releases run it zero times
```

## 18. Implementation Steps

1. Add the source-slice draw-capture and callback-count harness for SC-e03s01-P1-01 and SC-e03s01-P1-04 → verify: `xvfb-run --auto-servernum make -C tests test-pbutton-baseline && xvfb-run --auto-servernum tests/test-pbutton-baseline`
2. Add pointer transition, edge, and button-filter assertions for SC-e03s01-P1-02 and SC-e03s01-P1-03 → verify: `xvfb-run --auto-servernum tests/test-pbutton-baseline -p /pbutton`
3. Add check, clean, package-contract, and distribution wiring → verify: `tests/test-package-recipes.sh "$PWD" && xvfb-run --auto-servernum make check`

## 19. Verification Script

1. Build the focused test from a clean test directory.
2. Run all `/pbutton` cases under Xvfb.
3. Confirm changing an expected source rectangle makes a case fail.
4. Run the complete suite.
5. Confirm the source archive contains the new test input and no test binary.

## 20. Risks

- Test stubs could accidentally replace behavior instead of observing it; limit stubs to drawing output and external callbacks.
- Theme-dependent screenshots would be flaky; assert draw requests and state instead.
- Production source slicing can retain unresolved symbols; use section garbage collection and narrowly scoped stubs as existing tests do.
