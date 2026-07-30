#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-meson-dist.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

dist_build=$work_dir/dist-build
extract_root=$work_dir/extract
extracted_build=$work_dir/extracted-build

fail()
{
  printf '%s\n' "not ok - $1" >&2
  exit 1
}

command -v meson >/dev/null || fail 'Meson is required'
command -v tar >/dev/null || fail 'tar is required'
command -v xvfb-run >/dev/null || fail 'xvfb-run is required'
git -C "$repo_root" diff --quiet || fail 'working tree has unstaged changes'
git -C "$repo_root" diff --cached --quiet || fail 'working tree has staged changes'

meson setup "$dist_build" "$repo_root" --wrap-mode=nodownload >/dev/null
meson dist -C "$dist_build" >/dev/null
archive=$(find "$dist_build/meson-dist" -maxdepth 1 -type f -name 'xmms-*.tar.*' | head -n 1)
test -n "$archive" || fail 'meson dist did not produce a source archive'

mkdir "$extract_root"
tar -xf "$archive" -C "$extract_root"
source_dir=$(find "$extract_root" -mindepth 1 -maxdepth 1 -type d | head -n 1)
test -n "$source_dir" || fail 'source archive did not contain a source directory'
test -f "$source_dir/meson.build" || fail 'source archive lacks meson.build'
test -x "$source_dir/tests/verify-meson-install-layout.sh" || fail 'source archive lacks staged install verifier'

meson setup "$extracted_build" "$source_dir" --wrap-mode=nodownload >/dev/null
meson compile -C "$extracted_build" >/dev/null
xvfb-run --auto-servernum meson test -C "$extracted_build" --print-errorlogs
"$source_dir/tests/verify-meson-install-layout.sh" "$extracted_build"

printf '%s\n' 'ok - Meson source archive builds, tests, and staged-installs cleanly'
