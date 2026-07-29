# e01s01: Run a baseline-aware C lint gate locally

<!-- story: e01s01 -->

**type:** feat

**risk:** P0

**context:** infrastructure

**bcps:** 5

## 1. Summary

Add one repeatable `make lint` entry point that scans maintained C code with Cppcheck, accepts reviewed legacy findings, and fails on any finding outside that baseline.

## 2. User

XMMS Classic contributors and maintainers running quality checks before opening a pull request.

## 3. Problem

The project has compiler warnings but no static-analysis command or regression policy. Enabling a strict analyzer directly would either fail on legacy debt or force a risky, unrelated cleanup.

## 4. Value

Contributors receive actionable C defect feedback while maintainers can enable enforcement without changing runtime behavior or hiding new findings behind a permanently growing warning count.

## 5. Context

Cppcheck is selected by the research in `specs/product/SCOPE_LATEST.yaml`. Its official manual defines plain-text suppressions as `[error id]:[filename]:[line]`, permits comments, and loads them with `--suppressions-list=<file>`. Ubuntu 24.04's Cppcheck 2.13 package is the authoritative baseline environment.

## 6. In Scope

- Maintained C and header paths, including test sources.
- Explicit exclusion of generated compatibility sources under `intl/`.
- Checked-in legacy suppressions with diagnostic IDs and narrow locations.
- A deterministic runner and public `make lint` target.
- Tests for clean-baseline success, missing prerequisites, and new-diagnostic failure.

## 7. Out of Scope

- Fixing all existing diagnostics.
- Linting non-C languages or generated sources.
- Automatic formatting or source-level suppression comments.
- Runtime, ABI, API, plugin, socket, configuration, skin, or GTK2 changes.

## 8. Dependencies

- **[OK] Cppcheck:** mature, actively released, C-specific, available from Ubuntu 24.04, and appropriately scoped.
- POSIX shell and existing Autotools/Make infrastructure.

## 9. Module Purpose

The new runner owns analyzer invocation, version reporting, source scope, stable flags, and baseline loading. `Makefile.am` exposes it through the project's established contributor command surface.

## 10. Callers

Contributors call `make lint`; shell tests call the runner directly; CI calls the same public target in e01s02; source-distribution checks consume entries added to `EXTRA_DIST`.

## 11. Contracts

- Exit zero only when no unsuppressed diagnostic is reported.
- Exit non-zero with an actionable message when Cppcheck is missing.
- Resolve paths from the source tree so in-tree and out-of-tree builds behave consistently.
- Do not write into or modify source/build products.
- Keep the baseline reviewable and narrowly scoped; no global diagnostic-ID suppression.

## 12. Requirements

### ADDED: Public C lint command

The project SHALL provide `make lint` as the documented local C static-analysis command.

### ADDED: Legacy finding baseline

The lint command SHALL load a checked-in, reviewable suppression baseline and reject diagnostics that are not represented there.

### ADDED: Maintained-source boundary

The lint command SHALL analyze maintained C sources and headers while excluding generated compatibility sources.

### ADDED: Prerequisite failure

The lint command SHALL fail clearly when the supported analyzer is unavailable.

## 13. Design

Use a small POSIX shell runner rather than duplicating analyzer flags in Make and CI. **Reason for Depth:** one thin runner is necessary to keep source selection, baseline loading, and failure semantics identical across local, test, and CI callers.

Use native Cppcheck suppression entries instead of a custom snapshot comparison. New unsuppressed diagnostics receive a non-zero error exit code; baseline maintenance remains an explicit reviewed file change.

## 14. Files and Data

- `tools/run-c-lint.sh` — analyzer contract.
- `tools/cppcheck-suppressions.txt` — reviewed legacy baseline.
- `tests/test-c-lint.sh` — executable contract tests.
- `Makefile.am` and shipped `Makefile.in` — public target and distribution entries.

## 15. Error Handling

Missing tools, unreadable baseline files, unsupported invocation state, and analyzer findings fail closed. Diagnostics remain visible on standard error. No retry is appropriate because failures are deterministic local inputs.

## 16. Security

Security impact is low: the runner analyzes trusted repository files and performs no network access, privilege escalation, or runtime execution of analyzed code. Shell arguments and paths must remain quoted.

## 17. Acceptance Criteria

### Scenario: Reviewed legacy baseline passes

```gherkin
Given Cppcheck 2.13 and the checked-in source tree
When a contributor runs make lint
Then all maintained C code is analyzed
And reviewed legacy findings are suppressed
And the command exits successfully
```

### Scenario: A new diagnostic is rejected

```gherkin
Given a C source containing a representative unsuppressed defect
When the lint runner analyzes that source with the checked-in policy
Then Cppcheck reports the diagnostic
And the command exits non-zero
```

### Scenario: Analyzer is unavailable

```gherkin
Given Cppcheck is not available on PATH
When the lint runner starts
Then it prints an installation-oriented error
And exits non-zero without modifying the tree
```

## 18. Implementation Steps

1. Add failing shell contract tests for source scope, prerequisite handling, baseline success, and representative diagnostic rejection → verify: `tests/test-c-lint.sh "$PWD"`
2. Add the POSIX runner and reviewed Cppcheck suppression baseline using the confirmed native suppression design (ref: `4f295ef`) → verify: `tools/run-c-lint.sh`
3. Add `make lint` plus complete source-distribution entries to authoritative and shipped Automake files → verify: `make lint && tests/test-package-recipes.sh "$PWD"`
4. Verify the lint controls work from the source distribution boundary → verify: `xvfb-run --auto-servernum make distcheck`

## 19. Verification Script

1. Install the Ubuntu 24.04 `cppcheck` package.
2. Run `tests/test-c-lint.sh "$PWD"` and observe all contract cases pass.
3. Run `make lint` and confirm the reviewed baseline passes.
4. Run `git status --short` and confirm linting created no source-tree changes.
5. Run `xvfb-run --auto-servernum make distcheck` and confirm the lint files are distributed.

## 20. Risks

- **Version drift:** newer Cppcheck releases may emit additional diagnostics; CI 2.13 is authoritative and the runner reports its version.
- **Baseline drift:** line-specific suppressions may need review after source movement; controlled updates are preferable to broad patterns.
- **Coverage gaps:** preprocessor configurations can limit analysis; tests assert maintained path coverage and future changes can tighten configurations.
- **Distribution drift:** missing `EXTRA_DIST` entries would break tarball use; `distcheck` is mandatory.
