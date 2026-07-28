# Impact Assessment: C lint regression gate

## Target

The change will extend these existing integration surfaces:

- `Makefile.am` — authoritative top-level Automake source and public contributor targets.
- `.github/workflows/ci.yml` — pull-request path classification and required build/test orchestration.
- `tests/test-package-recipes.sh` — executable assertions over workflow and distribution policy.
- `CONTRIBUTING.md` and `docs/architecture/build-and-test.md` — contributor and architecture contracts for local and CI verification.

It will add a Cppcheck runner, checked-in configuration/baseline, and focused shell tests without changing runtime modules.

## Purpose, Callers, and Contracts

### `Makefile.am`

- **Purpose:** Defines top-level distribution contents, recursive build behavior, tests, cleanup, and public maintenance targets.
- **Callers:** Automake-generated `Makefile`, contributors invoking `make`, CI jobs, `make distcheck`, and Debian packaging.
- **Contracts:** Existing targets retain behavior; new distributed lint files are present in source archives; `make lint` does not alter build products or require a configured runtime build.

### `.github/workflows/ci.yml`

- **Purpose:** Classifies pull-request paths and supplies the protected branch's aggregate `build-and-test` result.
- **Callers:** GitHub pull requests, pushes to `main`, manual dispatches, and branch protection.
- **Contracts:** The aggregate required check always reports; documentation-only changes can still skip expensive runtime checks; C and lint-control changes cannot bypass lint; jobs remain bounded by timeouts.

### `tests/test-package-recipes.sh`

- **Purpose:** Guards repository-level build, packaging, and workflow policy through portable shell assertions.
- **Callers:** `tests/Makefile`, `make check`, `make distcheck`, and CI.
- **Contracts:** POSIX `sh`, deterministic file/text checks, aggregated failures, and no network or elevated privileges.

## Dependents

1. Generated top-level `Makefile` behavior depends on `Makefile.am`.
2. `make check` and `make distcheck` invoke `tests/test-package-recipes.sh` through `tests/Makefile`.
3. Every pull request and push to `main` depends on `.github/workflows/ci.yml` classification and aggregation.
4. Debian and source-distribution jobs depend on `EXTRA_DIST` completeness.
5. Contributors depend on `CONTRIBUTING.md` for supported local commands.
6. Architecture maintainers depend on `docs/architecture/build-and-test.md` for CI topology and path-filter behavior.
7. `.github/actions/setup-ccache/action.yml` hashes C, headers, Automake inputs, and `configure.in`; linting must not invalidate its compilation-cache contract unnecessarily.

## Affected Stories

- **e01s01:** Run a baseline-aware C lint gate locally.
- **e01s02:** Enforce the C lint regression gate in pull requests.

No previously shipped runtime story or public interface is modified.

## Test Coverage

- `tests/test-c-lint.sh` will cover source discovery, accepted legacy baseline, missing/wrong tool prerequisites, and rejection of a representative new diagnostic.
- `tests/test-package-recipes.sh` will cover the public `make lint` target, distribution inclusion, CI installation/execution, and path-classification policy.
- `make lint` will provide analyzer-level end-to-end evidence.
- `make -j"$(nproc)" && xvfb-run --auto-servernum make check` will guard existing build and behavior.
- `make distcheck` will verify source-archive completeness and out-of-tree operation.

### Gaps

- GitHub's hosted runner and path-filter action cannot be reproduced perfectly offline; text-contract tests reduce but do not eliminate that integration risk.
- Cppcheck diagnostic output can drift across versions; CI's Ubuntu 24.04 package is the authoritative baseline environment.

## Risk: High

The change does not touch runtime code, but CI classification and the required aggregate check affect every pull request, while top-level Automake distribution rules affect release artifacts.

## Recommended Action

Proceed test-first. Establish failing shell assertions before adding the runner or workflow job, keep lint independent from runtime artifacts, run `make distcheck`, and require live PR checks before merge.
