#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}
mode=${2:-}

case "$mode" in
  --geometry|--render)
    test_name=gtk3-main-window-shell
    ;;
  --transport)
    test_name=gtk3-main-window-transport
    ;;
  --linkage)
    test_name=
    ;;
  *)
    echo "usage: $0 REPO_ROOT --geometry|--render|--transport|--linkage" >&2
    exit 2
    ;;
esac

build_dir="$repo_root/build-meson"
if [ ! -f "$build_dir/build.ninja" ]; then
  meson setup "$build_dir" "$repo_root" --wrap-mode=nodownload
fi

if [ "$mode" = "--linkage" ]; then
  for binary in test-gtk3-play-button-proof test-gtk3-main-window-shell \
               test-gtk3-main-window-transport; do
    binary_path="$build_dir/tests/$binary"
    test -x "$binary_path" || {
      echo "missing GTK3 tracer binary: $binary_path" >&2
      exit 1
    }
    ldd "$binary_path" | grep -F 'libgtk-3.so' >/dev/null
    if ldd "$binary_path" | grep -F 'libgtk-x11-2.0.so' >/dev/null; then
      echo "GTK2 dependency in GTK3 tracer: $binary_path" >&2
      exit 1
    fi
  done
  grep -F 'test-gtk3-main-window-shell' \
    "$repo_root/tests/verify-meson-output-contract.sh" >/dev/null
  grep -F 'gtk3-main-window-transport' \
    "$repo_root/tests/test-meson-test-suite-contract.sh" >/dev/null
  grep -F 'e07 GTK3 main-window tracer' \
    "$repo_root/docs/architecture/ui-interaction.md" >/dev/null
  echo 'ok - GTK3 tracer linkage and delivery markers are present'
else
  meson test -C "$build_dir" "$test_name" --print-errorlogs
fi
