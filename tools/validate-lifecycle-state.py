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
    require_text(state, r"^active_flow: sustain$", "must hand off the completed cutover to sustain mode")
    require_text(state, r"^  last_tag: v0\.0\.6$", "must record the immutable published v0.0.6 tag")
    require_text(
        state,
        r"^  last_publish: published-v0\.0\.6$",
        "must record the published v0.0.6 release",
    )
    require_text(
        state,
        r"(?ms)^handoff:\n  status: complete$",
        "must record the completed e05 release handoff",
    )
    require_text(
        execution_status,
        r"^status: verified$",
        "must mark the completed execution verified",
    )
    require_text(
        execution_status,
        r"^  e05: verified$",
        "must mark e05 verified",
    )
    require_text(
        execution_status,
        r"^  e05s06: verified$",
        "must mark e05s06 verified",
    )
    require_text(
        release_plan,
        r"(?ms)^  - id: e05$.*?^    status: verified$",
        "must mark e05 verified in the release plan",
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
