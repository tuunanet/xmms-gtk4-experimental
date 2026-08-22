# Test Design: e07 GTK3 main-window slice

## 1. Risk Matrix & Scenarios

| Scenario ID | Behavior Description | Risk | Test Level | Target File/Module |
|-------------|----------------------|------|------------|--------------------|
| SC-e07s01-P1-01 | GTK3 shell exposes the approved classic dimensions and representative frame/display regions | P1 | Unit/integration | GTK3 shell fixture and adapter |
| SC-e07s01-P1-02 | GTK3 shell renders deterministic fixture pixels under Xvfb without production initialization | P1 | Integration | GTK3 shell test target |
| SC-e07s02-P0-01 | Valid transport press/release reports redraw and exactly one activation without playback | P0 | Unit/integration | Toolkit-neutral control and GTK3 adapter |
| SC-e07s02-P0-02 | Invalid transport input reports no activation and does not reach plugins, socket, config, or audio | P0 | Unit/integration | GTK3 transport test target |
| SC-e07s03-P1-01 | Tracer links GTK3 and not GTK2; production target remains GTK2-linked; Meson registers the test | P1 | Build/linkage | Meson target and linkage contract |
| SC-e07s03-P1-02 | Clean source distribution and strict preflight retain tracer sources, tests, and documentation without installed artifact changes | P1 | Distribution | Meson dist and preflight contracts |

## 2. Fixture Architecture & Isolation

- **Geometry fixture:** fixed classic main-window dimensions and named representative regions; no host display queries.
- **Pixel fixture:** in-memory Cairo/GdkPixbuf surfaces with explicit colors and coordinates; no user skin or filesystem dependency.
- **Event fixture:** synthetic GTK3 pointer events with valid, invalid, and repeated release sequences.
- **Activation observer:** an injected counter or callback that records results without calling playlist, input, plugin, or socket code.
- **Build fixture:** explicit Meson target paths and `ldd`/equivalent dependency inspection for GTK-major isolation.
- **Distribution fixture:** clean Meson source archive extraction and package manifest inspection.

All GTK tests run under Xvfb. Tests must remain independent and must not require a running player, audio device, user configuration, or installed plugin directory.

## 3. Level Strategy

- Use source-slice or GLib assertions for geometry, event translation, and exactly-once behavior.
- Use a focused GTK3 integration executable under Xvfb for actual widget/drawing and target linkage.
- Use shell/build contract tests for Meson registration, dynamic dependencies, source distribution, and installed artifact boundaries.
- Keep the full `tools/preflight.sh --strict` gate as the final cross-story verification rather than the only test of behavior.

## 4. NFR Verification

| NFR Type | Requirement | Verification Command |
|----------|-------------|----------------------|
| Isolation | GTK3 tracer links GTK3 and not GTK2; production target remains GTK2-linked | `tests/test-gtk3-main-window-shell.sh "$PWD" --linkage` |
| Determinism | Geometry and representative pixels are stable under Xvfb | `xvfb-run --auto-servernum meson test -C build-meson gtk3-main-window-shell` |
| Compatibility | Invalid transport input cannot invoke a production path | `xvfb-run --auto-servernum meson test -C build-meson gtk3-main-window-transport` |
| Distribution | Clean source archive retains tracer paths and tests | `tools/preflight.sh --strict` |
| Tooling | No new dependency download or formatter rewrite occurs | `tools/preflight.sh --strict` |

## 5. Out of Scope

- Production GTK2-to-GTK3 or GTK3-to-GTK4 switching.
- Full skin, playlist, equalizer, preferences, dock, or plugin UI parity.
- Playback, control-socket, configuration, and third-party plugin integration.
- Performance benchmarking beyond the existing bounded preflight and deterministic test requirements.
