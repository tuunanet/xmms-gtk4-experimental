# Test design: e05 Meson tooling migration

## 1. Risk matrix and scenarios

| Scenario | Behavior | Risk | Level | Planned proof |
| --- | --- | --- | --- | --- |
| SC-e05s01-P1-01 | Current release evidence and build/feature baseline are recorded before conversion. | P1 | Integration | Baseline manifest checker and lifecycle YAML validation. |
| SC-e05s02-P0-01 | A clean out-of-tree Meson setup compiles `xmms`, `wmxmms`, `libxmms`, enabled plugins, and the GTK3 proof without GTK2/GTK3 mixed linkage. | P0 | Integration | Clean `meson setup`, `meson compile`, output/link assertions. |
| SC-e05s02-P0-02 | Meson options preserve every supported required/optional feature decision exposed by the legacy configure contract. | P0 | Integration | Option matrix fixture and generated configuration assertions. |
| SC-e05s03-P0-01 | Meson registers and executes all GLib, shell, GTK/Xvfb, plugin-linkage, and package-contract tests with isolated build-tree paths. | P0 | Integration | `meson test` under Xvfb plus test inventory comparison. |
| SC-e05s03-P0-02 | Meson install and source distribution provide the required headers, binaries, plugins, translations, docs, and release inputs from a clean extracted tree. | P0 | E2E | Project-owned distribution verifier using `meson dist`. |
| SC-e05s04-P0-01 | Debian rules build unchanged `xmms` and `libxmms-dev` package contracts from Meson. | P0 | E2E | `dpkg-buildpackage`, metadata inspection, install/smoke checks. |
| SC-e05s04-P0-02 | The manual annotated-tag workflow produces verified Mint and Ubuntu draft-release assets from Meson. | P0 | E2E | Static workflow contract plus tagged GitHub dispatch and checksum review. |
| SC-e05s05-P1-01 | Canonical agent preflight fails clearly when Meson/Ninja are absent and succeeds with declared system tools. | P1 | Integration | PATH-isolated shell fixtures and normal preflight run. |
| SC-e05s05-P1-02 | CLAUDE, contributor, architecture, and release documentation contain only supported Meson-era commands. | P1 | Static | Documentation/contract script. |
| SC-e05s06-P0-01 | The tracked tree contains no legacy Autotools/libtool/configure/Makefile artifacts or live command contracts after cutover. | P0 | Static + E2E | Forbidden-path manifest and complete Meson preflight/package/distribution gates. |

## 2. Fixture and isolation strategy

- Use fresh disposable Meson build directories for every setup/compile/install
  scenario; never reuse a legacy in-tree build directory.
- Preserve existing fixture plugins and add Meson build-tree plugin-path setup
  rather than changing test behavior.
- Use `xvfb-run --auto-servernum` only around GTK-bearing tests; do not mask
  display-independent failures.
- Build optional dependencies through installed system/pkg-config packages only;
  no wrap/subproject network fetch is permitted.
- Keep one authoritative feature matrix fixture derived from the captured
  Meson feature baseline after the legacy toolchain is deleted.

## 3. Non-functional verification

| Concern | Requirement | Verification |
| --- | --- | --- |
| Reproducibility | Clean system-tool builds do not download dependencies. | Assert no subprojects/wrap downloads and run fresh Meson setup. |
| Compatibility | Outputs and package interfaces preserve public contracts. | Compare names, install paths, package metadata, plugin linkage, headers, and release inputs. |
| Security | Release remains annotated-tag, checksum, least-privilege, and draft-only. | Static workflow contract plus a post-cutover tagged dry release review. |
| Operability | Agent preflight is one documented project command. | PATH-negative fixture and normal preflight from a clean build dir. |

## 4. Out of scope

- GTK production-port behavior, public ABI redesign, new package targets,
  automatic publication, and permanent dual-build support.
