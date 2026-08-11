# WORKFLOW: Solo Git

**Trigger:** Use for normal solo feature, fix, and maintenance delivery.

The machine-readable recipe is [`workflows/solo-git.yaml`](workflows/solo-git.yaml).

| Step | Skill | Gate |
| --- | --- | --- |
| 1 | `survey-context` | Read project state and resolve lifecycle drift. |
| 2 | Planning skill for the task | Approve scope and runnable verification. |
| 3 | `kickoff-branch` | Start from updated, clean `main`; pass `tools/preflight.sh`; create a worktree. |
| 4 | `develop-tdd` or `execute-plan` | Keep the task branch green. |
| 5 | `run-evals` and `verify-work` | Pass automated and manual verification. |
| 6 | `audit-code` | Pass conventions, security, traceability, and diff review. |
| 7 | `commit-message` | Commit verified task changes and prepare the Conventional Commit squash message. |
| 8 | `release-branch` | Select **Release (solo-local)** and land from the primary checkout. |

Land only through:

```sh
bash scripts/land-branch.sh <branch> "<conventional-message>"
```

The task worktree must be clean, and its verified changes must be committed.
The land script owns the squash commit on `main`, pushes it, removes the task
worktree, and returns the primary checkout to `main`. Do not commit directly on
`main`. Pull requests are opt-in. If remote protection blocks the push, the
script stops without opening one. Select the pull-request path explicitly.
