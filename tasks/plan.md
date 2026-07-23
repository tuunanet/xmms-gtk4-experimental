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

### Phase 4: Resolve the next compiler blockers

#### Task 4: Remove the C23-reserved identifier from the control socket

**Description:** Rename the `gboolean bool` parameter in `xmms/controlsocket.c`; GCC 15 treats `bool` as a language keyword, preventing the control-socket translation unit from compiling.

**Acceptance criteria:**
- [ ] `ctrl_write_gboolean()` retains its packet payload and length.
- [ ] `xmms/controlsocket.c` compiles without errors.

**Verification:**
- [ ] Build the affected target or run `make -C xmms controlsocket.o`.

**Dependencies:** Task 3

**Files likely touched:**
- `xmms/controlsocket.c`

**Estimated scope:** Small (1 file)

#### Task 5: Correct the `fts_open()` comparator type

**Description:** Replace the incompatible function-pointer cast in `xmms/util.c` with the correctly typed null comparator. Do not alter deletion traversal behavior.

**Acceptance criteria:**
- [ ] `fts_open()` receives `NULL` or a comparator with its exact declared type.
- [ ] `xmms/util.c` compiles without the incompatible-pointer error.

**Verification:**
- [ ] Build the affected target or run `make -C xmms util.o`.

**Dependencies:** Task 3

**Files likely touched:**
- `xmms/util.c`

**Estimated scope:** Small (1 file)

#### Task 6: Restore typed custom-widget callback assignments

**Description:** Replace `GTK_SIGNAL_FUNC()` casts assigned to the strongly typed `Widget` callback fields with the callback functions' native signatures. Start with `sbutton.c` and `pbutton.c`, then compile all custom-widget implementations and handle newly exposed instances as a separate small task if needed.

**Acceptance criteria:**
- [ ] `sbutton.c` and `pbutton.c` assign compatible press, release, and motion callbacks.
- [ ] The custom-widget callback ABI and behavior are unchanged.
- [ ] No incompatible-pointer errors remain in the custom-widget translation units.

**Verification:**
- [ ] Build `sbutton.o` and `pbutton.o`.
- [ ] Run the focused entry test: `make -C tests check`.

**Dependencies:** Task 3

**Files likely touched:**
- `xmms/sbutton.c`
- `xmms/pbutton.c`

**Estimated scope:** Small (2 files)

#### Task 7: Audit GTK signal callback boundaries revealed by GCC 15

**Description:** Update only the direct `gtk_signal_connect()` calls and callback-holder types that fail compilation (initially in `xmms/input.c` and `xmms/util.c`) so each callback crosses GTK's generic `GtkSignalFunc` boundary explicitly. Preserve signal names and user-data arguments.

**Acceptance criteria:**
- [ ] All currently failing GTK signal connections compile with their intended callback signature.
- [ ] No signal handler behavior or connected user data changes.
- [ ] No new callback casts are used for assignments to the project's strongly typed `Widget` fields.

**Verification:**
- [ ] Build `input.o` and `util.o`.
- [ ] Inspect the changed signal connections against their callback declarations.

**Dependencies:** Task 3

**Files likely touched:**
- `xmms/input.c`
- `xmms/util.c`
- `xmms/util.h` (only if a callback-holder type needs to change)

**Estimated scope:** Medium (2-3 files)

#### Task 8: Iterate to a clean full build

**Description:** Reconfigure and rebuild after Tasks 4-7. Treat each subsequently exposed compiler error as a new, scoped task rather than applying broad warning suppression or a global compiler-flag workaround.

**Acceptance criteria:**
- [ ] `./configure && make -j"$(nproc)"` succeeds.
- [ ] `make -C tests check` and `make check` succeed.
- [ ] No generated build artifacts are staged.

**Verification:**
- [ ] Run `./configure`.
- [ ] Run `make -j"$(nproc)"`.
- [ ] Run `make -C tests check` and `make check`.

**Dependencies:** Tasks 4-7

**Files likely touched:**
- No source files expected; generated build artifacts only.

**Estimated scope:** Small (verification only)

### Checkpoint: Complete
- [ ] All focused tests and the full build pass.
- [ ] No generated build artifacts or unintended source changes are staged.
- [ ] The changes are ready for code review and atomic `fix:` commits.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| GTK test needs an X display | Medium | Run the focused test with `xvfb-run`; document/install that test-only dependency if absent. |
| UTF-8 byte indexing changes cursor semantics | High | Use GLib UTF-8 character/pointer helpers and explicitly test multibyte text. |
| Other legacy APIs fail after `xentry.c` is fixed | Medium | The GCC 15 findings are decomposed into Tasks 4-8; stop and add a new scoped task for any further blocker. |
| Callback casts hide a real ABI mismatch | High | Preserve native callback signatures for custom `Widget` fields and use GTK's generic callback boundary only at `gtk_signal_connect()` calls. |

## Open Questions
- Is `xvfb-run` available in the intended development and CI environments, or should the project add it as an explicit test dependency?
