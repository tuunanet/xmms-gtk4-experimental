# GTK2 Entry Navigation Build Fix

- [x] **Task 1:** Add focused display-independent word-navigation coverage, including UTF-8 character positions. Depends on: none.
- [x] **Task 2:** Port `libxmms/xentry.c` word navigation to public GTK2 visibility/text APIs and UTF-8 character offsets. Depends on: Task 1.
- [ ] **Task 3:** Reconfigure and run the full parallel build; currently blocked by unrelated legacy source incompatibilities outside this plan's scope. Depends on: Task 2.

## Completion criteria
- [x] `make -C tests check` passes.
- [ ] `./configure && make -j"$(nproc)"` succeeds (currently blocked outside this plan's scope).
- [ ] No generated artifacts are committed.
