# e02s06: Configure XMMS through GTK4 dialogs and helpers

<!-- story: e02s06 -->

**type:** feat

**risk:** P0

**context:** domain

**bcps:** 8

## 1. Summary

Port preferences, plugin management, file/folder selection, skin selection, messages, about windows, and GTK-facing libxmms helpers to supported GTK4 APIs.

## 2. User

XMMS users configuring the player and developers consuming libxmms UI helpers.

## 3. Problem

Core dialogs rely on removed containers, GtkObject, GtkItemFactory, synchronous chooser APIs, legacy signals, and GTK2 ownership conventions.

## 4. Value

Users can complete normal configuration workflows under GTK4 while GTK-independent libxmms consumers retain compatibility and GTK-facing source changes are documented.

## 5. Context

GTK4 file selection is asynchronous. Public GTK-independent libxmms APIs are frozen; GTK-facing helpers may require documented source migration where GTK4 has no equivalent.

## 6. In Scope

- Preferences and plugin-family lists/actions.
- File, multiple-file, directory, playlist, skin, message, and about flows.
- Async chooser state machines and owner destruction.
- GTK-facing libxmms helper migration and compatibility documentation.

## 7. Out of Scope

- Individual bundled plugin-owned UIs, handled in e02s07–e02s09.
- GTK-independent API or socket changes.
- UI redesign.

## 8. Dependencies

- **[OK] GtkFileDialog:** GTK 4.10+ asynchronous chooser API, available in GTK 4.22.
- **[OK] GAction/GMenu and standard GTK4 widgets:** supported replacements.
- Complete core GTK4 window foundation.

## 9. Module Purpose

Core dialogs collect configuration and invoke existing domain/plugin APIs; libxmms helpers expose reusable client UI behavior at a documented source boundary.

## 10. Callers

Main menus, playlist actions, preferences, plugin enumeration, skin loading, external libxmms source consumers, and shutdown.

## 11. Contracts

- GTK-independent libxmms ABI/API is unchanged.
- Apply/cancel and persisted identifiers remain unchanged.
- Async results cannot mutate destroyed owners.
- Dialog GTK operations run on the main context.

## 12. Requirements

### MODIFIED: Core dialogs

**Before:** Synchronous GTK2 dialogs and legacy widget APIs return or mutate state inline.

**After:** GTK4 dialogs preserve outcomes through explicit asynchronous ownership and callbacks.

### MODIFIED: GTK-facing libxmms helpers

**Before:** Helpers expose GTK2 types/semantics.

**After:** Documented GTK4 source APIs replace only toolkit-bound helpers while GTK-independent APIs remain frozen.

## 13. Design

Separate chooser completion from domain mutations with explicit request contexts. **Reason for Depth:** asynchronous callbacks can outlive windows, so ownership and cancellation must be modeled rather than emulating nested synchronous loops.

## 14. Files and Data

- Preferences, menu, dialog, file-selection, skin-selection, and message modules.
- `libxmms` GTK-facing helper headers/sources and migration documentation.
- Async and repeated-lifecycle test fixtures.

## 15. Error Handling

Cancel is a normal result. Destroyed owners, unavailable chooser services, invalid files, stale plugin rows, and repeated requests are handled without UAF, nested main loops, or fatal errors.

## 16. Security

Chosen paths and plugin metadata are untrusted. Preserve path validation and escaping, do not format untrusted text as markup, and explicitly own callback data.

## 17. Acceptance Criteria

### SC-e02s06-P0-01: Preferences retain behavior

```gherkin
Given enumerated plugin families and current configuration
When users select, enable, disable, configure, apply, or cancel in GTK4
Then the same plugin APIs and persisted identifiers are used
```

### SC-e02s06-P0-02: Async chooser outcomes are safe

```gherkin
Given open, save, multiple-file, and folder requests
When users accept, cancel, repeat, or destroy the parent
Then exactly one valid completion occurs
And destroyed owners are never mutated
```

### SC-e02s06-P0-03: libxmms compatibility is bounded

```gherkin
Given an existing GTK-independent libxmms client and a documented GTK-facing fixture
When both compile against the migration result
Then the independent client is unchanged
And only documented GTK4 source adaptations are needed by the UI fixture
```

## 18. Implementation Steps

1. Add dialog and helper contracts → verify: `xvfb-run --auto-servernum tests/test-gtk4-dialogs.sh "$PWD"`
2. Port preferences and core dialogs → verify: `xvfb-run --auto-servernum tests/test-gtk4-preferences.sh "$PWD"`
3. Implement explicit async chooser flows → verify: `xvfb-run --auto-servernum tests/test-gtk4-file-dialogs.sh "$PWD"`
4. Port/document GTK-facing libxmms helpers → verify: `tests/test-libxmms-api.sh "$PWD" && xvfb-run --auto-servernum tests/test-gtk4-libxmms-ui.sh "$PWD"`
5. Run both build modes → verify: `tests/test-gtk-build-modes.sh "$PWD" --story e02s06`

## 19. Verification Script

1. Exercise every preferences tab and plugin action.
2. Run each chooser through accept, cancel, repeated-open, and parent-destroy paths.
3. Repeat dialog open/close 100 times under memory instrumentation.
4. Compile independent and GTK-facing libxmms fixtures.
5. Run both-mode preflight with isolated config directories.

## 20. Risks

- Async conversion can introduce UAF or duplicate completions.
- Toolkit-facing helper changes can accidentally leak into frozen APIs.
- Native chooser automation is limited; one recorded manual acceptance pass remains required.
