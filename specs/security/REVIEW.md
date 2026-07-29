# Security Review

- Generated: 2026-07-29T08:52:28Z
- Branch: `chore/project-agent-reviewers`
- Base: `origin/main`
- Reviewed implementation head: `0ff8a11`
- Scope: pinned Pi package settings, project reviewer definitions, dual-review prompt, shell contracts, source-distribution wiring, documentation, and lifecycle specifications

## Verdict

PASS — no reportable vulnerability with confidence 8 or higher.

## Threat Model

- **Inputs:** Trusted repository configuration, maintainer-supplied review focus, repository files, verification commands selected from reviewed specifications, and model-generated reviewer output.
- **Trust boundaries:** Project trust approval; npm package installation; local Pi extension execution; reviewer `bash` execution; model output returned to the parent session.
- **Sensitive assets:** Contributor workstation files, Git working-tree integrity, model credentials held by Pi, and pull-request quality-gate integrity.
- **Failure modes:** Malicious package code, repository prompt manipulation, reviewer shell mutation, missing or partial reports, model prompt injection, or an AND gate that accepts incomplete evidence.

## Assessment

- `.pi/settings.json` pins exactly `@bacnh85/pi-subagent@0.12.2`; npm audit reported zero known vulnerabilities.
- The approved package source was inspected before adoption. Published peer metadata covers installed Pi 0.82.1; the stale README compatibility sentence is explicitly documented and end-to-end execution is required.
- Project settings do not enable `allowUnconfirmedProjectAgents` or `allowExternalCwd`. Interactive project-agent approval and workspace containment remain package defaults.
- Reviewer frontmatter omits `edit`, `write`, and recursive `subagent` tools. `bash` remains intentionally available for independent verification and is constrained by the higher-priority reviewer system prompt.
- The dual-review prompt uses one parallel call, identical task text, two isolated roles, wait-for-both handling, a five-round cap, and an AND gate requiring zero must-fix findings plus scores of at least 94.
- Potentially sensitive untracked content fails closed before dispatch rather than being copied into a model brief.
- Status comparison detects ordinary tracked-path and untracked-path changes but is not a filesystem sandbox. The prompt and story now state that ignored writes and mutate-then-restore behavior remain residual trusted-agent risks.
- Child reports are treated as untrusted model output and do not authorize merge or arbitrary execution.
- No secrets, credentials, tokens, direct GitHub API calls, unsafe deserialization, attacker-controlled shell interpolation, or privilege escalation were introduced.
- `.pi/npm/`, model output, sessions, package caches, and build artifacts are excluded from commits; inspectable settings and reviewer contracts are source-distributed.

## Findings

None at confidence 8 or higher.

## Residual Risks

- The pinned extension executes with contributor privileges after project trust. Version updates require renewed source review and explicit pin changes.
- Reviewer `bash` is policy-restricted rather than OS-sandboxed. A malicious or compromised reviewer could target ignored files or restore modified content before status comparison.
- Parallel sessions multiply provider usage and cost.
- Model output may contain inaccurate findings or prompt-injected instructions; the parent must validate evidence and enforce the AND gate.

---

## Keyboard shortcut fix — 2026-07-29

- Branch: `fix/keyboard-shortcuts`
- Base: `origin/main`
- Reviewed implementation head: `d43a936`
- Scope: GTK2 key-event delegation and the isolated X11 regression test

### Verdict

PASS — no reportable findings with confidence 8 or higher.

### Assessment

The only production change returns unrecognized key events to GTK2's existing
accelerator dispatcher. It introduces no new data parsing, command execution,
file access, network access, authentication boundary, secrets, or unsafe
deserialization. The X11 process-launching code is confined to the test suite,
uses fixed developer-authored arguments, isolates HOME and TMPDIR, and cleans
its generated runtime directory.

### Findings

None.
