#!/bin/sh
set -eu

repo_root=${1:?usage: $0 REPO_ROOT}
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-meson-test-contract.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM

meson setup "$build_dir" "$repo_root" --wrap-mode=nodownload >/dev/null

registered_tests=$(meson test -C "$build_dir" --list | sed 's/^[^:]*://')
for expected_test in \
  xentry \
  filebrowser \
  font-load \
  popup-position \
  pbutton-baseline \
  ui-control \
  pluginenum \
  pluginenum-meson-build \
  outputplugin \
  outputplugin-meson-build \
  alsa-pcm-state \
  alsa-volume \
  mpg123-file-duration \
  mpg123-stream-position \
  no-autotools-artifacts \
  no-autotools-artifacts-source \
  c-lint \
  gnome-c-dependency-contract \
  meson-migration-contracts \
  preflight \
  meson-documentation-contract \
  meson-configure-contract \
  mikmod-build-contract \
  build-parity-contract \
  package-recipes \
  debian-package-contract \
  release-artifacts \
  plugin-linkage \
  meson-output-contract \
  release-tools \
  solo-git-workflow \
  autonomous-epic-workflow \
  meson-test-suite-contract \
  meson-dist-contract
do
  printf '%s\n' "$registered_tests" | grep -Fx "$expected_test" >/dev/null || {
    printf '%s\n' "missing Meson test registration: $expected_test" >&2
    exit 1
  }
done

for source_mutating_test in meson-configure-contract build-parity-contract meson-test-suite-contract
do
  grep -A 2 "test('$source_mutating_test'" "$repo_root/tests/meson.build" \
    | grep -F 'is_parallel: false' >/dev/null || {
      printf '%s\n' "source-mutating Meson test is not serialized: $source_mutating_test" >&2
      exit 1
    }
done

grep -A 3 "test('build-parity-contract'" "$repo_root/tests/meson.build" \
  | grep -F 'timeout: 120' >/dev/null || {
    printf '%s\n' 'build-parity contract must declare a 120-second timeout' >&2
    exit 1
  }

meson compile -C "$build_dir" test-xentry >/dev/null 2>&1 || {
  printf '%s\n' 'registered Meson xentry test does not compile' >&2
  exit 1
}

if pkg-config --exists 'gtk+-3.0 >= 3.24'; then
  printf '%s\n' "$registered_tests" | grep -Fx gtk3-play-button-proof >/dev/null || {
    printf '%s\n' 'missing Meson test registration: gtk3-play-button-proof' >&2
    exit 1
  }
fi

printf '%s\n' 'ok - Meson registers the complete regression test inventory'
