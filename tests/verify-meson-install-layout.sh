#!/bin/sh
set -eu

build_dir=${1:?usage: $0 BUILD_DIR}
stage_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-meson-install.XXXXXX")
trap 'rm -rf "$stage_dir"' EXIT HUP INT TERM

fail()
{
  printf '%s\n' "not ok - $1" >&2
  exit 1
}

require_file()
{
  test -f "$stage_dir/usr/local/$1" || fail "installs $1"
}

meson install -C "$build_dir" --destdir "$stage_dir" >/dev/null

for path in \
  bin/xmms \
  bin/wmxmms \
  bin/xmms-config \
  lib/libxmms.so.4.1.3 \
  include/xmms/plugin.h \
  include/xmms/xmmsctrl.h \
  lib/xmms/Input/libmpg123.so \
  lib/xmms/Output/libALSA.so \
  share/xmms/wmxmms.xpm \
  share/man/man1/xmms.1 \
  share/man/man1/wmxmms.1 \
  share/locale/de/LC_MESSAGES/xmms.mo
do
  require_file "$path"
done

printf '%s\n' 'ok - Meson staged install preserves the public layout'
