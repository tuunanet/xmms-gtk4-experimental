# e03s03: Prove the Play-button boundary in a separate GTK3 harness

<!-- story: e03s03 -->

**type:** feat

**risk:** P0

**context:** UI migration

**bcps:** 8

## 1. Summary

Build a separately linked GTK3 proof executable that renders and activates the Play control through the e03s02 toolkit-neutral contract while the production player remains GTK2.

## 2. User

Maintainers and contributors who need executable evidence that the staged migration seam works across toolkit generations before porting a production window.

## 3. Problem

A toolkit-neutral header alone does not prove that another GTK major can consume the control contract, render the expected sprite states, or remain isolated from GTK2 linkage.

## 4. Value

The repository gains its first running GTK3 UI slice and catches build, link, drawing, event-adapter, test, packaging, and distribution problems before a full-window migration.

## 5. Context

The official GTK guidance says GTK2 applications should first migrate to GTK3 and warns that loading multiple GTK majors into one process is unsafe. ADR-0001 therefore requires separate executables and rebuilt UI-bearing plugins.

## 6. In Scope

- Authoritative optional GTK3 detection.
- A test-only or experimental GTK3 executable separate from the production player.
- Deterministic normal/pressed Play sprite rendering through the shared command contract.
- Primary activation and invalid-activation checks through a GTK3 adapter.
- Link isolation checks, build/test/package/distribution wiring, and architecture documentation.

## 7. Out of Scope

- Switching `xmms` to GTK3.
- Starting playback, loading plugins, reading user config, or opening sockets from the proof process.
- Porting the complete main window or other controls.
- GTK4 compilation.
- Runtime support for GTK2-linked plugins in a GTK3/GTK4 process.

## 8. Dependencies

- **GTK3 development package — [OK]:** mature upstream bridge explicitly required by the official GTK2-to-GTK4 migration guide.
- Existing GLib, GdkPixbuf, Cairo, Autotools, Xvfb, and C toolchain.
- No third-party rendering framework.

The official GTK3 guide states that `GdkPixmap` is removed in favor of Cairo surfaces, and the GTK4 guide states that event controllers replace legacy event signals while many controller APIs are available in GTK3 for preparation.

## 9. Module Purpose

The new proof target validates one cross-toolkit UI path only. Autotools detects and isolates its GTK3 compilation; the shared control module owns toolkit-neutral behavior; the GTK3 adapter owns widget/event translation and Cairo-backed presentation.

## 10. Callers

Developers, `make check`, applicable CI jobs, package contract tests, and `make distcheck` build the proof. The production player does not call or load it.

## 11. Contracts

- The proof executable links GTK3 and never GTK2.
- The production executable and plugins continue to link their current GTK2 dependencies in this initiative.
- Both paths consume one toolkit-neutral state and draw-command contract.
- Proof execution is deterministic under Xvfb and touches no user configuration or audio device.
- GTK3 absence is diagnosed at configure time according to the approved build policy; applicable CI and maintainer environments install it rather than silently skipping migration coverage.

## 12. Requirements

### ADDED: Isolated GTK3 Play-control proof

A separate GTK3 executable renders normal and pressed Play states and activates the shared callback contract without linking GTK2 or starting the player core.

### ADDED: Mixed-toolkit linkage guard

Automated verification fails when the GTK3 proof gains a GTK2 dependency or loses its GTK3 dependency.

### ADDED: Migration dependency and documentation contract

Authoritative build, package, CI, clean, and distribution paths include the GTK3 proof prerequisites and sources, and architecture documentation records the staged status and plugin policy.

## 13. Design

Use a small GTK3 drawing surface/window adapter, an in-memory two-color sprite fixture, and the shared e03s02 command contract. Build it as an independent executable with target-specific GTK3 flags and libraries; never share a process or link unit with GTK2 code. **Reason for Depth:** a separate executable is required to prove a real GTK3 consumer while enforcing GTK's documented prohibition on unsafe mixed-major linkage.

## 14. Files and Data

Expected changes include `configure.in` and shipped generated outputs, test/build manifests, a focused GTK3 proof source, package/CI prerequisites where applicable, and architecture docs. Sprite data is generated in memory; no binary assets or persistent state are added.

## 15. Error Handling

Configure reports a missing GTK3 development dependency with actionable context under the selected policy. The proof exits non-zero on widget creation, rendering, pixel, activation, or linkage-contract failure. It allocates and releases GTK/Cairo objects within the test lifetime.

## 16. Security

The proof processes only compiled in-memory fixtures and pointer coordinates. It performs no archive extraction, file parsing, network access, plugin loading, privilege change, or persistent write. GTK3 is obtained from the system package manager and introduces no vendored code.

## 17. Acceptance Criteria

### Scenario SC-e03s03-P0-01: Toolkit linkage is isolated

```gherkin
Given the production GTK2 target and GTK3 proof target
When their dynamic dependencies are inspected
Then the proof links GTK3 and not GTK2
And the production target remains GTK2
```

### Scenario SC-e03s03-P0-02: Shared commands render in GTK3

```gherkin
Given deterministic normal and pressed sprite fixtures
When the GTK3 adapter consumes shared Play-button draw commands
Then pixel assertions identify the expected state and destination
And no GTK2 renderer is involved
```

### Scenario SC-e03s03-P0-03: GTK3 activation uses shared behavior

```gherkin
Given valid and invalid pointer activations in the GTK3 proof
When they are translated to the shared control contract
Then a valid primary activation calls back exactly once
And invalid activation calls back zero times
```

### Scenario SC-e03s03-P0-04: Delivery paths include the proof

```gherkin
Given a clean source tree with declared migration prerequisites
When lint, package contracts, make check, and distcheck run
Then the proof builds and passes under Xvfb
And no local binary or generated package artifact is committed
```

## 18. Implementation Steps

1. Add GTK3 dependency detection and a separately linked proof target for SC-e03s03-P0-01 → verify: `./configure --disable-esd && make -C tests test-gtk3-play-button-proof && ldd tests/test-gtk3-play-button-proof | grep -F 'libgtk-3.so' && ! ldd tests/test-gtk3-play-button-proof | grep -F 'libgtk-x11-2.0.so'`
2. Implement deterministic GTK3 rendering and activation scenarios SC-e03s03-P0-02 and SC-e03s03-P0-03 through the shared contract → verify: `xvfb-run --auto-servernum tests/test-gtk3-play-button-proof`
3. Synchronize prerequisites, checks, clean rules, source manifests, and package contracts for SC-e03s03-P0-04 → verify: `tests/test-package-recipes.sh "$PWD" && make lint && xvfb-run --auto-servernum make check && xvfb-run --auto-servernum make distcheck`
4. Document the proven staged boundary and plugin GTK-major policy → verify: `rg -q 'GTK2.*GTK3.*GTK4' docs/architecture/ui-interaction.md && rg -q 'mixed.*GTK|GTK.*major' docs/architecture/plugin-system.md`

## 19. Verification Script

1. Install the declared GTK3 development prerequisite.
2. Configure and build both the production player and proof target.
3. Inspect each executable with `ldd` and confirm toolkit-major isolation.
4. Run the GTK3 proof under Xvfb and inspect its test cases.
5. Run the production GTK2 PButton baseline and full suite.
6. Run lint, package contracts, and distcheck.
7. Confirm docs state that UI-bearing plugins require rebuild/porting for the active GTK major.

## 20. Risks

- Linking both toolkit majors through a transitive library can crash; enforce binary dependency checks before execution.
- Theme or compositor rendering can be nondeterministic; assert an in-memory fixture and offscreen pixel output.
- Making GTK3 optional could allow migration coverage to disappear; applicable CI and maintainer gates must install and require it.
- Generated Autotools drift can break source archives; update source definitions and shipped outputs together and run distcheck.
- The proof could grow into a second application; keep it limited to one control and no player-core initialization.
