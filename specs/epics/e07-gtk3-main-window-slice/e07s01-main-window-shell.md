# e07s01: Render the GTK3 main-window shell and geometry fixture

<!-- story: e07s01 -->

**type:** feat

**risk:** P1

**context:** UI migration

**bcps:** 5

## 1. Summary

Extend the isolated GTK3 migration tracer with a deterministic main-window shell that represents the classic XMMS frame, content regions, and display surface without starting the production player.

## 2. User

Maintainers and contributors who need executable geometry and rendering evidence before migrating another production UI surface.

## 3. Problem

The existing GTK3 proof covers one control but does not prove that the classic main-window coordinate contract can be represented without importing GTK2 window code or user state.

## 4. Value

A focused shell fixture catches geometry, rendering, and GTK-major boundary regressions before transport behavior or a production toolkit decision depends on them.

## 5. Context

ADR-0001 stages the migration through GTK3 and requires vertical slices. e03 proved the Play-button boundary; e06 established the GNOME C rules that new migration modules must follow.

## 6. In Scope

- A GTK3-only shell model for the approved classic main-window dimensions and representative frame/display regions.
- Deterministic in-memory skin or pixel fixtures and representative rendering assertions.
- A separate GTK3 test target that does not initialize the production player or load plugins.

## 7. Out of Scope

- Production `xmms` toolkit changes.
- Complete skin parity, playlist/equalizer windows, window docking, or user skin loading.
- Playback, configuration, socket, plugin, or audio-device initialization.

## 8. Dependencies

- **GTK3 >= 3.24 — [OK]:** already an existing, system-provided migration-proof dependency selected by Meson.
- Existing GLib, GdkPixbuf, Cairo, Meson, and Xvfb test infrastructure.
- e03 toolkit-neutral control boundary and e06 GNOME C foundation policy.

## 9. Module Purpose

The new shell fixture owns only the GTK3 presentation geometry needed to prove a main-window migration seam. It must not become a second application composition root.

## 10. Callers

The GTK3 shell test target and Meson test runner call the fixture. The production GTK2 player, plugin loader, control socket, and installed package do not call it.

## 11. Contracts

- Classic main-window dimensions and representative coordinates remain explicit and testable.
- The GTK3 target links GTK3 and does not link GTK2.
- Rendering is deterministic under Xvfb and uses no user files or persistent state.
- Existing production GTK2 output and package artifacts remain unchanged.

## 12. Requirements

### ADDED: GTK3 main-window shell geometry

The migration tracer shall expose a deterministic GTK3 shell with the approved classic main-window dimensions, frame regions, and display fixture so tests can assert representative rendered output.

### ADDED: Shell process isolation

The shell test shall remain a separately linked GTK3 target and shall not initialize playback, plugins, configuration, or the control socket.

## 13. Design

Represent the shell geometry as a small owned fixture consumed by a GTK3 drawing adapter, then render into an offscreen Cairo surface for pixel assertions. **Reason for Depth:** an explicit fixture prevents host themes, user skins, and GTK2 globals from masking geometry regressions.

## 14. Files and Data

Expected changes are a focused GTK3 shell/fixture module, a GTK3 test source, Meson test registration, and narrowly scoped architecture documentation. No binary skin assets or generated build products are added.

## 15. Error Handling

The test exits non-zero when GTK3 initialization, fixture creation, surface creation, or an expected geometry/pixel assertion fails. Missing GTK3 remains an actionable Meson dependency failure under the existing proof option.

## 16. Security

The fixture uses compiled or in-memory data only. It performs no network access, archive extraction, plugin loading, privilege change, or persistent write.

## 17. Acceptance Criteria

### Scenario SC-e07s01-P1-01: Shell geometry is explicit

```gherkin
Given the approved classic main-window geometry fixture
When the GTK3 shell is created
Then its dimensions and representative frame/display regions match the fixture
And no production GTK2 window is initialized
```

### Scenario SC-e07s01-P1-02: Shell rendering is deterministic

```gherkin
Given deterministic in-memory shell pixels
When the GTK3 shell renders under Xvfb
Then representative output pixels match the fixture
And a missing or invalid fixture fails the test instead of falling back to user state
```

## 18. Implementation Steps

1. Add the owned GTK3 shell geometry and deterministic fixture (ref: ADR-0001-staged-gtk-migration.md) → verify: `tests/test-gtk3-main-window-shell.sh "$PWD" --geometry`
2. Add offscreen GTK3 rendering assertions and register the shell test in Meson (ref: e03s03-gtk3-play-button-proof.md) → verify: `xvfb-run --auto-servernum meson test -C build-meson gtk3-main-window-shell`

## 19. Verification Script

1. Configure the project with the GTK3 proof enabled.
2. Build the GTK3 shell test target.
3. Run the shell test under Xvfb.
4. Confirm dimensions and representative pixels match the documented fixture.
5. Confirm the production `xmms` target remains a separate GTK2-linked target.

## 20. Risks

- Reusing GTK2 globals could accidentally create a mixed-toolkit process; keep the fixture and target dependency lists explicit.
- Host theme rendering could make assertions unstable; use offscreen fixtures and representative pixel checks.
- Shell scope could expand into a full window port; keep only geometry and rendering in this story.
