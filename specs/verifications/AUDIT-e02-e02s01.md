# Audit — e02s01 project-local dual review

- Audited: 2026-07-29T09:08:22Z
- Branch: `chore/project-agent-reviewers`
- Base: `origin/main`
- Implementation head: `0ff8a11`
- Verdict: PASS

## Churn-first review

The repository has no `scripts/bp-churn-rank.sh`; a 90-day Git history fallback ranked `Makefile.in`, `Makefile.am`, `tests/test-package-recipes.sh`, `tests/Makefile`, `.gitignore`, `CONTRIBUTING.md`, and `specs/state.yaml` among the changed hotspots. Those paths and all new `.pi` resources received full review.

## Supply chain and security

- ✓ The new dependency is pinned as `@bacnh85/pi-subagent@0.12.2`, tagged `[SUS]`, and explicitly approved by the user on 2026-07-29.
- ✓ Package source, peer ranges, project-agent confirmation, cwd containment, tool validation, timeout behavior, and model fallback were inspected before adoption.
- ✓ `npm audit --prefix .pi/npm --omit=dev` reports zero known vulnerabilities.
- ✓ No secrets or credentials appear in `origin/main...HEAD`.
- ✓ Project settings do not bypass agent confirmation or workspace containment.
- ✓ `specs/security/REVIEW.md` reports no finding with confidence 8 or higher.
- ✓ Reviewer bash is documented as a residual trusted-agent risk rather than misrepresented as an OS sandbox.

## Provenance and metadata

- ✓ The active story contains `type`, `risk`, `context`, BCP, requirements, contracts, security analysis, and runnable verification steps.
- ✓ The selected package and rejected alternatives have source provenance and rationale in `SCOPE_LATEST.yaml`.
- ✓ The implementation uses documented Pi package, agent, and prompt interfaces; no undocumented custom extension code was added.

## Law of Demeter

- ✓ No production object collaboration or message chain was introduced.
- ✓ Project settings, role files, prompt, and contract test communicate only through Pi's documented resource boundaries.

## CONVENTIONS.md compliance

- ✓ Planning, impact, security, audit, and bug-triage output is under `specs/`.
- ✓ No issue creation, direct GitHub API call, or unauthorized Git operation was added.
- ✓ The work was isolated in `chore/project-agent-reviewers` and uses Conventional Commits.
- ✓ Authoritative and shipped Autotools metadata are synchronized.
- ✓ New paths were evaluated against CI classification, source distribution, Debian packaging, release automation, and ignore rules.

## Scope

- ✓ Changes are limited to project-agent review infrastructure, its static contracts, source-distribution support, and documentation.
- ✓ No XMMS runtime, ABI, API, socket, skin, or installed Debian package behavior changed.
- ✓ No general implementation agents, CI model credentials, or provider-diversity requirements were added.
- ✓ The reproducible GCC 15 default-build failure found during verification was investigated and logged as `BUG-2026-07-29T080737`; verification used the already-established Debian compatibility flag rather than hiding the failure.

## Boy Scout Rule

- ✓ Missing ignore entries for two generated test binaries were added when status comparison exposed them.
- ✓ Project instructions and contracts required by reviewers are now source-distributed.
- ✓ No dead or commented-out code was introduced.

## Types and safety

- ✓ No TypeScript implementation, `any`, suppression directive, or unsafe cast was introduced.
- ✓ JSON settings parse successfully; agent frontmatter and prompt contracts are mechanically checked.
- ✓ Shell and Python paths are quoted or represented through `pathlib`.

## Test coverage and F.I.R.S.T

- ✓ `tests/test-project-agent-wiring.sh` covers the exact package pin, trusted-setting defaults, generated-content ignores, reviewer identity, role parity, tool restrictions, mutation-policy limits, parallel prompt behavior, AND gate, and iteration cap.
- ✓ `tests/test-package-recipes.sh` covers `make check` and source-distribution wiring.
- ✓ Full `make check` and `make distcheck` execute the static contract.
- ✓ Fast: focused contract completes in 0.06 seconds locally.
- ✓ Independent: reads one checkout and requires no model credentials or network.
- ✓ Repeatable: exact pinned strings and checked-in files determine the result.
- ✓ Self-validating: assertions print `ok`/`not ok` and exit non-zero on failure.
- ✓ Timely: the failing contract was committed before implementation (`7f9b7c9`), then passed after implementation (`b97141c`).

## SOLID and heuristics

- ✓ Each resource has one responsibility: package declaration, reviewer role, invocation workflow, or static contract.
- ✓ Pi is extended through documented package/resource discovery rather than modified.
- ✓ The shell test uses two small helpers and a linear set of observable contract assertions.
- ✓ No hidden temporal coupling exists beyond the explicitly documented audit → dual review order.

## Refactoring smells

- **Duplicated Code:** Reviewer A and Reviewer B intentionally have identical system bodies. Duplication is the tested dual-blind contract; extraction would make each standalone agent definition incomplete.
- **Primitive Obsession:** Prompt strings are unavoidable because Markdown files are Pi's public configuration interface; exact phrases are guarded by behavior-oriented contract labels.
- No Mysterious Name, Feature Envy, Data Clumps, Message Chains, or Middle Man detected.

## Code style and clarity

- ✓ Names identify the project and reviewer role precisely.
- ✓ New files are focused and below 300 lines.
- ✓ Comments and documentation explain trust rationale and residual risk.
- ✓ No nested application logic or unrelated formatting was introduced.

## Rationalizations caught

- The initial status comparison was described too strongly. Independent smoke reviewers rejected that claim; the prompt, test, and risk documentation now explicitly limit it to status-visible changes.
- The first source-distribution run failed because reviewer-required project instructions were absent from `EXTRA_DIST`; the failure was fixed and `distcheck` rerun successfully.
- The GCC 15 configure/build failure was not dismissed; it was reproduced, isolated, verified, and logged for a separate fix.

## Round 1 remediation re-audit

- ✓ Correctness: the focused project-agent and packaging contracts pass after strengthening exact reviewer cardinality, fail-closed outcomes, fresh-context reruns, project scope, and all authoritative/shipped distribution entries.
- ✓ Security: untracked content now fails closed before model dispatch when it may contain a secret or private data; confirmation and external-CWD bypass instructions remain forbidden; the remediation diff contains no configured credential pattern.
- ✓ Test quality: the new assertions failed before the prompt fix, then passed; both focused contracts, full Xvfb-backed `make check`, and `make lint` pass.
- ✓ Build and packaging: every `.pi` resource is asserted in both `Makefile.am` and `Makefile.in`, and Debian install manifests are asserted not to include `.pi/` paths.
- ✓ Metadata: release bug totals match the open bug registry, active lifecycle files consistently report review in progress, and all changed YAML parses successfully.
- ✓ Performance: changes affect short static contract checks and lifecycle data only; no runtime or build hot path changed.
- ✓ Clarity and scope: changes directly address every Round 1 must-fix/should-fix finding without unrelated runtime edits.
- ✓ Refactoring smells: intentional A/B role duplication remains documented; no new Mysterious Name, Feature Envy, Data Clumps, Primitive Obsession, Message Chains, or Middle Man was introduced.
- ✓ Red flags: the full build refreshed tracked translation files; they were restored byte-for-byte from `HEAD` and excluded from the remediation diff rather than rationalized as relevant changes.

## Persisted-evidence review remediation

- ✓ Exact commands, exit codes, evidence-recording time, and concise terminal-output evidence are persisted for focused contracts, the local quality gate, distcheck, and diff checking.
- ✓ The focused contract was rerun at 2026-07-29T09:08:22Z; its 128 output lines hash to `ca9e28434a78735515d8e801d76a48eabf74ad77e34e4d39ffb5ee2fe6b0daa5` and every assertion passed.
- ✓ Exact safe pre/post status outputs are persisted separately; each is 340 bytes with SHA-256 `3055ad4cabdac249ddbc68047fe2a2bf5dce2f6216139800e8658ba34cd56b76`, and parsed content matches byte-for-byte.
- ✓ Final UAT/NFR paths are explicitly evaluated in `specs/IMPACT_LATEST.md`: they remain repository-only lifecycle evidence, trigger full CI classification, are absent from Debian install manifests, and intentionally follow the existing exclusion of `specs/` from source archives.
- ✓ All changed YAML/JSON parses, lifecycle totals agree, `git diff --check` passes, and no runtime or dependency behavior changed.

## Result

All implementation-audit, review-remediation, and persisted-evidence checks pass. A fresh final dual review independently reproduced the evidence and passed both reviewers at 100 with no findings; the change is ready for release.
