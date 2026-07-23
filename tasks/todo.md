# GTK2 Entry Navigation Build Fix

- [x] **Task 1:** Add focused display-independent word-navigation coverage, including UTF-8 character positions. Depends on: none.
- [x] **Task 2:** Port `libxmms/xentry.c` word navigation to public GTK2 visibility/text APIs and UTF-8 character offsets. Depends on: Task 1.
- [ ] **Task 3:** Reconfigure and run the full parallel build; blocked by legacy source incompatibilities. Depends on: Task 2.
- [ ] **Task 4:** Rename the C23-reserved `bool` parameter in `xmms/controlsocket.c`. Depends on: Task 3.
- [ ] **Task 5:** Correct the `fts_open()` null-comparator type in `xmms/util.c`. Depends on: Task 3.
- [ ] **Task 6:** Restore native callback assignments for `sbutton` and `pbutton`. Depends on: Task 3.
- [ ] **Task 7:** Audit currently failing GTK signal callback boundaries. Depends on: Task 3.
- [ ] **Task 8:** Iterate to a clean full build without warning suppression. Depends on: Tasks 4-7.

## Completion criteria
- [x] `make -C tests check` passes.
- [ ] `./configure && make -j"$(nproc)"` succeeds.
- [ ] No generated artifacts are committed.
