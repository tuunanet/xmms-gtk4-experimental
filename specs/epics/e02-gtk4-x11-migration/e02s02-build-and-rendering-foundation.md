# e02s02: Add separate GTK4 build and skin rendering foundation

<!-- story: e02s02 -->

**type:** refactor

**risk:** P0

**context:** infrastructure

**bcps:** 8

## 1. Summary

Add isolated GTK2 and GTK4 build modes and move classic skin decoding, ownership, compositing, masks, and scaling behind Cairo-based boundaries that both modes can verify.

## 2. User

Maintainers landing migration slices while users continue receiving a releasable GTK2 build.

## 3. Problem

Current global GTK2 flags and GdkPixmap/GdkGC fields prevent incremental migration and make pixel regressions invisible.

## 4. Value

Every later GTK4 slice receives normal CI while classic skin output is protected before its drawing implementation changes.

## 5. Context

ADR-0002 requires separate processes/build trees and explicit deletion criteria. Forty-five files use GdkPixmap and 41 use GdkGC. Skin assets and geometry remain public compatibility contracts.

## 6. In Scope

- Deterministic GTK2/GTK4 configure selection and isolated build outputs.
- Ubuntu 26.04 GTK4 dependency discovery and dual-mode CI.
- Cairo surface ownership and skin compositing seams.
- Golden output for complete, incomplete, shaped, shaded, and double-size skins.

## 7. Out of Scope

- Porting complete application windows.
- Changing skin formats, coordinates, assets, or fallback behavior.
- Permanent dual-toolkit support.

## 8. Dependencies

- **[OK] Cairo:** mature drawing API already available through GTK/GLib ecosystems.
- **[OK] GTK2:** temporary release-only migration dependency.
- **[OK] GTK 4.22:** experimental build dependency.

## 9. Module Purpose

`skin.c` and custom widget drawing decode and composite fixed WinAmp-compatible assets; configure/CI select one toolkit per build.

## 10. Callers

Main, playlist, equalizer, every custom widget renderer, bundled visual components, tests, packaging, and CI.

## 11. Contracts

- One build tree selects exactly one GTK major.
- GTK2 remains the release default during this story.
- Pixel geometry, masks, clipping, fallbacks, and scaling remain unchanged.
- Transitional abstractions have final deletion criteria.

## 12. Requirements

### MODIFIED: Toolkit build selection

**Before:** Configure requires GTK2 globally.

**After:** Isolated builds select GTK2 release mode or GTK4 experimental mode and no artifact links both.

### MODIFIED: Skin rendering storage

**Before:** Skin and widget structures expose GdkPixmap/GdkGC ownership directly.

**After:** Toolkit-neutral Cairo rendering boundaries preserve identical pixels and hide backend storage.

### ADDED: Skin golden regression gate

Approved skin states SHALL be compared deterministically across migration modes.

## 13. Design

Use one narrow rendering boundary rather than conditional drawing throughout widgets. **Reason for Depth:** dozens of callers share fixed skin compositing, so centralized ownership prevents duplicated GTK-major branches and makes final GTK2 deletion tractable.

## 14. Files and Data

- `configure.in`, generated build inputs, CI and package policy tests.
- `xmms/skin.[ch]`, `bmp.c`, `widget.[ch]`, and focused rendering helpers.
- Deterministic skin fixtures and golden outputs under `tests/`.

## 15. Error Handling

Invalid toolkit selection, mixed dependency output, unavailable Cairo/GTK packages, invalid skin surfaces, and golden mismatches fail with mode and asset context. Existing missing-skin fallback remains graceful.

## 16. Security

Skin archives and BMP inputs are untrusted. Refactoring must not broaden extraction or decoding behavior, and new surface dimensions must be checked before allocation and drawing.

## 17. Acceptance Criteria

### SC-e02s02-P0-01: Build modes are isolated

```gherkin
Given a clean Ubuntu 26.04 source tree
When GTK2 and GTK4 configurations build in separate directories
Then each artifact links only its selected toolkit
And the GTK2 release build remains unchanged
```

### SC-e02s02-P0-02: Skin pixels remain stable

```gherkin
Given approved complete and shaped skin fixtures
When normal, shaded, and double-size states render in both modes
Then their owned pixel regions and masks match the approved goldens
```

### SC-e02s02-P0-03: Skin fallbacks remain compatible

```gherkin
Given missing, undersized, RLE, and partially invalid skin assets
When the shared renderer loads them
Then classic fallback, clipping, and failure behavior remains unchanged
```

## 18. Implementation Steps

1. Add failing isolated-build contracts (ref: ADR-0002) → verify: `tests/test-gtk-build-modes.sh "$PWD"`
2. Add temporary build selection and dual-mode CI → verify: `tests/test-gtk-build-modes.sh "$PWD" && tests/test-package-recipes.sh "$PWD"`
3. Move skin ownership/compositing behind Cairo seams → verify: `xvfb-run --auto-servernum tests/test-skin-rendering.sh "$PWD" --toolkit-matrix`
4. Add deterministic skin goldens → verify: `tests/test-skin-goldens.sh "$PWD" --toolkit-matrix`
5. Verify CI classification and dual-mode policy → verify: `tests/test-package-recipes.sh "$PWD" && tests/test-gtk-build-modes.sh "$PWD" --ci-contract`

## 19. Verification Script

1. Configure separate GTK2 and GTK4 build roots.
2. Inspect each executable's dynamic dependencies.
3. Render default and representative skins in all required states.
4. Compare masks and pixels with approved output.
5. Run the full GTK2 release preflight and the GTK4 foundation checks.

## 20. Risks

- Temporary conditionals may become permanent; removal criteria are a hard final gate.
- Cairo sampling can alter edge pixels or scaling; goldens detect this.
- GTK4 partial mode may tempt unsupported UI claims; only declared surfaces count as migrated.
