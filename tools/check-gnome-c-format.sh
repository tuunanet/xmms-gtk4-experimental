#!/bin/sh
set -eu

repo_root=${1:?repository root is required}
format_config="$repo_root/tools/clang-format-gnome.yml"

if ! command -v clang-format >/dev/null 2>&1; then
	echo "error: install system package 'clang-format' to check GNOME C formatting" >&2
	exit 1
fi

for relative_path in xmms/ui_gtk3_control.c xmms/ui_gtk3_control.h; do
	path="$repo_root/$relative_path"
	if ! clang-format --style="file:$format_config" --dry-run --Werror "$path"; then
		echo "error: format $relative_path with: clang-format --style=file:$format_config -i $relative_path" >&2
		exit 1
	fi
done

echo "ok - GNOME C formatting is current"
