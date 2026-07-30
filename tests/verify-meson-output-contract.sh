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
require_file libxmms/libxmms.so.4.1.3
require_file tests/test-gtk3-play-button-proof

if ! ldd "$build_dir/tests/test-gtk3-play-button-proof" | grep -F 'libgtk-3.so' >/dev/null; then
	fail "links the GTK3 proof to GTK3"
fi
if ldd "$build_dir/tests/test-gtk3-play-button-proof" | grep -F 'libgtk-x11-2.0.so' >/dev/null; then
	fail "keeps GTK2 out of the GTK3 proof"
fi

echo "ok - preserves core and isolated GTK3 Meson outputs"
