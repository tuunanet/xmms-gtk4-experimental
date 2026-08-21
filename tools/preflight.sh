#!/bin/sh
set -eu

if test "$#" -gt 1 || { test "$#" -eq 1 && test "$1" != '--strict'; }; then
	echo "usage: $0 [--strict]" >&2
	exit 2
fi

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
build_dir=${MESON_BUILD_DIR:-$repo_root/build-meson-preflight}
output_dir=${DEB_OUTPUT_DIR:-$repo_root/deb-artifacts}
snapshot_root=

cleanup_snapshot()
{
	if test -n "$snapshot_root"; then
		rm -rf "$snapshot_root"
	fi
}

trap cleanup_snapshot EXIT HUP INT TERM

reject_unsupported_source_entries()
{
	python3 - "$repo_root" <<'PY'
import os
import stat
import subprocess
import sys

root = sys.argv[1]
for parent, directories, names in os.walk(root, topdown=True,
                                         followlinks=False):
    directories[:] = [name for name in directories if name != '.git']
    for name in names:
        path = os.path.join(parent, name)
        mode = os.lstat(path).st_mode
        if stat.S_ISREG(mode) or stat.S_ISLNK(mode):
            continue
        relative = os.path.relpath(path, root)
        if subprocess.run(['git', '-C', root, 'check-ignore', '-q', '--',
                           relative], check=False).returncode == 0:
            continue
        print(f'error: unsupported source snapshot entry: {relative}',
              file=sys.stderr)
        raise SystemExit(1)
PY
}

create_dirty_source_archive()
{
	snapshot_root=$(mktemp -d "${TMPDIR:-/tmp}/xmms-preflight-source.XXXXXX")
	snapshot_source="$snapshot_root/xmms-$version"
	snapshot_build="$snapshot_root/build"
	file_list="$snapshot_root/files"

	mkdir "$snapshot_source"
	git -C "$repo_root" ls-files -z --cached --others --exclude-standard > "$file_list"
	python3 - "$repo_root" "$snapshot_source" "$file_list" <<'PY'
import os
import shutil
import stat
import sys

source_root, snapshot_root, file_list = map(os.fsdecode, sys.argv[1:])
with open(file_list, 'rb') as paths:
    for path in paths.read().split(b'\0'):
        if not path:
            continue
        relative = os.fsdecode(path)
        source = os.path.join(source_root, relative)
        destination = os.path.join(snapshot_root, relative)
        if not os.path.lexists(source):
            continue
        os.makedirs(os.path.dirname(destination), exist_ok=True)
        source_mode = os.lstat(source).st_mode
        if stat.S_ISLNK(source_mode):
            os.symlink(os.readlink(source), destination)
        elif stat.S_ISREG(source_mode):
            shutil.copy2(source, destination, follow_symlinks=False)
        else:
            raise SystemExit(
                f'error: unsupported source snapshot entry: {relative}')
PY
	git -C "$snapshot_source" init --quiet
	git -C "$snapshot_source" add -A
	git -C "$snapshot_source" \
		-c user.name='XMMS preflight' \
		-c user.email='preflight@example.invalid' \
		commit --quiet -m 'preflight source snapshot'
	meson setup "$snapshot_build" "$snapshot_source" --wrap-mode=nodownload
	meson dist -C "$snapshot_build" --formats=gztar
	mkdir -p "$build_dir/meson-dist"
	cp "$snapshot_build/meson-dist/xmms-$version.tar.gz" \
		"$build_dir/meson-dist/xmms-$version.tar.gz"
}

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
require_tool clang-format clang-format
if test -e "$repo_root/.git"; then
	require_tool git git
	reject_unsupported_source_entries
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
	if test -n "$(git -C "$repo_root" status --porcelain)"; then
		create_dirty_source_archive
	else
		meson dist -C "$build_dir" --formats=gztar --allow-dirty
	fi
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
