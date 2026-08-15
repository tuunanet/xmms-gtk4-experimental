#!/usr/bin/env python3
"""Validate the release and active-epic facts recorded in lifecycle YAML."""

import re
import sys
from pathlib import Path


def require_text(path, pattern, description):
    text = Path(path).read_text(encoding="utf-8")
    if not re.search(pattern, text, re.MULTILINE):
        raise SystemExit(f"error: {path}: {description}")


def main():
    if len(sys.argv) != 4:
        raise SystemExit(
            "usage: validate-lifecycle-state.py STATE EXECUTION_STATUS RELEASE_PLAN"
        )

    state, execution_status, release_plan = sys.argv[1:]
    require_text(state, r"^active_epic_id: e05$", "must identify e05 as active")
    require_text(state, r"^  last_tag: v0\.0\.2$", "must record the v0.0.2 tag")
    require_text(
        state,
        r"^  last_publish: failed-draft-release-workflow$",
        "must record the failed draft-release workflow",
    )
    require_text(
        state,
        r"(?ms)^handoff:\n  status: in_progress$",
        "must record the active e05 release repair",
    )
    require_text(
        execution_status,
        r"^status: in_progress$",
        "must mark the active execution in progress",
    )
    require_text(
        execution_status,
        r"^  e05: in_progress$",
        "must mark e05 repair in progress",
    )
    require_text(
        execution_status,
        r"^  e05s06: in_progress$",
        "must mark e05s06 repair in progress",
    )
    require_text(
        release_plan,
        r"(?ms)^  - id: e05$.*?^    status: in_progress$",
        "must mark e05 repair in progress in the release plan",
    )
    require_text(execution_status, r"^  e04: verified$", "must mark e04 verified")
    require_text(execution_status, r"^  e04s01: verified$", "must mark e04s01 verified")
    require_text(
        release_plan,
        r"(?ms)^  - id: e04$.*?^    status: verified$",
        "must mark e04 verified in the release plan",
    )


if __name__ == "__main__":
    main()
