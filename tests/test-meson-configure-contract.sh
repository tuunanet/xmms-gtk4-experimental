#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-meson-configure.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

require_option()
{
	grep -F "option('$1'" "$repo_root/meson_options.txt" >/dev/null \
		|| fail "declares Meson option $1"
}

for option in one-plugin-dir user-plugin-dir dev-dsp dev-mixer \
	cdda-device cdda-dir gtk3-proof opengl esd mikmod vorbis simd ipv6 oss
 do
	require_option "$option"
done

test -f "$repo_root/meson.build" || fail "provides a root Meson project"
meson setup "$build_dir" "$repo_root" --wrap-mode=nodownload >/dev/null
meson configure "$build_dir" | grep -F 'gtk3-proof' >/dev/null \
	|| fail "reports the GTK3 proof option"
test -f "$build_dir/config.h" || fail "generates config.h"
grep -F '#define DEV_DSP "/dev/dsp"' "$build_dir/config.h" >/dev/null \
	|| fail "configures the default OSS DSP path"
grep -F '#define DEV_MIXER "/dev/mixer"' "$build_dir/config.h" >/dev/null \
	|| fail "configures the default OSS mixer path"
echo "ok - configures the no-download Meson option contract"
