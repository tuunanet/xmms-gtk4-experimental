# e02s01: Enable project-local dual review

<!-- story: e02s01 -->

**type:** feat

**risk:** P0

**context:** infrastructure

**bcps:** 5

## 1. Summary

Add a trusted project-local Pi configuration that starts two independent repository-aware reviewers in parallel and enforces the bigpowers request-review AND gate.

## 2. User

XMMS Classic maintainers preparing verified feature and bug-fix branches for pull requests.

## 3. Problem

The project requires two fresh external reviewer agents, but no project package or repository-specific reviewer roles are available. Completed work therefore cannot satisfy the dual-blind request-review gate locally.

## 4. Value

Maintainers can obtain two independent reviews with a repeatable repository-owned rubric, while preserving explicit trust approval and keeping review separate from remediation.

## 5. Context

Pi 0.82.1 loads trusted project packages from `.pi/settings.json`, project agents from `.pi/agents/`, and prompt templates from `.pi/prompts/`. The approved `@bacnh85/pi-subagent@0.12.2` package declares peer support for Pi `>=0.80.0 <0.83.0` and exposes parallel isolated SDK sessions with project-agent confirmation, workspace containment, bounded execution, and parent-model fallback.

The package README contains one stale narrower compatibility sentence. Published peer metadata and end-to-end execution are therefore authoritative for this integration.

## 6. In Scope

- A pinned project-local subagent package declaration.
- Exactly two project reviewer definitions with identical review behavior.
- A project prompt that prepares identical briefs and invokes both reviewers in parallel.
- Contract checks for configuration, role parity, tool restrictions, AND-gate instructions, `make check`, and source distribution.
- Interactive end-to-end UAT with repository-state comparison.
- Project instruction and ignore-rule updates.

## 7. Out of Scope

- CI-hosted model execution.
- Reviewer edit/write capabilities.
- General-purpose project agents.
- Mandatory provider diversity.
- Changes to XMMS runtime, installed Debian package contents, ABI, API, socket, configuration, skin, or GTK behavior.

## 8. Dependencies

- **[SUS, user-approved] `@bacnh85/pi-subagent@0.12.2`:** actively published, pinned, MIT licensed, current Pi peer range, and strong trust-boundary controls; stale README compatibility prose requires end-to-end verification.
- **[OK] Pi 0.82.1 project package, agent, and prompt discovery:** locally installed and documented by the authoritative Pi package.
- Existing bigpowers `request-review` skill for the Santa Method rubric and pass threshold.

## 9. Module Purpose

The `.pi` project configuration owns repository-specific agent wiring only: package loading, reviewer role definitions, and the dual-review invocation prompt. It does not own code remediation or pull-request authorization.

**Reason for Depth:** a project package declaration, two isolated role files, and one prompt are the minimum separate resources required by Pi's package, agent-discovery, and prompt-template interfaces.

## 10. Callers

Maintainers invoke `/dual-review`; Pi project startup consumes settings and prompt files; the subagent extension discovers both role files; bigpowers `request-review` supplies the review contract; `make check` runs the static wiring contract; `make distcheck` verifies that the inspectable trust-boundary files ship in source archives.

## 11. Contracts

- Project agents execute only after explicit interactive trust approval by default.
- Reviewer A and Reviewer B receive identical task briefs in separate child sessions.
- Neither reviewer sees the implementation conversation or the other report before both finish.
- Role declarations omit `edit` and `write`; bash usage is limited by the reviewer system prompt to inspection and the supplied verification command.
- Both reports categorize findings, report verification, calculate score, and return PASS or FAIL.
- The parent accepts the round only when both have zero must-fix findings and score at least 94.
- Installed package caches and generated contents remain untracked.

## 12. Requirements

### ADDED: Pinned project subagent package

The repository SHALL declare the exact approved subagent package version in project-local Pi settings and SHALL ignore generated project package installation contents.

### ADDED: Independent reviewer roles

The repository SHALL provide Reviewer A and Reviewer B as separate project-agent identities with the same system rubric and without edit or write tools.

### ADDED: Dual-blind parallel invocation

The project dual-review prompt SHALL construct one self-contained brief, dispatch both reviewers in parallel with project scope, and withhold either report from the other reviewer.

### ADDED: AND-gate verdict

The dual-review workflow SHALL pass only when both independent reports have zero must-fix findings and each score is at least 94 percent.

### ADDED: Trust-preserving execution

Project-agent execution SHALL retain interactive confirmation, workspace containment, bounded execution, and no committed credentials or model output.

### ADDED: Static and source-distribution coverage

The normal test suite SHALL validate the reviewer wiring without model credentials, and source distributions SHALL include the checked-in settings, reviewer roles, prompt, and contract test for inspection before trust approval.

## 13. Design

Use `.pi/settings.json` to pin the reviewed package rather than vendoring its implementation. Define two role files because report independence and clear A/B attribution are explicit request-review requirements. Keep their system bodies identical so role identity does not create different review instructions.

Use a prompt template as the only user entry point. It directs the parent Pi session to prepare one brief from repository evidence and call the package's parallel mode once with `agentScope: project`. Reviewer agents read repository instructions themselves and receive a bounded task contract because child sessions do not automatically inherit project instructions.

## 14. Files and Data

- `.pi/settings.json` — pinned project package declaration.
- `.pi/agents/xmms-reviewer-a.md` and `xmms-reviewer-b.md` — isolated reviewer identities.
- `.pi/prompts/dual-review.md` — repeatable parent workflow.
- `tests/test-project-agent-wiring.sh` and `tests/Makefile` — static contract checks without model credentials.
- `Makefile.am` and `Makefile.in` — source-distribution entries for inspectable project-agent resources.
- `.gitignore` — generated `.pi/npm/` exclusion.
- `CLAUDE.md` — enabled workspace fact.
- `specs/` — plan, impact, state, and verification evidence.

No credentials, sessions, child output, npm package cache, or generated dependencies are stored.

## 15. Error Handling

Missing package installation, malformed agent frontmatter, unknown reviewers, unavailable models, rejected trust confirmation, timeouts, and failed child sessions fail closed. A missing or failed report cannot satisfy the AND gate. After five unsuccessful review rounds, the workflow stops for human decision as required by request-review.

## 16. Security

Risk is high because Pi packages execute with local system access and project prompts are repository-controlled. Mitigations are exact version pinning, source inspection, normal Pi project trust, mandatory interactive project-agent confirmation, workspace-constrained child sessions, bounded timeouts, reviewer tool restriction, explicit no-mutation system instructions, and repository-state comparison after UAT.

Child reports are untrusted model output. The parent validates findings against repository evidence and never treats a report as authorization to merge or execute arbitrary commands.

## 17. Acceptance Criteria

### Scenario: Pi discovers the project reviewers

```gherkin
Given a trusted checkout and the pinned project package
When Pi loads the project configuration
Then the subagent extension is available
And Reviewer A and Reviewer B are discoverable from .pi/agents
```

### Scenario: Dual review remains blind and parallel

```gherkin
Given one self-contained review brief
When a maintainer invokes the dual-review prompt
Then Reviewer A and Reviewer B start as separate isolated sessions in one parallel call
And both receive identical task text
And neither receives the other reviewer's report
```

### Scenario: Project-agent execution requires approval

```gherkin
Given the default trusted settings
When the workflow requests the project reviewers interactively
Then Pi asks the maintainer to approve the repository-controlled agents
And declining approval prevents either reviewer from running
```

### Scenario: Review AND gate is enforced

```gherkin
Given two completed reviewer reports
When either report has a must-fix finding or a score below 94 percent
Then the review round fails
And both reviewers must be rerun after remediation
```

### Scenario: Review does not alter the branch

```gherkin
Given a recorded repository status before review
When both reviewers complete
Then repository status after review matches the recorded status
And no package cache, credentials, sessions, or report output are tracked
```

## 18. Implementation Steps

1. Add failing shell contract checks for the package pin, ignored package cache, exact reviewer identities, matching rubric, restricted declared tools, and dual-review prompt → verify: `tests/test-project-agent-wiring.sh "$PWD"`
2. Add pinned project settings, `.pi/npm/` ignore handling, and the two project reviewer roles with no edit/write tools → verify: `tests/test-project-agent-wiring.sh "$PWD" && git check-ignore -q .pi/npm/example`
3. Add `/dual-review`, wire the static contract into `make check` and source distribution, and update the project workspace fact while preserving explicit confirmation and the request-review AND gate → verify: `tests/test-project-agent-wiring.sh "$PWD" && tests/test-package-recipes.sh "$PWD" && rg -q 'external-agent wiring is enabled' CLAUDE.md`
4. Install and execute the pinned package with both isolated project reviewers, record status-visible state comparison and residual-risk evidence, and persist acceptance → verify: `test -f specs/verifications/e02s01-verify.yaml && grep -q 'dual_review: passed' specs/verifications/e02s01-verify.yaml`
5. Prove XMMS remains unaffected → verify: `make -j"$(nproc)" && xvfb-run --auto-servernum make check`

## 19. Verification Script

1. Start Pi from the feature worktree and trust the project when prompted.
2. Confirm `pi list --approve` shows `npm:@bacnh85/pi-subagent@0.12.2` as a project package.
3. Run `tests/test-project-agent-wiring.sh "$PWD"`.
4. Record `git status --short`.
5. Invoke `/dual-review` with the current branch as its target.
6. Approve both named project reviewers when Pi displays the trust prompt.
7. Confirm the TUI shows two concurrent project-agent sessions and returns separately attributed A and B reports.
8. Confirm each report includes categorized findings, verification result, score, and verdict.
9. Re-run `git status --short` and confirm it matches step 4.
10. Run the XMMS Preflight command.

## 20. Risks

- **Supply-chain execution:** the extension has local access; exact pinning, source review, trust confirmation, and a dedicated PR make changes visible.
- **Documentation drift:** README compatibility prose conflicts with package peer metadata; end-to-end execution gates acceptance.
- **Review mutation through bash:** tools omit direct editors and the system prompt forbids mutation, but bash is retained for verification. Status comparison detects ordinary tracked-path and untracked-path changes, not writes to ignored content or mutate-then-restore behavior; trusted project approval and report validation remain necessary controls.
- **Provider availability:** explicit reviewer models could be unavailable; role files omit model pins so the authenticated parent model is the fallback.
- **Cost multiplication:** two child sessions consume model resources concurrently; the workflow is invoked only at the review gate.
- **Non-deterministic output:** independent reports may disagree; the strict AND gate intentionally fails closed.
