#!/bin/sh
set -eu

artifact_dir=${1:?usage: $0 ARTIFACT_DIRECTORY}

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

require_file()
{
	test -f "$1" || fail "$2"
}

require_glob()
{
	for path in $1; do
		if test -f "$path" || test -L "$path"; then
			return 0
		fi
	done
	fail "$2"
}

require_absent_glob()
{
	for path in $1; do
		if test -e "$path" || test -L "$path"; then
			fail "$2"
		fi
	done
}

for command in dpkg-deb mktemp readelf; do
	command -v "$command" >/dev/null 2>&1 || fail "requires $command"
done

if test ! -d "$artifact_dir"; then
	fail 'requires an artifact directory'
fi
runtime=$(find "$artifact_dir" -maxdepth 1 -type f -name 'xmms_*.deb' -print)
devel=$(find "$artifact_dir" -maxdepth 1 -type f -name 'libxmms-dev_*.deb' -print)
test -n "$runtime" && test -z "$(printf '%s\n' "$runtime" | sed -n '2p')" \
	|| fail 'contains exactly one xmms package'
test -n "$devel" && test -z "$(printf '%s\n' "$devel" | sed -n '2p')" \
	|| fail 'contains exactly one libxmms-dev package'

test "$(dpkg-deb --field "$runtime" Package)" = xmms \
	|| fail 'runtime package name is xmms'
test "$(dpkg-deb --field "$devel" Package)" = libxmms-dev \
	|| fail 'development package name is libxmms-dev'
test "$(dpkg-deb --field "$runtime" Version)" = \
	"$(dpkg-deb --field "$devel" Version)" \
	|| fail 'runtime and development versions match'
test "$(dpkg-deb --field "$runtime" Architecture)" = \
	"$(dpkg-deb --field "$devel" Architecture)" \
	|| fail 'runtime and development architectures match'

stage_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-debian-contract.XXXXXX")
trap 'rm -rf "$stage_dir"' EXIT HUP INT TERM
dpkg-deb -x "$runtime" "$stage_dir/runtime"
dpkg-deb -x "$devel" "$stage_dir/devel"

require_file "$stage_dir/runtime/usr/bin/xmms" 'installs xmms'
require_file "$stage_dir/runtime/usr/bin/wmxmms" 'installs wmxmms'
require_glob "$stage_dir/runtime/usr/lib/*/libxmms.so.1*" \
	'installs the libxmms runtime library'
runtime_library=$(find "$stage_dir/runtime/usr/lib" -type f -name 'libxmms.so.1*' \
	-print -quit)
test -n "$runtime_library" || fail 'finds the libxmms runtime ELF library'
runtime_soname=$(readelf -d "$runtime_library" \
	| sed -n 's/.*(SONAME).*\[\([^]]*\)\].*/\1/p')
test "$runtime_soname" = libxmms.so.1 \
	|| fail 'preserves the libxmms ELF SONAME'
require_glob "$stage_dir/runtime/usr/lib/*/xmms/Input/libmpg123.so" \
	'installs the MP3 input plugin'
require_file "$stage_dir/runtime/usr/share/applications/xmms.desktop" \
	'installs the desktop entry'
require_file "$stage_dir/runtime/usr/share/icons/hicolor/16x16/apps/xmms.xpm" \
	'installs the application icon'
require_file "$stage_dir/runtime/usr/share/man/man1/xmms.1.gz" \
	'installs the compressed xmms manual page'
require_file "$stage_dir/runtime/usr/share/man/man1/wmxmms.1.gz" \
	'installs the compressed wmxmms manual page'
require_file "$stage_dir/runtime/usr/share/xmms/wmxmms.xpm" \
	'installs the Window Maker icon data'

require_file "$stage_dir/devel/usr/bin/xmms-config" \
	'installs xmms-config'
require_file "$stage_dir/devel/usr/include/xmms/plugin.h" \
	'installs the plugin API header'
require_glob "$stage_dir/devel/usr/lib/*/libxmms.a" \
	'installs the static libxmms archive'
require_glob "$stage_dir/devel/usr/lib/*/libxmms.so" \
	'installs the libxmms linker name'
require_file "$stage_dir/devel/usr/share/aclocal/xmms.m4" \
	'installs the plugin build macro'
require_absent_glob "$stage_dir/runtime/usr/lib/*/*.la" \
	'does not install libtool archives in the runtime package'
require_absent_glob "$stage_dir/devel/usr/lib/*/*.la" \
	'does not install libtool archives in the development package'

echo 'ok - Meson Debian packages preserve runtime and development contracts'
