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
test -f "$build_dir/xmms/i18n.h" || fail "generates i18n.h"
grep -F '#define ENABLE_NLS 1' "$build_dir/xmms/i18n.h" >/dev/null \
	|| fail "defines gettext support numerically in the Meson i18n header"
grep -F '#define DEV_DSP "/dev/dsp"' "$build_dir/config.h" >/dev/null \
	|| fail "configures the default OSS DSP path"
grep -F '#define DEV_MIXER "/dev/mixer"' "$build_dir/config.h" >/dev/null \
	|| fail "configures the default OSS mixer path"

collision_source="$build_dir/source-with-autotools-header"
collision_build_dir="$build_dir/collision-build"
mkdir "$collision_source"
if git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	git -C "$repo_root" archive --format=tar HEAD | tar -x -C "$collision_source"
else
	(cd "$repo_root" && tar -cf - .) | tar -xf - -C "$collision_source"
fi
cat > "$collision_source/xmms/i18n.h" <<'EOF'
#error Meson must select its generated i18n.h before retained Autotools output
EOF
meson setup "$collision_build_dir" "$collision_source" --wrap-mode=nodownload >/dev/null
${CC:-cc} -DHAVE_CONFIG_H \
	-I"$collision_build_dir" -I"$collision_build_dir/xmms" \
	-I"$collision_source" -I"$collision_source/xmms" \
	$(pkg-config --cflags gtk+-2.0 glib-2.0) \
	-c "$collision_source/xmms/ui_control.c" \
	-o "$collision_build_dir/ui_control.o" \
	|| fail "compiles with a retained Autotools gettext header"

esd_build_dir="$build_dir/esd"
if pkg-config --exists esound; then
	meson setup "$esd_build_dir" "$repo_root" --wrap-mode=nodownload \
		-Desd=enabled >/dev/null
	meson compile -C "$esd_build_dir" >/dev/null
	test -f "$esd_build_dir/Output/esd/libesdout.so" \
		|| fail "builds ESD when force-enabled"
	nm -D --defined-only "$esd_build_dir/Output/esd/libesdout.so" \
		| grep -E '[[:space:]]get_oplugin_info$' >/dev/null \
		|| fail "preserves the ESD plugin entry point"
else
	if meson setup "$esd_build_dir" "$repo_root" --wrap-mode=nodownload \
		-Desd=enabled >/dev/null 2>&1; then
		fail "fails force-enabled ESD without its system dependency"
	fi
fi

echo "ok - configures the no-download Meson option contract"
