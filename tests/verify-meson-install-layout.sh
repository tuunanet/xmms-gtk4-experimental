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

require_if_built()
{
  target_name=$1
  install_path=$2
  if meson introspect --targets "$build_dir" | python3 -c '
import json
import sys
name = sys.argv[1]
raise SystemExit(not any(target["name"] == name
                         for target in json.load(sys.stdin)))
' "$target_name"; then
    require_file "$install_path"
  fi
}

meson install -C "$build_dir" --destdir "$stage_dir" >/dev/null

for path in \
  "$bindir/xmms" \
  "$bindir/wmxmms" \
  "$bindir/xmms-config" \
  "$libdir/libxmms.so.4.1.3" \
  "$includedir/xmms/plugin.h" \
  "$includedir/xmms/xmmsctrl.h" \
  "$includedir/xmms/i18n.h" \
  "$libdir/xmms/Input/libmpg123.so" \
  "$libdir/xmms/Input/libwav.so" \
  "$libdir/xmms/Input/libtonegen.so" \
  "$libdir/xmms/Output/libALSA.so" \
  "$libdir/xmms/Output/libdisk_writer.so" \
  "$libdir/xmms/Effect/libecho.so" \
  "$libdir/xmms/Effect/libvoice.so" \
  "$libdir/xmms/Effect/libstereo.so" \
  "$libdir/xmms/General/libsong_change.so" \
  "$libdir/xmms/General/libir.so" \
  "$libdir/xmms/Visualization/libsanalyzer.so" \
  "$libdir/xmms/Visualization/libbscope.so" \
  "$datadir/xmms/wmxmms.xpm"
do
  require_file "$path"
done

for locale in $(tr '\n' ' ' < "$(dirname "$0")/../po/LINGUAS")
do
  require_file "$localedir/$locale/LC_MESSAGES/xmms.mo"
done

require_if_built cdaudio "$libdir/xmms/Input/libcdaudio.so"
require_if_built vorbis "$libdir/xmms/Input/libvorbis.so"
require_if_built mikmod "$libdir/xmms/Input/libmikmod.so"
require_if_built OSS "$libdir/xmms/Output/libOSS.so"
require_if_built esdout "$libdir/xmms/Output/libesdout.so"
require_if_built joy "$libdir/xmms/General/libjoy.so"
require_if_built ogl_spectrum "$libdir/xmms/Visualization/libogl_spectrum.so"

for header in configfile.h xmmsctrl.h dirbrowser.h util.h formatter.h titlestring.h \
  plugin.h fullscreen.h i18n.h
do
  printf '%s\n' "#include <xmms/$header>" | \
    ${CC:-cc} -x c -fsyntax-only -I"$install_root/$includedir" \
    $(pkg-config --cflags gtk+-2.0 glib-2.0) - \
    || fail "installs a self-contained public header: $header"
done

xmms_config="$install_root/$bindir/xmms-config"
test -x "$xmms_config" || fail 'installs an executable xmms-config'
test "$("$xmms_config" --version)" = '0.0.1' || fail 'configures xmms-config version'
test "$("$xmms_config" --plugin-dir)" = "$prefix/$libdir/xmms" || fail 'configures xmms-config plugin path'

printf '%s\n' 'ok - Meson staged install preserves the public layout'
