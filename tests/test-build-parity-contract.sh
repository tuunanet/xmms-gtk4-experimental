#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-meson-parity.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

verifier="$repo_root/tools/verify-build-parity.sh"
[ -x "$verifier" ] || fail "provides a Meson-to-legacy build parity verifier"

meson setup "$build_dir" "$repo_root" --wrap-mode=nodownload >/dev/null
meson compile -C "$build_dir" >/dev/null
"$verifier" "$build_dir"

rm -f "$build_dir/xmms/xmms"
if "$verifier" "$build_dir" >/dev/null 2>&1; then
	fail "rejects a missing legacy-named player output"
fi

echo "ok - compares the frozen legacy build inventory"
