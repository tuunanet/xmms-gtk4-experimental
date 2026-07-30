#!/bin/sh
set -eu

build_dir=${1:?usage: verify-meson-output-contract.sh BUILD_DIR}

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

require_file()
{
	test -f "$build_dir/$1" || fail "builds $1"
}

require_file xmms/xmms
require_file wmxmms/wmxmms
require_export()
{
	module=$1
	symbol=$2
	require_file "$module"
	nm -D --defined-only "$build_dir/$module" \
		| grep -E "[[:space:]]${symbol}$" >/dev/null \
		|| fail "$module exports $symbol"
}

require_file libxmms/libxmms.so.4.1.3
for contract in \
	Input/mpg123/libmpg123.so:get_iplugin_info \
	Input/wav/libwav.so:get_iplugin_info \
	Input/tonegen/libtonegen.so:get_iplugin_info \
	Input/cdaudio/libcdaudio.so:get_iplugin_info \
	Input/vorbis/libvorbis.so:get_iplugin_info \
	Input/mikmod/libmikmod.so:get_iplugin_info \
	Output/alsa/libALSA.so:get_oplugin_info \
	Output/OSS/libOSS.so:get_oplugin_info \
	Output/disk_writer/libdisk_writer.so:get_oplugin_info \
	Effect/echo_plugin/libecho.so:get_eplugin_info \
	Effect/voice/libvoice.so:get_eplugin_info \
	Effect/stereo_plugin/libstereo.so:get_eplugin_info \
	General/song_change/libsong_change.so:get_gplugin_info \
	General/ir/libir.so:get_gplugin_info \
	General/joystick/libjoy.so:get_gplugin_info \
	Visualization/sanalyzer/libsanalyzer.so:get_vplugin_info \
	Visualization/blur_scope/libbscope.so:get_vplugin_info \
	Visualization/opengl_spectrum/libogl_spectrum.so:get_vplugin_info
 do
	require_export "${contract%%:*}" "${contract#*:}"
done
require_file tests/test-gtk3-play-button-proof

if ! ldd "$build_dir/tests/test-gtk3-play-button-proof" | grep -F 'libgtk-3.so' >/dev/null; then
	fail "links the GTK3 proof to GTK3"
fi
if ldd "$build_dir/tests/test-gtk3-play-button-proof" | grep -F 'libgtk-x11-2.0.so' >/dev/null; then
	fail "keeps GTK2 out of the GTK3 proof"
fi

echo "ok - preserves full supported plugin and isolated GTK3 Meson outputs"
