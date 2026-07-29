# e02s01: Rebrand current project surfaces and reset the release baseline

<!-- story: e02s01 -->

**type:** chore

**risk:** P0

**context:** infrastructure

**bcps:** 5

## 1. Summary

Establish XMMS GTK4 Experimental as the current project identity, archive inherited fork-specific release prose, and begin an independent release line at 0.0.1.

## 2. User

Contributors, package consumers, and maintainers who need an unambiguous identity and release baseline for the experimental GTK4 fork.

## 3. Problem

Current documentation and packaging still identify the repository as XMMS GTK4 Experimental and version 0.0.1, obscuring the fork's new direction.

## 4. Value

Every current-facing surface communicates one project identity and a pre-1.0 version suitable for experimental development.

## 5. Context

The repository retains inherited runtime contracts even though its project identity changes. Prior fork-specific narrative belongs under `docs/history/`, alongside preserved upstream material.

## 6. In Scope

- Public branding and repository URLs.
- Documentation, package descriptions, project specs, and agent guidance.
- Authoritative and shipped Autotools version metadata.
- Current changelog and release examples.
- Packaging and release contract tests.

## 7. Out of Scope

- Runtime executable/package/library/API/config-path renames.
- GTK4 implementation work.
- Rewriting archived source history.

## 8. Dependencies

No external dependencies.

## 9. Module Purpose

Release metadata defines the source package version; packaging metadata describes installed artifacts; current documentation communicates project identity; historical documentation preserves provenance.

## 10. Callers

Configure/build scripts, Debian package tooling, release scripts, contributors, package users, and documentation readers.

## 11. Contracts

- Autotools inputs and checked-in generated outputs remain synchronized.
- `xmms`, `libxmms`, plugin ABI, socket commands, and `~/.xmms` remain stable.
- Historical material remains available under `docs/history/`.
- Current repository links resolve to `tuunanet/xmms-gtk4-experimental`.

## 12. Requirements

### RENAMED: Current project identity

**Before:** Current-facing materials use the inherited fork identity and its former repository URL.

**After:** Current-facing materials identify the project as XMMS GTK4 Experimental and link to `tuunanet/xmms-gtk4-experimental`.

### MODIFIED: Initial release baseline

**Before:** Build and release metadata target version 0.0.1.

**After:** Build and release metadata target version 0.0.1 as the first independent fork release.

### MODIFIED: Historical narrative placement

**Before:** The current changelog mixes prior fork-specific release narrative with current work.

**After:** Prior fork-specific narrative is retained under `docs/history/`; the current changelog begins at 0.0.1.

## 13. Design

Use direct metadata and prose updates without introducing an alias layer. **Reason for Depth:** no new abstraction is needed because identity and version each have existing authoritative surfaces.

## 14. Files and Data

Current docs, packaging recipes, release/build metadata, generated Autotools output, tests, project specs, and one archived historical changelog.

## 15. Error Handling

Repository-wide searches fail verification if stale current-facing branding remains. Existing package/release tests fail closed on metadata drift.

## 16. Security

No security boundary changes; URLs remain public project links and no credentials or external APIs are added.

## 17. Acceptance Criteria

### Scenario: Current identity is consistent

```gherkin
Given any current-facing tracked file
When project branding or repository links are inspected
Then they identify XMMS GTK4 Experimental
And XMMS GTK4 Experimental references occur only in docs/history
```

### Scenario: Version starts at 0.0.1

```gherkin
Given a clean configured source tree
When configure and release metadata are inspected
Then the package version is 0.0.1
And package and release checks pass
```

### Scenario: Compatibility identifiers remain stable

```gherkin
Given inherited runtime contracts
When the project rebrand is applied
Then xmms executable, package, library, plugin, socket, and config identifiers are unchanged
```

## 18. Implementation Steps

1. Archive inherited fork-specific changelog prose and update all current branding and links → verify: `test -z "$(rg -il --hidden --glob '!.git/**' --glob '!docs/history/**' 'xmms[- _]class[i]c' .)"`
2. Set authoritative and generated version metadata to 0.0.1 → verify: `grep -Fq 'AM_INIT_AUTOMAKE([xmms], [0.0.1])' configure.in && grep -Fq 'VERSION=0.0.1' configure`
3. Align package/release tests and run all delivery gates → verify: `tests/test-package-recipes.sh "$PWD" && tests/test-release-tools.sh "$PWD" && xvfb-run --auto-servernum make distcheck`

## 19. Verification Script

1. Search tracked current-facing files for stale branding.
2. Run configure and confirm version 0.0.1.
3. Run package and release contract tests.
4. Run the complete Xvfb-backed test suite and distribution check.
5. Confirm the executable and package compatibility names remain `xmms`.

## 20. Risks

- Generated Autotools drift is caught by configure and distcheck.
- Accidental compatibility renames are prevented by explicit scope and package tests.
- Moving historical prose can omit source-distribution content unless `EXTRA_DIST` is updated.
