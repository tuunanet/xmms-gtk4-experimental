# e03s02: Route the GTK2 Play button through a toolkit-neutral boundary

<!-- story: e03s02 -->

**type:** refactor

**risk:** P0

**context:** UI migration

**bcps:** 5

## 1. Summary

Extract the Play button's state transitions and sprite draw request into a toolkit-neutral contract, then adapt the production GTK2 PButton path to it with no observable behavior change.

## 2. User

Users who need uninterrupted classic behavior and maintainers who need one proven control path that can be reused by later GTK renderers.

## 3. Problem

The current PButton embeds GTK2/GDK event and drawing types in its shared base, preventing its interaction and sprite-selection behavior from being exercised by a different toolkit without duplication.

## 4. Value

One representative production control becomes portable while the GTK2 application remains fully functional, proving the migration can advance incrementally instead of through a repository-wide rewrite.

## 5. Context

ADR-0001 selects a GTK3 bridge and vertical migration slices. The e03s01 baseline defines the behavior that this internal refactor must preserve.

## 6. In Scope

- Toolkit-neutral Play-button state and pointer-input operations.
- A deterministic skin sprite draw-command shape containing source and destination geometry.
- A GTK2 adapter used by the production Play button.
- Focused unit tests and all e03s01 parity tests.
- Full existing build, test, package, and distribution gates.

## 7. Out of Scope

- Migrating every `Widget` subtype or replacing the complete `Widget` base.
- Replacing all `GdkPixmap`, `GdkGC`, skin storage, masks, or window rendering.
- GTK3/GTK4 production UI, menus, dialogs, playback, or plugin changes.

## 8. Dependencies

GLib scalar types and existing GTK2/GDK APIs. No new external package or framework.

## 9. Module Purpose

`xmms/widget.[ch]` owns common geometry, redraw, and event dispatch for custom controls. `xmms/pbutton.[ch]` owns momentary button behavior. `xmms/skin.[ch]` resolves skin indices and sprite rectangles into toolkit-specific drawing.

## 10. Callers

Main, playlist, and equalizer window constructors create PButtons; widget-list dispatch calls their input handlers; draw loops invoke their draw function; transport callbacks receive activation.

## 11. Contracts

- Public runtime and plugin contracts remain unchanged.
- PButton geometry, source rectangles, state transitions, callback count, and redraw timing remain observationally equivalent to e03s01.
- The new control contract contains no GTK/GDK types and performs no I/O or GTK work.
- Existing PButton callers require no coordinated migration in this story.

## 12. Requirements

### MODIFIED: Play-button state and drawing path

**Before:** GTK2 event objects directly mutate PButton state and PButton drawing directly invokes the GDK-backed skin facade.

**After:** GTK2 adapters translate pointer data to a toolkit-neutral control operation and consume its sprite draw command; users observe identical states, geometry, drawing, and callback activation.

### ADDED: Toolkit-neutral control contract

The selected control state and draw-command header is independently testable and exposes no GTK/GDK types.

## 13. Design

Add one focused `ui_control` module for rectangle hit testing, primary-button state transitions, activation result, and immutable sprite copy commands. Keep GTK2 event translation and actual skin drawing in `pbutton.c`; do not introduce a general renderer backend or migrate unrelated controls. **Reason for Depth:** the small contract is necessary because the same exact interaction and sprite-selection semantics must be consumed by mutually incompatible GTK-major executables without copying behavior.

## 14. Files and Data

Expected changes are a focused `xmms/ui_control.[ch]`, PButton integration, focused tests, and authoritative/generated build manifests. State is in-memory and owned by the containing PButton.

## 15. Error Handling

The pure API rejects unsupported pointer buttons and outside activation through explicit results. It allocates no resources and introduces no recoverable runtime failure path. GTK2 drawing continues to use established diagnostics and behavior.

## 16. Security

No untrusted parsing, filesystem, archive, network, process, privilege, or persistence boundary changes. Coordinate inputs are bounded scalar values used only for hit testing and drawing commands.

## 17. Acceptance Criteria

### Scenario SC-e03s02-P0-01: Contract is toolkit-neutral

```gherkin
Given the new control public header
When its declarations and dependencies are inspected
Then no GTK or GDK type is exposed
And state transitions and draw commands are unit-testable without a display
```

### Scenario SC-e03s02-P0-02: GTK2 behavior remains identical

```gherkin
Given the production GTK2 Play button uses the new contract
When every e03s01 baseline scenario runs
Then all sprite, hit, transition, redraw, and activation observations are unchanged
```

### Scenario SC-e03s02-P0-03: Existing delivery remains green

```gherkin
Given the migration boundary is integrated
When the player, plugins, packages, tests, and source archive are built
Then every existing gate passes
And public plugin, socket, libxmms, configuration, executable, package, and skin contracts remain unchanged
```

## 18. Implementation Steps

1. Add failing pure tests and the minimum toolkit-neutral state/input/draw-command contract for SC-e03s02-P0-01 → verify: `! rg -n 'Gtk|Gdk' xmms/ui_control.h && make -C tests test-ui-control && tests/test-ui-control`
2. Adapt GTK2 PButton event and draw paths to the contract while retaining the legacy outward interface for SC-e03s02-P0-02 → verify: `xvfb-run --auto-servernum make -C tests test-pbutton-baseline test-ui-control && xvfb-run --auto-servernum tests/test-pbutton-baseline && tests/test-ui-control`
3. Run compatibility and delivery gates for SC-e03s02-P0-03 → verify: `make -j"$(nproc)" && xvfb-run --auto-servernum make check && xvfb-run --auto-servernum make distcheck`

## 19. Verification Script

1. Run the pure control test without Xvfb.
2. Inspect the public header for toolkit types.
3. Run the GTK2 PButton baseline under Xvfb.
4. Launch the GTK2 player and exercise Play press, drag-out, drag-in, and release.
5. Run Preflight and distcheck.
6. Compare public compatibility headers against `main`.

## 20. Risks

- A broad generic renderer would create premature depth; constrain the module to one proven control command contract.
- Redraw timing could change even when final pixels match; retain and assert legacy redraw requests.
- Struct layout or callback changes could fan out to all controls; preserve existing outward PButton and Widget interfaces.
- Distcheck may expose missing new source inputs; update authoritative and generated manifests together.
