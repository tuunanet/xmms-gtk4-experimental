# Implementation Plan: Restore GTK2 entry navigation build compatibility

## Overview
Repair `libxmms/xentry.c` so it uses GTK2-compatible entry APIs and UTF-8 text handling. This resolves the current GCC build errors while preserving read-only entry navigation, including Alt+F/Alt+B word movement and the no-navigation behavior for invisible entries.

## Architecture Decisions
- Use public GTK2 accessors (`gtk_entry_get_visibility()` and `gtk_entry_get_text()`) instead of relying on the obsolete `GtkEntry` text representation.
- Treat editable positions as UTF-8 character offsets; use GLib UTF-8 helpers rather than indexing UTF-8 bytes or GTK1 `GdkWChar` data.
- Keep the fix scoped to the custom XMMS entry widget. Do not update the broader deprecated GTK2 type system as part of this build fix.

## Dependency Graph

```text
GTK2 public text/visibility APIs
        |
        v
word-navigation implementation in libxmms/xentry.c
        |
        +--> focused navigation regression coverage
        |
        v
full configure + build verification
```

## Task List

### Phase 1: Specify and protect existing behavior

#### Task 1: Add focused read-only entry navigation coverage

**Description:** Add a display-independent GLib regression test for the extracted word-boundary calculation. Cover ASCII boundaries and UTF-8 text without requiring a virtual X server.

**Acceptance criteria:**
- [x] Forward and backward movement return the expected word boundary for ASCII text.
- [x] Navigation uses character positions correctly for a UTF-8 string.

**Verification:**
- [x] Run `make -C tests check`.
- [x] Confirm the test/build fails against the pre-fix implementation.

**Dependencies:** None

**Files touched:**
- `tests/test-xentry.c` (new)
- `tests/Makefile` (new)
- `libxmms/xentry.h` (narrow testable helper declaration)

**Estimated scope:** Medium (3 files)

### Phase 2: Port the incompatible entry code

#### Task 2: Replace GTK1-only text and visibility usage

**Description:** Update the forward and backward word-navigation helpers to pass `GtkEntry *` to the visibility accessor and use the public UTF-8 entry text API. Convert between GTK editable character offsets and UTF-8 pointers with GLib helpers; retain the current word-boundary rules and cursor results.

**Acceptance criteria:**
- [x] `libxmms/xentry.c` no longer assigns `GtkEntry::text` to `GdkWChar *`.
- [x] Both word-navigation helpers pass `GtkEntry *` to `gtk_entry_get_visibility()`.
- [x] The focused navigation tests pass, including UTF-8 character-position coverage.
- [x] No new compiler errors are introduced in `libxmms`.

**Verification:**
- [x] Run `make -C tests check`.
- [x] Run `make -C libxmms` as part of the full build.

**Dependencies:** Task 1

**Files likely touched:**
- `libxmms/xentry.c`

**Estimated scope:** Small (1 file)

### Checkpoint: Entry widget fixed
- [x] Focused entry-navigation checks pass.
- [x] `make -C libxmms` completes without errors as part of the full build.
- [x] Review confirms the change uses public GTK2 APIs and handles UTF-8 character offsets.

### Phase 3: Verify the project build

#### Task 3: Reconfigure and build the project

**Description:** Build from a clean generated state with the existing optional-plugin detection. Treat unrelated warnings as separate work unless they prevent compilation or linking.

**Acceptance criteria:**
- [x] `./configure` completes successfully with the installed GTK2 toolchain.
- [ ] `make -j"$(nproc)"` completes successfully; it is currently blocked by unrelated legacy source incompatibilities in `xmms/controlsocket.c`, `xmms/input.c`, `xmms/sbutton.c`, `xmms/util.c`, and `xmms/pbutton.c`.
- [x] The original `xentry.c` incompatible-pointer errors do not recur.

**Verification:**
- [x] Run `./configure`.
- [ ] Run `make -j"$(nproc)"` (blocked by the unrelated errors above).
- [ ] Run `make check` after the full build succeeds.

**Dependencies:** Task 2

**Files likely touched:**
- No source files expected; generated build artifacts only.

**Estimated scope:** Small (verification only)

### Checkpoint: Complete
- [ ] All focused tests and the full build pass (full build remains blocked outside this plan's scope).
- [ ] No generated build artifacts or unintended source changes are staged.
- [ ] The fix is ready for code review and an atomic `fix:` commit.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| GTK test needs an X display | Medium | Run the focused test with `xvfb-run`; document/install that test-only dependency if absent. |
| UTF-8 byte indexing changes cursor semantics | High | Use GLib UTF-8 character/pointer helpers and explicitly test multibyte text. |
| Other legacy APIs fail after `xentry.c` is fixed | Medium | Stop at the next compiler error and create a separate, scoped plan item rather than broadening this fix. |

## Open Questions
- Is `xvfb-run` available in the intended development and CI environments, or should the project add it as an explicit test dependency?
