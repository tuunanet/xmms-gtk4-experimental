#!/bin/sh
set -eu

srcdir=${1:-.}

python3 - "$srcdir" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
failures = 0


def check(condition, description):
    global failures
    if condition:
        print(f"ok - {description}")
    else:
        print(f"not ok - {description}", file=sys.stderr)
        failures += 1


def read(path):
    try:
        return (root / path).read_text(encoding="utf-8")
    except OSError:
        return ""


settings_text = read(".pi/settings.json")
try:
    settings = json.loads(settings_text)
except json.JSONDecodeError:
    settings = {}
check(
    settings.get("packages") == ["npm:@bacnh85/pi-subagent@0.12.2"],
    "pins the approved project subagent package",
)
check(
    "allowUnconfirmedProjectAgents" not in settings,
    "does not bypass project-agent confirmation",
)
check(
    "allowExternalCwd" not in settings,
    "does not allow reviewer working directories outside the project",
)

ignore_text = read(".gitignore")
check("/.pi/npm/" in ignore_text, "ignores generated project npm contents")
check(
    all(path in ignore_text for path in ["/tests/test-font-load", "/tests/test-mpg123-file-duration"]),
    "ignores test binaries produced by reviewer verification",
)

agent_paths = sorted((root / ".pi/agents").glob("*.md")) if (root / ".pi/agents").is_dir() else []
check(
    [path.name for path in agent_paths] == ["xmms-reviewer-a.md", "xmms-reviewer-b.md"],
    "defines exactly the two approved project reviewers",
)

agents = []
for path in agent_paths:
    text = path.read_text(encoding="utf-8")
    parts = text.split("---", 2)
    frontmatter = parts[1] if len(parts) == 3 else ""
    body = parts[2].strip() if len(parts) == 3 else ""
    fields = {}
    for line in frontmatter.splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            fields[key.strip()] = value.strip()
    agents.append((fields, body))

if len(agents) == 2:
    expected_names = ["xmms-reviewer-a", "xmms-reviewer-b"]
    check([agent[0].get("name") for agent in agents] == expected_names, "uses distinct reviewer identities")
    declared_tools = [
        [tool.strip() for tool in agent[0].get("tools", "").split(",") if tool.strip()]
        for agent in agents
    ]
    expected_tools = ["read", "grep", "find", "ls", "bash"]
    check(all(tools == expected_tools for tools in declared_tools), "limits both reviewers to inspection and verification tools")
    check(all("edit" not in tools and "write" not in tools and "subagent" not in tools for tools in declared_tools), "omits mutation and recursive delegation tools")
    check(agents[0][1] == agents[1][1], "gives both reviewers an identical system rubric")
    body = agents[0][1]
    for phrase, description in [
        ("Do not modify", "forbids repository mutation"),
        ("must-fix", "requires categorized findings"),
        ("94", "requires the request-review score threshold"),
        ("verification command", "requires independent verification evidence"),
        ("PASS", "requires an explicit reviewer verdict"),
    ]:
        check(phrase in body, description)
else:
    for description in [
        "uses distinct reviewer identities",
        "limits both reviewers to inspection and verification tools",
        "omits mutation and recursive delegation tools",
        "gives both reviewers an identical system rubric",
        "forbids repository mutation",
        "requires categorized findings",
        "requires the request-review score threshold",
        "requires independent verification evidence",
        "requires an explicit reviewer verdict",
    ]:
        check(False, description)

prompt = read(".pi/prompts/dual-review.md")
check(prompt.count("xmms-reviewer-a") == 1, "dispatches Reviewer A exactly once")
check(prompt.count("xmms-reviewer-b") == 1, "dispatches Reviewer B exactly once")
for phrase, description in [
    ("agentScope: project", "selects project-local agents explicitly"),
    ("exactly two tasks", "limits dispatch to the two approved reviewers"),
    ("one parallel", "dispatches both reviewers in one parallel call"),
    ("identical", "requires identical self-contained briefs"),
    ("staged diff, unstaged diff, untracked file list and contents", "reviews the complete working change set"),
    ("potential secret or private data", "fails closed before disclosing sensitive untracked content"),
    ("Wait for both reports before assessing either", "preserves dual-blind report collection"),
    ("missing, failed, partial, timed-out, aborted, or repository-mutating review fails", "fails closed for incomplete or unsafe reviews"),
    ("compare it byte-for-byte", "detects status-visible reviewer changes"),
    ("does not prove that ignored content was untouched", "documents the residual bash mutation risk"),
    ("zero must-fix", "enforces the must-fix AND gate"),
    ("94", "enforces the score AND gate"),
    ("fresh contexts", "requires fresh reviewers after remediation"),
    ("five rounds", "caps review iterations"),
]:
    check(phrase in prompt, description)
for forbidden, description in [
    ("agentScope: user", "does not dispatch user-scoped agents"),
    ("agentScope: both", "does not broaden agent discovery scope"),
    ("allowUnconfirmedProjectAgents", "does not instruct confirmation bypass"),
    ("allowExternalCwd", "does not instruct external working directories"),
]:
    check(forbidden not in prompt, description)

claude = read("CLAUDE.md")
check("Project-local external-agent wiring is enabled." in claude, "records the enabled workspace capability")

sys.exit(1 if failures else 0)
PY
