#!/bin/sh
set -eu

srcdir=${1:-.}
srcdir=$(cd "$srcdir" && pwd)

python3 - "$srcdir" <<'PY'
from pathlib import Path
import sys
import yaml

srcdir = Path(sys.argv[1])
claude = (srcdir / 'CLAUDE.md').read_text()
for required in (
    '## Autonomous Epic Execution',
    'MUST continue through every approved story in the active epic',
    'MUST NOT request routine confirmation after a green task, story, or gate',
):
    assert required in claude, required

recipe_path = srcdir / 'specs/workflows/autonomous-epic.yaml'
recipe = yaml.safe_load(recipe_path.read_text())
assert recipe['schema_version'] == 1
assert recipe['name'] == 'autonomous-epic'
assert recipe['command'] == '/autonomous-epic'
assert recipe['args']['build-epic']['execution_mode'] == 'autonomous'
assert recipe['args']['build-epic']['continue_until'] == 'active_epic_complete'
assert recipe['args']['execute-plan']['execution_mode'] == 'autonomous'
assert recipe['continuation']['after_green_gate'] == 'advance'
assert recipe['continuation']['on_reproducible_failure'] == 'investigate_and_repair'
assert recipe['human_feedback_required_for'] == [
    'unresolved_scope_or_ambiguity',
    'destructive_operation',
    'credentials_or_sensitive_data',
    'immutable_tag_or_release_authorization',
    'external_blocker_or_exhausted_retries',
]
PY

printf '%s\n' 'ok - project automation advances approved epic work without routine checkpoints'
