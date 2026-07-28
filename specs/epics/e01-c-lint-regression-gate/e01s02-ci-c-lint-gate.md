# e01s02: Enforce the C lint regression gate in pull requests

<!-- story: e01s02 -->

**type:** feat

**risk:** P1

**context:** infrastructure

**bcps:** 3

## 1. Summary

Run the public C lint command in pull-request CI, protect its workflow and control paths with executable policy tests, and document contributor triage and baseline maintenance.

## 2. User

Maintainers relying on protected-branch checks and contributors preparing pull requests.

## 3. Problem

A local-only linter can be skipped or run with a different invocation. CI must enforce the same command without breaking documentation-only classification or the aggregate required check.

## 4. Value

Every build-affecting pull request receives consistent C regression analysis, while contributors can reproduce failures locally and understand how baseline changes are reviewed.

## 5. Context

The existing workflow classifies changed paths, runs `full-ci` for source changes, and always reports through `build-and-test`. C sources and new lint-control paths are not excluded by the filter, so adding a bounded lint step to `full-ci` preserves current branch-protection topology.

## 6. In Scope

- Install Ubuntu 24.04's Cppcheck package in the existing full-CI dependency step.
- Run `make lint` as a named, bounded CI step.
- Guard target, installation, invocation, distribution, and path-filter assumptions with shell tests.
- Document local execution, finding triage, suppressions, and controlled baseline updates.
- Run full build, test, and distribution verification.

## 7. Out of Scope

- A separate required GitHub status check or replacement CI pipeline.
- Running C lint for documentation-only changes.
- SARIF upload, hosted analyzer dashboards, or CodeQL replacement.
- Release workflow changes unless impact validation demonstrates they are required.

## 8. Dependencies

- **[OK] Cppcheck:** installed from the existing Ubuntu package repositories.
- Existing `dorny/paths-filter`, `full-ci`, and `build-and-test` workflow contracts.
- e01s01's public `make lint` command.

## 9. Module Purpose

`.github/workflows/ci.yml` owns pull-request classification and verification. `tests/test-package-recipes.sh` guards repository-level workflow/build contracts without requiring GitHub-hosted execution.

## 10. Callers

GitHub pull requests, pushes to `main`, manual workflow dispatches, branch protection, `make check`, `make distcheck`, contributors, and release maintainers depend on these files.

## 11. Contracts

- Preserve the always-reporting `build-and-test` aggregate.
- Preserve documentation-only full-CI skips.
- Ensure C and lint-control changes cannot bypass the lint invocation.
- Keep the lint step bounded and use the same `make lint` command documented locally.
- Keep workflow tests portable, deterministic, and network-free.

## 12. Requirements

### ADDED: Pull-request lint enforcement

Full CI SHALL install the supported analyzer and fail when `make lint` reports a new C diagnostic.

### ADDED: Workflow classification coverage

C sources, headers, the runner, baseline, build target, tests, and workflow configuration SHALL remain build-affecting paths.

### ADDED: Contributor operating guidance

Contributor documentation SHALL explain installation, local execution, finding triage, narrow suppressions, and baseline-review expectations.

### MODIFIED: Full-CI verification sequence

**Before:** Full CI configures, builds, tests, checks distributions, and validates Debian packages without a C static-analysis gate.

**After:** Full CI additionally runs the public C lint regression gate under a bounded step before release-oriented verification.

## 13. Design

Extend `full-ci` rather than introducing another conditional job. **Reason for Depth:** no new orchestration abstraction is needed because the current source classifier already selects every C and lint-control path while preserving documentation-only skips.

## 14. Files and Data

- `.github/workflows/ci.yml` — analyzer installation and bounded lint step.
- `tests/test-package-recipes.sh` — workflow/build contract assertions.
- `CONTRIBUTING.md` — contributor commands and maintenance policy.
- `docs/architecture/build-and-test.md` — CI topology and lint architecture.

## 15. Error Handling

Analyzer installation and lint findings fail the existing full-CI job. The aggregate check propagates failure under its current fail-closed rules. No retry is added for deterministic lint findings.

## 16. Security

Security impact is low. CI installs a distribution package from the existing trusted repository and runs analysis on checked-out source without secrets or elevated runtime behavior. Existing least-privilege workflow permissions remain unchanged.

## 17. Acceptance Criteria

### Scenario: C change passes lint

```gherkin
Given a pull request changes maintained C code without adding a diagnostic
When full CI runs
Then Cppcheck is installed
And make lint succeeds
And build-and-test can report success
```

### Scenario: New diagnostic blocks merge

```gherkin
Given a pull request introduces an unsuppressed Cppcheck finding
When full CI runs make lint
Then the lint step fails
And the aggregate build-and-test check fails closed
```

### Scenario: Documentation-only change remains inexpensive

```gherkin
Given a pull request changes only an already excluded documentation path
When CI classifies the change
Then full-ci remains skipped
And build-and-test still reports success according to its existing contract
```

## 18. Implementation Steps

1. Extend policy tests to require the public target, distributed controls, Cppcheck installation, named lint step, timeout, and non-excluded lint paths → verify: `tests/test-package-recipes.sh "$PWD"`
2. Install Cppcheck and run `make lint` in the existing full-CI job without changing aggregate semantics → verify: `tests/test-package-recipes.sh "$PWD" && make lint`
3. Document contributor usage, triage, suppressions, and baseline refresh policy in both audience-specific documents → verify: `rg -n "make lint|Cppcheck|baseline|suppression" CONTRIBUTING.md docs/architecture/build-and-test.md`
4. Run the complete local release-equivalent verification stack → verify: `make -j"$(nproc)" && xvfb-run --auto-servernum make check && xvfb-run --auto-servernum make distcheck`

## 19. Verification Script

1. Run `tests/test-package-recipes.sh "$PWD"` and confirm workflow contracts pass.
2. Run `make lint` and confirm it uses the same public command as CI.
3. Inspect the workflow's changed-path exclusions and confirm no lint-control path is excluded.
4. Run the complete build, Xvfb-backed test suite, and `distcheck`.
5. Push the branch and confirm GitHub's live `Classify changes`, `Full build and test`, and aggregate checks behave as documented.

## 20. Risks

- **Required-check breakage:** incorrect job dependencies could block every pull request; preserve and test aggregate semantics.
- **Path-filter bypass:** future exclusions could hide lint changes; policy tests name every control path expectation.
- **CI duration:** static analysis adds time; use normal checking and a bounded step rather than exhaustive analysis.
- **Environment drift:** Ubuntu package updates can change diagnostics; baseline changes require explicit review and live CI evidence.
