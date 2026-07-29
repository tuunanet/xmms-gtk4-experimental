---
description: Run the XMMS Classic dual-blind request-review gate
argument-hint: "[extra review focus]"
---

Run the bigpowers `request-review` Santa Method for the current branch. Additional requested focus: ${@:-none}.

Hard prerequisites:

1. Confirm the branch is not `main` and a completed `audit-code` artifact exists for this change. Stop and explain if either prerequisite is absent.
2. Capture the exact pre-review output of `git status --porcelain=v1 --untracked-files=all`. Before placing untracked contents in a model brief, inspect them locally; if any may contain a potential secret or private data, stop without dispatching reviewers and explain the blocked disclosure. Never redact silently. Otherwise, build one self-contained review brief from repository evidence only. Include the intended behavior, merge base, committed diff, staged diff, unstaged diff, untracked file list and contents, relevant active epic or bug artifacts, applicable `CONVENTIONS.md` rules, the exact runnable verification command, security focus, and genuine uncertainty. Do not include implementation-chat reasoning.
3. Use the `subagent` tool in one parallel call with `agentScope: project`. Dispatch exactly two tasks: `xmms-reviewer-a` and `xmms-reviewer-b`.
4. Give both tasks identical self-contained brief text. The agent names may differ, but the task text and bounded repository instructions must not differ. Do not run either reviewer sequentially and do not pass either report to the other reviewer.
5. Preserve normal interactive project-agent confirmation. Never request or enable unconfirmed project agents or an external working directory.
6. Wait for both reports before assessing either. Read every finding from both reports before remediation.
7. Re-run `git status --porcelain=v1 --untracked-files=all` and compare it byte-for-byte with the captured pre-review output. Any status-visible difference fails the round and must be reported as a must-fix reviewer-safety violation. This check detects ordinary tracked-path and untracked-path changes; it does not prove that ignored content was untouched or that content was not changed and restored.
8. The AND gate passes only when both reports independently have zero must-fix findings and a score of at least 94. A missing, failed, partial, timed-out, aborted, or repository-mutating review fails the round.
9. If the gate fails, invoke `respond-review`, remediate accepted findings, and rerun both reviewers from fresh contexts with an updated identical brief. Stop after five rounds and request a human decision.
10. Report the round number, Reviewer A score and verdict, Reviewer B score and verdict, verification outcomes, status comparison and its limitation, combined categorized findings, and final AND-gate result.

Do not edit files while collecting the two blind reports.
