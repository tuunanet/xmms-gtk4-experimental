#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}
repo_root=$(CDPATH= cd -- "$repo_root" && pwd)
if test ! -e "$repo_root/.git"; then
	printf '%s\n' 'ok - retained source-archive package regression requires a source checkout'
	exit 0
fi

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-autotools-package.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

version=$(python3 - "$repo_root/meson.build" <<'PY'
import re
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text(encoding="utf-8")
match = re.search(r"^project\(.*?^\)", source, re.MULTILINE | re.DOTALL)
if match is None:
    raise SystemExit("not ok - finds the Meson project declaration")
version = re.search(r"^\s*version:\s*'([^']+)'", match.group(0), re.MULTILINE)
if version is None:
    raise SystemExit("not ok - finds the Meson project version")
print(version.group(1))
PY
)

mkdir "$tmpdir/source"
(
	cd "$repo_root"
	git ls-files -z | tar --null -T - -cf -
) | tar -C "$tmpdir/source" -xf -

(
	cd "$tmpdir/source"
	unset MAKEFLAGS MFLAGS
	./configure --disable-esd >"$tmpdir/configure.log" 2>&1
	make dist-gzip >"$tmpdir/dist.log" 2>&1
)

tar -xzf "$tmpdir/source/xmms-$version.tar.gz" -C "$tmpdir"
source_dir=$tmpdir/xmms-$version
(
	cd "$source_dir"
	unset MAKEFLAGS MFLAGS
	./configure --disable-esd >"$tmpdir/extracted-configure.log" 2>&1
	DEB_OUTPUT_DIR="$tmpdir/deb-artifacts" \
		make DEB_OUTPUT_DIR="$tmpdir/deb-artifacts" deb >"$tmpdir/package.log" 2>&1
)
"$source_dir/tests/verify-debian-package-contract.sh" "$tmpdir/deb-artifacts"
printf '%s\n' 'ok - retained source archive builds Meson Debian packages without VCS metadata'
