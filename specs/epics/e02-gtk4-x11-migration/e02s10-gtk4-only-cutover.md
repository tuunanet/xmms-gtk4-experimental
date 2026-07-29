# e02s10: Ship GTK4-only XMMS on Ubuntu 26.04

<!-- story: e02s10 -->

**type:** feat

**risk:** P0

**context:** infrastructure

**bcps:** 8

## 1. Summary

Remove GTK2 and temporary migration scaffolding, make GTK 4.22/X11 the sole supported UI path, update all delivery surfaces, and prove the installed release preserves approved contracts.

## 2. User

XMMS users installing the release, distributors packaging it, maintainers releasing it, and plugin authors rebuilding against it.

## 3. Problem

Temporary dual-build support is not the product goal; residual GTK2 source, packages, conditionals, docs, or shared-object dependencies would leave an incomplete and unsafe migration.

## 4. Value

XMMS Classic ships cleanly on Ubuntu 26.04 with modern GTK4 while preserving classic X11 behavior and programming interfaces.

## 5. Context

ADR-0002 defines mandatory removal criteria. The minimum GTK version is 4.22, Wayland is unsupported, and the major platform/dependency change implies a semantic major release.

## 6. In Scope

- Remove GTK2 configure/build branches, migration conditionals, dependencies, CI jobs, and documentation.
- Make GTK4/X11 defaults authoritative across Autotools, Debian packaging, release workflows, and contributor docs.
- Clean source archive, distcheck, package, install, binary-dependency, external-plugin, and recorded UAT gates.

## 7. Out of Scope

- Wayland support, GTK3, UI redesign, plugin retirement.
- Historical GTK2 binary plugin compatibility.
- Playback/codec modernization.

## 8. Dependencies

- All e02s01–e02s09 acceptance criteria and NFRs pass.
- **[OK] Ubuntu 26.04:** minimum build/CI baseline.
- **[OK] GTK >= 4.22 plus X11/XShape:** sole supported runtime UI stack.

## 9. Module Purpose

Build, packaging, CI, release, documentation, and policy surfaces define what XMMS actually ships and supports.

## 10. Callers

Contributors, CI, Debian builders, release automation, distributors, installed users, and external plugin builds.

## 11. Contracts

- No active GTK2 include, package, configure mode, binary SONAME, workflow, or support claim remains.
- `xmms` identity, config paths, skins, socket protocol, plugin interfaces/paths/identifiers, and GTK-independent libxmms APIs remain stable.
- Non-X11 startup fails clearly.
- Every bundled optional plugin is built or explicitly classified on the authoritative baseline.

## 12. Requirements

### REMOVED: GTK2 support

**Before:** GTK2 is the release default and temporarily coexists with a separate GTK4 migration build.

**After:** GTK2 and all dual-build scaffolding are absent; GTK 4.22/X11 is the only UI configuration.

### MODIFIED: Platform baseline

**Before:** Historical distributions and GTK2 dependencies define the build baseline.

**After:** Ubuntu 26.04, GTK 4.22, X11, and XShape define build, CI, package, and support policy.

### MODIFIED: Release verification

**Before:** Existing checks do not prove GTK dependency purity or complete plugin/UI parity.

**After:** release gates include ABI, dependency, X11, skin, plugin, package, install, and external-source compatibility evidence.

## 13. Design

Delete the migration seam rather than preserving a compatibility framework. **Reason for Depth:** dependency purity must be enforced at source, build, package, and installed-binary boundaries because any one can silently reintroduce GTK2.

## 14. Files and Data

- Autotools sources and shipped generated inputs.
- `.github/workflows/`, Debian packaging, release tooling, manifests, and ignore rules.
- Contributor and architecture documentation.
- Final policy scanners, external fixture plugin, verification script, and UAT records.

## 15. Error Handling

Missing GTK4/X11/XShape dependencies and non-X11 runtime fail early with actionable messages. Package or plugin omissions, GTK2 references, SONAMEs, ABI drift, and UAT failures block release.

## 16. Security

Run security review over native X11 access, async ownership, plugin UIs, file/DnD paths, skin decoding, package scripts, and dynamic loading. Do not suppress unresolved P0/P1 findings.

## 17. Acceptance Criteria

### SC-e02s10-P0-01: GTK2 is completely absent

```gherkin
Given the source tree, source archive, clean build, package, and installed files
When migration and dynamic-dependency gates inspect them
Then no active GTK2/GDK2 source, package, mode, support claim, or SONAME remains
```

### SC-e02s10-P0-02: Clean release pipeline passes

```gherkin
Given a clean Ubuntu 26.04 X11 environment
When lint, build, check, distcheck, Debian package, install, smoke, and recorded UAT run
Then all required gates pass with GTK 4.22 only
```

### SC-e02s10-P0-03: Public compatibility survives

```gherkin
Given the frozen contract suites
When the release is built, installed, and exercised
Then identity, config, skins, socket, plugin interfaces, paths, identifiers, and GTK-independent libxmms APIs match
```

### SC-e02s10-P0-04: External source plugins remain viable

```gherkin
Given a representative plugin built outside the source tree
When it recompiles against the installed public headers and is discovered by GTK4 XMMS
Then it loads through the frozen entry point and completes its lifecycle
```

## 18. Implementation Steps

1. Add final GTK2-removal gates → verify: `tests/test-gtk-migration-contracts.sh "$PWD" --phase final`
2. Remove GTK2 mode and make GTK4/X11 sole path → verify: `tests/test-gtk-build-modes.sh "$PWD" --gtk4-only`
3. Update CI, packaging, release, and docs → verify: `tests/test-package-recipes.sh "$PWD" && tests/test-gtk-migration-contracts.sh "$PWD" --delivery`
4. Inspect installed executable/plugins → verify: `tests/test-installed-gtk-dependencies.sh "$PWD"`
5. Run release-equivalent verification → verify: `tools/verify-gtk4-release.sh "$PWD"`

## 19. Verification Script

1. Build a clean source archive on Ubuntu 26.04.
2. Run lint, build, check, distcheck, Debian package, install, and smoke tests.
3. Scan source, package metadata, executable, libraries, and every bundled plugin for GTK2.
4. Compile/load the external-style plugin and exercise socket/libxmms contracts.
5. Complete the skin/window/plugin UAT matrix under X11 and attach evidence.

## 20. Risks

- Optional dependency gaps can conceal unported bundled plugins.
- Packaging may retain GTK2 despite source cleanup.
- Exact WM behavior needs representative manual X11 evidence beyond Xvfb.
- A future GTK release may remove the approved deprecated XID accessor; GTK baseline increases require ADR review.
