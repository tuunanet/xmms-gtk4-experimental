#!/bin/sh
set -eu

if test "$#" -ne 0; then
	echo "usage: $0" >&2
	exit 2
fi

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
build_dir=${MESON_BUILD_DIR:-$repo_root/build-meson}
output_dir=${DEB_OUTPUT_DIR:-$repo_root/deb-artifacts}

for command in meson ninja python3 xvfb-run; do
	if ! command -v "$command" >/dev/null 2>&1; then
		echo "error: Meson Debian packages require $command" >&2
		exit 1
	fi
done

if test -d "$build_dir"; then
	meson setup --reconfigure "$build_dir" "$repo_root" --wrap-mode=nodownload
else
	meson setup "$build_dir" "$repo_root" --wrap-mode=nodownload
fi

version=$(meson introspect --projectinfo "$build_dir" | python3 -c \
	'import json, sys; print(json.load(sys.stdin)["version"])')
if test -n "${DEB_SOURCE_ARCHIVE:-}"; then
	archive=$DEB_SOURCE_ARCHIVE
	if test ! -f "$archive"; then
		echo "error: requested source archive not found: $archive" >&2
		exit 1
	fi
elif test -e "$repo_root/.git"; then
	xvfb-run --auto-servernum meson dist -C "$build_dir" --formats=gztar
	archive="$build_dir/meson-dist/xmms-$version.tar.gz"
	if test ! -f "$archive"; then
		echo "error: Meson did not produce xmms-$version.tar.gz source archive" >&2
		exit 1
	fi
else
	echo 'error: Meson packaging requires DEB_SOURCE_ARCHIVE outside a Git checkout' >&2
	exit 1
fi

exec "$repo_root/tools/build-deb.sh" "$version" "$archive" "$output_dir" \
	"$repo_root/packaging"
