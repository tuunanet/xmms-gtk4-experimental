# Project-local dual-review impact

## Target

Add project-scoped Pi package settings, prompt templates, and two reviewer definitions under `.pi/`; update `.gitignore` and the workspace fact in `CLAUDE.md`.

## Dependents (5)

- Pi project startup: reads `.pi/settings.json`, installs the pinned package after trust, and discovers `.pi/prompts/`.
- `@bacnh85/pi-subagent`: discovers `.pi/agents/*.md` when invoked with `agentScope: project`.
- bigpowers `request-review`: supplies the required dual-blind review and AND-gate contract.
- Contributors and maintainers: approve repository-controlled agent execution and consume both reports.
- Git/GitHub path handling: `.gitignore` excludes generated `.pi/npm/`; `.pi/**` is not excluded by `.github/workflows/ci.yml`, so this PR receives full CI.

## Affected Stories

- e02s01: Enable project-local dual review.
- Pending keyboard-shortcuts bug delivery: gains the external dual-review gate after this infrastructure PR merges.
- e01 C lint stories: unaffected; their implementation is already merged and verified.

## Test Coverage

- `make check` contract coverage validates the package pin, exact reviewer set, matching review rubric, restricted declared tools, prompt AND-gate instructions, and distribution wiring.
- End-to-end UAT will load the project package, start both reviewers in parallel, collect two reports, and compare repository status before and after.
- Existing `make -j"$(nproc)" && xvfb-run --auto-servernum make check` covers the unaffected XMMS build and runtime test boundary.
- Gap: automated CI cannot execute model-backed reviewers without credentials and project trust, so model execution remains explicit UAT.

## Workflow, packaging, and release classification

- `.pi/settings.json`, `.pi/agents/*.md`, and `.pi/prompts/*.md` do not match the documentation-only exclusions in `.github/workflows/ci.yml`; full CI is expected without workflow edits.
- The checked-in `.pi` settings, roles, prompt, and static contract test are listed in root `EXTRA_DIST` so source-distribution users can inspect the trust boundary before approval.
- Debian install manifests do not include `.pi`, so runtime and development package contents remain unchanged.
- Release workflows package the Autotools source archive and Debian artifacts; `distcheck` verifies the new source-distribution entries without workflow edits.
- Final UAT and NFR records under `specs/verifications/` are intentionally repository-only lifecycle evidence, matching the existing treatment of `specs/`: they are not installed by Debian manifests or listed in root `EXTRA_DIST`. Because `specs/**` is not excluded by CI path filters, these new evidence paths retain full CI classification. Release automation requires no path update.
- `.pi/npm/` is an installation cache and must be ignored rather than committed.

## Risk: High

The change does not affect XMMS runtime behavior, but a project-installed Pi extension and repository-controlled prompts form a local code-execution trust boundary. Version pinning, interactive approval, limited reviewer tools, source inspection, and end-to-end verification are mandatory.

## Recommended action

Proceed with one P0 infrastructure story. Keep interactive project-agent confirmation enabled, avoid edit/write tools, run reviewers only in the current workspace, and require manual dual-review acceptance before delivery.
