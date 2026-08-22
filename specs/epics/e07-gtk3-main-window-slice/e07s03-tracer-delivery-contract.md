# e07s03: Seal GTK3 tracer delivery and linkage contracts

<!-- story: e07s03 -->

**type:** feat

**risk:** P1

**context:** build and delivery

**bcps:** 5

## 1. Summary

Make the GTK3 main-window tracer a durable Meson test and source-distribution contract with explicit GTK-major linkage checks and migration documentation.

## 2. User

Maintainers and packagers who need the new tracer to remain buildable, testable, and visible in clean source archives without changing installed production artifacts.

## 3. Problem

A local GTK3 proof can silently disappear from Meson, package, or source-distribution paths even when its source test passes in one build tree.

## 4. Value

The migration evidence remains reproducible across clean builds and release preparation, while the production GTK2 delivery contract stays protected.

## 5. Context

Meson is the sole build and delivery toolchain. Existing e03 and e06 contracts already test the isolated Play-button proof and GNOME C policy; this story extends those gates to the main-window tracer.

## 6. In Scope

- Meson registration, target-specific GTK3 dependency, test suite membership, and linkage inspection for the tracer.
- Clean source-distribution inclusion and strict-preflight coverage.
- Architecture and contributor documentation for the new tracer boundary and limitations.

## 7. Out of Scope

- New CI services or external dependencies.
- Installed GTK3 production binaries or package payload changes.
- Replacing the manual release workflow or changing version metadata.
- A GTK2-to-GTK3 production switch.

## 8. Dependencies

- **GTK3 >= 3.24 — [OK]:** existing system dependency already declared for migration proof coverage.
- Existing Meson, Ninja, Xvfb, package, source-distribution, and linkage checks.
- e07s01 and e07s02 tracer sources and tests.

## 9. Module Purpose

Meson and shell contract checks own delivery verification for the isolated tracer. Architecture documentation owns the durable process-boundary and migration-policy description.

## 10. Callers

Meson configure/build/test, strict preflight, source-distribution verification, package contract tests, and maintainers call these delivery checks. No installed runtime component calls the tracer.

## 11. Contracts

- The tracer is registered in the Meson test inventory and source distribution.
- Its binary links GTK3 and not GTK2; the production binary remains GTK2-linked.
- Strict preflight does not rewrite source files, download dependencies, or change installed artifacts.
- Documentation matches the actual process and plugin-loading boundary.

## 12. Requirements

### ADDED: GTK3 tracer delivery contract

Meson, clean source-distribution, and strict-preflight paths shall build and test the GTK3 main-window tracer while keeping it outside installed production outputs.

### ADDED: GTK-major linkage guard

Automated verification shall fail if the tracer loses its GTK3 dependency or gains a GTK2 dependency, and shall continue to verify the production GTK2 target separately.

## 13. Design

Extend existing Meson and shell contract patterns with a target-specific linkage assertion and source-distribution inventory check. **Reason for Depth:** delivery verification must inspect the built artifacts rather than trust source classification, because mixed GTK-major linkage is a binary compatibility hazard.

## 14. Files and Data

Expected changes are Meson source definitions, focused shell/test contracts, architecture or contributor documentation, and e07 verification evidence. No generated build output, package artifact, or binary is committed.

## 15. Error Handling

Missing GTK3 or required system tools fail with the existing actionable diagnostics. Linkage, test-registration, source-distribution, or documentation mismatches exit non-zero and identify the affected contract.

## 16. Security

The checks inspect local build and archive contents only. They add no network fetch, code generation service, credentials, archive extraction privilege, or runtime plugin loading beyond existing test infrastructure.

## 17. Acceptance Criteria

### Scenario SC-e07s03-P1-01: Linkage and test registration are durable

```gherkin
Given a clean Meson build with the GTK3 proof enabled
When the main-window tracer and production target dependencies are inspected
Then the tracer links GTK3 and not GTK2
And the production target remains GTK2-linked
And the tracer appears in the Meson test inventory
```

### Scenario SC-e07s03-P1-02: Distribution preserves the tracer contract

```gherkin
Given a clean source tree
When strict preflight and source-distribution checks run
Then the tracer sources, tests, and documentation are included
And no installed production artifact changes solely because the tracer exists
```

## 18. Implementation Steps

1. Register the GTK3 tracer targets and linkage guard in Meson and focused contract tests (ref: ADR-0001-staged-gtk-migration.md) → verify: `tests/test-gtk3-main-window-shell.sh "$PWD" --linkage`
2. Add source-distribution, strict-preflight, and architecture documentation coverage (ref: e05-meson-tooling-migration) → verify: `tools/preflight.sh --strict`

## 19. Verification Script

1. Configure a clean Meson build with GTK3 proof coverage enabled.
2. Build the production and tracer targets.
3. Inspect dynamic dependencies and confirm GTK-major isolation.
4. List Meson tests and confirm the tracer is registered.
5. Run strict preflight and source-distribution checks.
6. Confirm installed production artifacts and historical compatibility contracts remain unchanged.

## 20. Risks

- A test-only target could accidentally enter installed outputs; assert install-disabled target metadata and package contents.
- Source-distribution omissions can be hidden by an existing build tree; test from a clean extracted archive.
- Linkage checks can inspect the wrong binary if paths are implicit; use explicit Meson target paths and fail on ambiguity.
