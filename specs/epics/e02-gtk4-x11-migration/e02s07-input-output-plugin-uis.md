# e02s07: Configure Input and Output plugins under GTK4

<!-- story: e02s07 -->

**type:** feat

**risk:** P0

**context:** domain

**bcps:** 5

## 1. Summary

Port every bundled Input and Output plugin's about, configure, file-info, and error UI to GTK4 while preserving plugin interfaces and audio behavior.

## 2. User

XMMS users configuring decoders and output devices, plus third-party plugin authors relying on stable contracts.

## 3. Problem

Optional plugin UIs directly use GTK2, but broad rewrites risk altering decoder/output callbacks or silently excluding plugins from GTK4 packages.

## 4. Value

All bundled decoder and output choices remain configurable after migration without changing public plugin APIs.

## 5. Context

Plugin retirement is out of scope. Plugins may be recompiled and source-ported, but old GTK2-linked binaries need not load. Optional dependency availability must be reported honestly.

## 6. In Scope

- Every bundled Input/Output GTK-facing source file.
- About/configure/file-info/error workflows and persisted settings.
- Fixture coverage, ABI checks, optional-build classification, and `.so` dependency inspection.

## 7. Out of Scope

- Decoder, demuxer, device, latency, or audio-quality modernization.
- Loading historical GTK2-linked binaries.
- Plugin interface changes.

## 8. Dependencies

- e02s01 plugin ABI fixtures and e02s06 dialog conventions.
- Existing optional codec/device libraries on Ubuntu 26.04.
- **[OK] GTK 4.22:** sole toolkit in experimental plugin builds.

## 9. Module Purpose

Input plugins decode sources; Output plugins deliver PCM. Their optional UIs only configure or report state and must not redefine processing contracts.

## 10. Callers

Plugin enumeration, preferences, file-info actions, playback setup, users, CI, and packaging.

## 11. Contracts

- `InputPlugin` and `OutputPlugin` layouts, callbacks, entry points, discovery paths, and identifiers remain frozen.
- Non-UI audio paths retain existing tests and behavior.
- Each `.so` links only the selected toolkit.
- Missing optional dependencies are classified, never silently ignored.

## 12. Requirements

### MODIFIED: Input/Output plugin UIs

**Before:** Bundled plugin dialogs use GTK2 APIs.

**After:** Every available bundled plugin dialog uses GTK4 with unchanged settings and plugin callbacks.

### MODIFIED: Optional plugin delivery

**Before:** Build coverage may not prove all plugin UIs or dynamic GTK dependencies.

**After:** CI records each plugin as built/tested or unavailable for an explicit dependency reason.

## 13. Design

Use one host fixture to load each real plugin UI through the frozen interface. **Reason for Depth:** uniform lifecycle testing catches ownership and linkage failures without introducing a new plugin abstraction.

## 14. Files and Data

- GTK-facing files under `Input/` and `Output/` only as required.
- Plugin-host fixtures, settings fixtures, ABI manifest, and dependency scanner.
- Autotools conditionals, distribution manifests, CI/package dependencies.

## 15. Error Handling

Unavailable devices/codecs, invalid settings, missing metadata, repeated dialogs, and destroyed parents remain recoverable. Build skips must state the missing dependency.

## 16. Security

Plugin metadata, filenames, streams, and device names are untrusted. Escape displayed text, preserve existing validation, and review callback ownership and integer dimensions.

## 17. Acceptance Criteria

### SC-e02s07-P0-01: All available plugin UIs work

```gherkin
Given each bundled Input and Output plugin available on Ubuntu 26.04
When its about, configure, file-info, or error UI opens and applies or cancels
Then GTK4 completes safely and persisted behavior matches GTK2
```

### SC-e02s07-P0-02: Processing contracts remain frozen

```gherkin
Given ABI probes and existing audio fixtures
When GTK4 plugin sources are built and exercised
Then public layouts and callbacks match
And decoder/output behavior is unchanged
```

### SC-e02s07-P0-03: Plugin dependencies are pure

```gherkin
Given all produced Input and Output shared objects
When dynamic dependencies are inspected
Then each links only its selected GTK major
And no available bundled plugin is omitted silently
```

## 18. Implementation Steps

1. Add fixture-driven UI contracts → verify: `xvfb-run --auto-servernum tests/test-gtk4-io-plugin-uis.sh "$PWD"`
2. Port all bundled Input UIs → verify: `xvfb-run --auto-servernum tests/test-gtk4-io-plugin-uis.sh "$PWD" --family input`
3. Port all bundled Output UIs → verify: `xvfb-run --auto-servernum tests/test-gtk4-io-plugin-uis.sh "$PWD" --family output`
4. Check ABI and dynamic dependencies → verify: `tests/test-plugin-abi.sh "$PWD" && tests/test-gtk-plugin-dependencies.sh "$PWD" input output`
5. Verify both modes and optional classifications → verify: `tests/test-gtk-build-modes.sh "$PWD" --story e02s07`

## 19. Verification Script

1. Build all available Input/Output plugins in isolated toolkit modes.
2. Open/apply/cancel/reopen every UI through the host fixture.
3. Run existing playback/device tests.
4. Inspect exported symbols and dynamic dependencies.
5. Compare built/skipped plugin inventory with packaging manifests.

## 20. Risks

- Optional dependencies can hide unported code from CI.
- Legacy dialogs may couple UI state to decoder/device lifetime.
- Broad plugin edits could unintentionally touch historical codec code; changes must remain GTK-facing.
