#!/bin/sh
set -eu

if test "$#" -ne 0; then
	echo "usage: $0" >&2
	exit 2
fi

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
build_dir=${MESON_BUILD_DIR:-$repo_root/build-meson-preflight}
output_dir=${DEB_OUTPUT_DIR:-$repo_root/deb-artifacts}

require_tool()
{
	tool=$1
	package=$2
	if ! command -v "$tool" >/dev/null 2>&1; then
		echo "error: install system package '$package' to provide $tool" >&2
		exit 1
	fi
}

require_tool meson meson
require_tool ninja ninja-build
require_tool xvfb-run xvfb
require_tool xauth xauth
require_tool python3 python3
if test -e "$repo_root/.git"; then
	require_tool git git
fi

if test -d "$build_dir"; then
	meson setup --reconfigure "$build_dir" --wrap-mode=nodownload
else
	meson setup "$build_dir" "$repo_root" --wrap-mode=nodownload
fi

meson compile -C "$build_dir"
xvfb-run --auto-servernum meson test -C "$build_dir"
"$repo_root/tools/run-c-lint.sh"
version=$(meson introspect --projectinfo "$build_dir" | python3 -c \
	'import json, sys; print(json.load(sys.stdin)["version"])')
if test -e "$repo_root/.git"; then
	meson dist -C "$build_dir" --formats=gztar --allow-dirty
	source_archive="$build_dir/meson-dist/xmms-$version.tar.gz"
	if test ! -f "$source_archive"; then
		echo "error: Meson did not produce xmms-$version.tar.gz source archive" >&2
		exit 1
	fi
elif test -n "${DEB_SOURCE_ARCHIVE:-}"; then
	source_archive=$DEB_SOURCE_ARCHIVE
	if test ! -f "$source_archive"; then
		echo "error: requested source archive not found: $source_archive" >&2
		exit 1
	fi
	mkdir -p "$build_dir/meson-dist"
	cp "$source_archive" "$build_dir/meson-dist/xmms-$version.tar.gz"
	source_archive="$build_dir/meson-dist/xmms-$version.tar.gz"
else
	echo "error: source archive preflight requires DEB_SOURCE_ARCHIVE=/path/to/xmms-VERSION.tar.gz outside a Git checkout" >&2
	exit 1
fi
DEB_OUTPUT_DIR="$output_dir" DEB_SOURCE_ARCHIVE="$source_archive" \
	MESON_BUILD_DIR="$build_dir" "$repo_root/tools/package-deb.sh"
MESON_BUILD_DIR="$build_dir" "$repo_root/tools/verify-release-artifacts.sh" \
	"$output_dir"
