#!/bin/sh
set -eu

srcdir=${1:-.}
failures=0

ok()
{
	echo "ok - $1"
}

not_ok()
{
	echo "not ok - $1" >&2
	failures=$((failures + 1))
}

output_file=$(mktemp)
trap 'rm -f "$output_file"' EXIT HUP INT TERM

if PATH=/nonexistent "$srcdir/tools/run-c-lint.sh" >"$output_file" 2>&1; then
	not_ok "fails when Cppcheck is unavailable"
elif grep -F 'Cppcheck is required' "$output_file" >/dev/null; then
	ok "explains the missing Cppcheck prerequisite"
else
	not_ok "explains the missing Cppcheck prerequisite"
fi

if test "$failures" -ne 0; then
	echo "$failures C lint checks failed" >&2
	exit 1
fi
