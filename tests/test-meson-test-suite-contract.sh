#!/bin/sh
set -eu

repo_root=${1:?usage: $0 REPO_ROOT}
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-meson-test-contract.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM

rm -f "$repo_root/xmms/i18n.h"
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
  outputplugin \
  alsa-pcm-state \
  alsa-volume \
  mpg123-file-duration \
  mpg123-stream-position \
  c-lint \
  intl-generated-sources \
  meson-migration-contracts \
  meson-configure-contract \
  mikmod-build-contract \
  build-parity-contract \
  package-recipes \
  plugin-linkage \
  meson-output-contract \
  release-tools \
  meson-test-suite-contract \
  meson-dist-contract
do
  printf '%s\n' "$registered_tests" | grep -Fx "$expected_test" >/dev/null || {
    printf '%s\n' "missing Meson test registration: $expected_test" >&2
    exit 1
  }
done

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
