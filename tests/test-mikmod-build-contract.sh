#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-mikmod-build.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

meson setup "$build_dir" "$repo_root" --wrap-mode=nodownload \
	-Dmikmod=enabled >/dev/null
meson compile -C "$build_dir" mikmod >/dev/null \
	|| fail "builds the force-enabled MikMod module"
module="$build_dir/Input/mikmod/libmikmod.so"
test -f "$module" || fail "produces libmikmod.so"
nm -D --defined-only "$module" | grep -E '[[:space:]]get_iplugin_info$' >/dev/null \
	|| fail "exports the XMMS input-plugin entry point"

echo "ok - builds the modern libmikmod callback boundary"
