# Test Design: e03 GTK migration foundation

## 1. Risk Matrix & Scenarios

| Scenario ID | Behavior description | Risk | Test level | Target file/module |
| --- | --- | --- | --- | --- |
| SC-e03s01-P1-01 | A released Play button requests the historical normal `cbuttons.bmp` source rectangle and destination geometry. | P1 | Unit/source slice | `tests/test-pbutton-baseline.c`, `xmms/pbutton.c` |
| SC-e03s01-P1-02 | Pressing inside with button 1 requests the pressed rectangle; leaving and re-entering changes visual state consistently. | P1 | Unit/source slice | `tests/test-pbutton-baseline.c`, `xmms/pbutton.c` |
| SC-e03s01-P1-03 | Hit testing includes the top/left edge, excludes bottom/right and outside coordinates, and ignores non-primary buttons. | P1 | Unit/source slice | `tests/test-pbutton-baseline.c`, `xmms/widget.c` |
| SC-e03s01-P1-04 | Releasing a valid press invokes the Play callback exactly once; invalid releases invoke it zero times. | P1 | Unit/source slice | `tests/test-pbutton-baseline.c`, `xmms/pbutton.c` |
| SC-e03s02-P0-01 | Toolkit-neutral control headers expose no GTK/GDK types and produce deterministic state transitions and draw commands. | P0 | Unit | `tests/test-ui-control.c`, `xmms/ui_control.[ch]` |
| SC-e03s02-P0-02 | The GTK2 PButton adapter preserves every e03s01 baseline observation. | P0 | Integration/source slice | `tests/test-pbutton-baseline.c`, `xmms/pbutton.c` |
| SC-e03s02-P0-03 | Production build, plugin discovery/linkage, package contracts, and source distribution remain green. | P0 | Integration | `tools/preflight.sh --strict` and `tools/verify-meson-dist.sh` |
| SC-e03s03-P0-01 | The GTK3 proof binary links GTK3 and does not link GTK2. | P0 | Binary contract | `ldd tests/test-gtk3-play-button-proof` |
| SC-e03s03-P0-02 | The GTK3 proof renders normal and pressed Play sprites through the shared command contract with deterministic pixel assertions. | P0 | Integration | `tests/test-gtk3-play-button-proof.c` |
| SC-e03s03-P0-03 | The GTK3 proof translates a primary-button activation into exactly one shared callback and rejects invalid activation. | P0 | Integration | `tests/test-gtk3-play-button-proof.c` |
| SC-e03s03-P0-04 | GTK3 prerequisites, optional detection, package manifests, and distribution inputs remain synchronized. | P0 | Integration | Meson options, package tests, and source-distribution checks |

## 2. Fixture Architecture & Isolation

- Use stack-allocated control state and a callback counter; do not initialize playback, plugins, sockets, or user configuration.
- Stub the GTK2 skin draw facade in the source-slice baseline test to capture source and destination rectangles without relying on a window manager theme.
- Use a tiny generated in-memory sprite fixture with distinct normal/pressed colors for deterministic GTK3 pixel assertions; do not add binary fixture files.
- Run GTK-dependent tests under an isolated Xvfb display and destroy widgets/surfaces within each test.
- Build GTK2 and GTK3 tests as separate executables. Never link both toolkit majors into one test process.
- Keep tests independent of `~/.xmms`, installed plugins, audio hardware, network access, locale order, and execution order.

## 3. NFR Verification

| NFR type | Requirement | Verification command |
| --- | --- | --- |
| Compatibility | Public runtime and plugin ABI contracts are unchanged. | `git diff --exit-code main -- xmms/plugin.h libxmms/xmmsctrl.h xmms/controlsocket.h` |
| Link isolation | GTK3 proof contains GTK3 and no GTK2 dependency. | `ldd tests/test-gtk3-play-button-proof | grep -F 'libgtk-3.so' && ! ldd tests/test-gtk3-play-button-proof | grep -F 'libgtk-x11-2.0.so'` |
| Threading | New control and render-command logic performs no GTK work or blocking I/O. | `! rg -n 'Gtk|Gdk|pthread|read\(|write\(|system\(' xmms/ui_control.[ch]` |
| Regression | Existing player and full suite remain green. | `tools/preflight.sh --strict` |
| Distribution | Clean source archive rebuild includes all new inputs. | `tools/verify-meson-dist.sh` |
| Lint | New maintained C code introduces no Cppcheck regression. | `tools/run-c-lint.sh` |

## 4. Manual Acceptance

1. Run the production GTK2 player with the default skin under X11/Xvfb.
2. Press, drag outside, drag back inside, and release the Play control.
3. Confirm normal/pressed feedback and one activation match the pre-migration behavior.
4. Run the GTK3 proof executable and confirm it reports its normal, pressed, and activation checks as passing.
5. Confirm the production binary still links GTK2 only and the proof binary links GTK3 only.

## 5. Out of Scope

- Screenshot parity for the complete main, playlist, or equalizer windows.
- Window masks, windowshade, doublesize, docking, drag-and-drop, menus, fonts, and file selection.
- Audio playback through the GTK3 proof process.
- Third-party plugin loading in the GTK3 proof process.
- GTK4 compilation or execution.
