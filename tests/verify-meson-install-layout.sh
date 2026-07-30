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

meson_option()
{
  meson introspect --buildoptions "$build_dir" | python3 -c '
import json
import sys
name = sys.argv[1]
for option in json.load(sys.stdin):
    if option["name"] == name:
        print(option["value"])
        break
else:
    raise SystemExit("missing Meson option: " + name)
' "$1"
}

prefix=$(meson_option prefix)
bindir=$(meson_option bindir)
libdir=$(meson_option libdir)
includedir=$(meson_option includedir)
datadir=$(meson_option datadir)
localedir=$(meson_option localedir)
install_root=$stage_dir$prefix

require_file()
{
  test -f "$install_root/$1" || fail "installs $1"
}

meson install -C "$build_dir" --destdir "$stage_dir" >/dev/null

for path in \
  "$bindir/xmms" \
  "$bindir/wmxmms" \
  "$bindir/xmms-config" \
  "$libdir/libxmms.so.4.1.3" \
  "$includedir/xmms/plugin.h" \
  "$includedir/xmms/xmmsctrl.h" \
  "$libdir/xmms/Input/libmpg123.so" \
  "$libdir/xmms/Input/libwav.so" \
  "$libdir/xmms/Input/libtonegen.so" \
  "$libdir/xmms/Input/libcdaudio.so" \
  "$libdir/xmms/Input/libvorbis.so" \
  "$libdir/xmms/Input/libmikmod.so" \
  "$libdir/xmms/Output/libALSA.so" \
  "$libdir/xmms/Output/libOSS.so" \
  "$libdir/xmms/Output/libdisk_writer.so" \
  "$libdir/xmms/Effect/libecho.so" \
  "$libdir/xmms/Effect/libvoice.so" \
  "$libdir/xmms/Effect/libstereo.so" \
  "$libdir/xmms/General/libsong_change.so" \
  "$libdir/xmms/General/libir.so" \
  "$libdir/xmms/General/libjoy.so" \
  "$libdir/xmms/Visualization/libsanalyzer.so" \
  "$libdir/xmms/Visualization/libbscope.so" \
  "$libdir/xmms/Visualization/libogl_spectrum.so" \
  "$datadir/xmms/wmxmms.xpm" \
  "$localedir/de/LC_MESSAGES/xmms.mo"
do
  require_file "$path"
done

xmms_config="$install_root/$bindir/xmms-config"
test -x "$xmms_config" || fail 'installs an executable xmms-config'
test "$("$xmms_config" --version)" = '0.0.1' || fail 'configures xmms-config version'
test "$("$xmms_config" --plugin-dir)" = "$prefix/$libdir/xmms" || fail 'configures xmms-config plugin path'

printf '%s\n' 'ok - Meson staged install preserves the public layout'
