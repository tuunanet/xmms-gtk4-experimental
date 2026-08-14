#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	echo "usage: $0 VERSION [REPOSITORY_ROOT]" >&2
	exit 2
fi

expected=$1
root=${2:-.}

if ! printf '%s\n' "$expected" | grep -Eq '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'; then
	echo "error: '$expected' is not a MAJOR.MINOR.PATCH version" >&2
	exit 1
fi

for file in meson.build CHANGELOG.md; do
	if [ ! -f "$root/$file" ]; then
		echo "error: required release file is missing: $file" >&2
		exit 1
	fi
done

meson_versions=$(sed -n \
	-e "s/^project(.*version:[[:space:]]*'\\([^']*\\)'.*/\\1/p" \
	-e "/^project(/,/^)/ { s/^[[:space:]]*version:[[:space:]]*'\\([^']*\\)'.*/\\1/p; }" \
	"$root/meson.build")
meson_count=$(printf '%s\n' "$meson_versions" | grep -c . || true)
if [ "$meson_count" -ne 1 ]; then
	echo "error: meson.build must contain exactly one XMMS project version" >&2
	exit 1
fi
if [ "$meson_versions" != "$expected" ]; then
	echo "error: requested version $expected does not match meson.build version $meson_versions" >&2
	exit 1
fi

changelog_count=$(awk -v heading="## [$expected]" '
	index($0, heading) == 1 {
		suffix = substr($0, length(heading) + 1)
		if (suffix == "" || index(suffix, " - ") == 1 ||
		    index(suffix, " — ") == 1)
			count++
	}
	END { print count + 0 }
' "$root/CHANGELOG.md")
if [ "$changelog_count" -ne 1 ]; then
	echo "error: CHANGELOG.md must contain exactly one [$expected] release heading" >&2
	exit 1
fi

printf '%s\n' "$expected"
