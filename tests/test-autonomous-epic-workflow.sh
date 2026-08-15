#!/bin/sh
set -eu

srcdir=${1:-.}
srcdir=$(cd "$srcdir" && pwd)

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

require_text()
{
	grep -F -- "$2" "$1" >/dev/null || fail "$3"
}

claude="$srcdir/CLAUDE.md"
recipe="$srcdir/specs/workflows/autonomous-epic.yaml"

for required in \
	'## Autonomous Epic Execution' \
	'MUST continue through every approved story in the active epic' \
	'MUST NOT request routine confirmation after a green task, story, or gate'
do
	require_text "$claude" "$required" 'documents autonomous epic execution'
done

for required in \
	'schema_version: 1' \
	'name: autonomous-epic' \
	'command: /autonomous-epic' \
	'    execution_mode: autonomous' \
	'    continue_until: active_epic_complete' \
	'  after_green_gate: advance' \
	'  on_reproducible_failure: investigate_and_repair' \
	'  - unresolved_scope_or_ambiguity' \
	'  - destructive_operation' \
	'  - credentials_or_sensitive_data' \
	'  - immutable_tag_or_release_authorization' \
	'  - external_blocker_or_exhausted_retries' \
	'grep -Fx "    execution_mode: autonomous"'
do
	require_text "$recipe" "$required" 'preserves the autonomous epic policy'
done

feedback_count=$(sed -n '/^human_feedback_required_for:/,/^terminal_states:/p' \
	"$recipe" | grep -c '^  - ')
test "$feedback_count" -eq 5 || fail 'limits human feedback to declared terminal conditions'
if grep -E '^(import yaml|from yaml import)' "$recipe" "$0" >/dev/null; then
	fail 'does not require PyYAML for policy verification'
fi

printf '%s\n' 'ok - project automation advances approved epic work without routine checkpoints'
