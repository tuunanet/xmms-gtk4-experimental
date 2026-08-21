#!/bin/sh
set -eu

repo_root=${1:?repository root is required}
checker="$repo_root/tools/check-gnome-c-format.sh"
source="$repo_root/xmms/ui_gtk3_control.c"
header="$repo_root/xmms/ui_gtk3_control.h"
output_file=$(mktemp "${TMPDIR:-/tmp}/xmms-gnome-c-format.XXXXXX")
trap 'rm -f "$output_file"' EXIT HUP INT TERM

before=$(sha256sum "$source" "$header")
"$checker" "$repo_root" >/dev/null
after=$(sha256sum "$source" "$header")

if test "$before" != "$after"; then
	echo "format checker modified a managed source file" >&2
	exit 1
fi

if PATH=/nonexistent "$checker" "$repo_root" >"$output_file" 2>&1; then
	echo "format checker unexpectedly passed without clang-format" >&2
	exit 1
fi

grep -F "install system package 'clang-format'" "$output_file" >/dev/null || {
	echo "format checker lacks clang-format installation guidance" >&2
	exit 1
}

echo "ok - GNOME C format checker is non-mutating and fails clearly without clang-format"
