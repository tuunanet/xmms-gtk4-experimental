#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}
repo_root=$(CDPATH= cd -- "$repo_root" && pwd)
if test ! -e "$repo_root/.git"; then
	printf '%s\n' 'ok - retained Autotools archive regression requires a source checkout'
	exit 0
fi

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

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-autotools-dist.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

mkdir "$tmpdir/source"
(
	cd "$repo_root"
	git ls-files -z | tar --null -T - -cf -
) | tar -C "$tmpdir/source" -xf -

(
    cd "$tmpdir/source"
    # This test can run from make check; do not pass its jobserver FDs to the
    # independent copied source tree.
    unset MAKEFLAGS MFLAGS
    ./configure --disable-esd >"$tmpdir/configure.log" 2>&1
    make dist-gzip >"$tmpdir/dist.log" 2>&1
)

tar -tzf "$tmpdir/source/xmms-$version.tar.gz" > "$tmpdir/archive-files.txt"
python3 - "$repo_root/Makefile.am" "$repo_root/Makefile.in" "$tmpdir/archive-files.txt" "$version" <<'PY'
import re
import sys
from pathlib import Path

makefile_am = Path(sys.argv[1]).read_text(encoding="utf-8")
makefile_in = Path(sys.argv[2]).read_text(encoding="utf-8")
archive_files = set(Path(sys.argv[3]).read_text(encoding="utf-8").splitlines())
version = sys.argv[4]
match = re.search(r"^MESON_DIST = \\\n(.*?)(?:\n\n|\Z)", makefile_am, re.MULTILINE | re.DOTALL)
if match is None:
    raise SystemExit("not ok - defines the Meson distribution manifest")
paths = [line.strip().rstrip("\\").strip() for line in match.group(1).splitlines()]
missing_manifest = [path for path in paths
                    if not re.search(r"^\s*" + re.escape(path) + r"\s*\\?$", makefile_in, re.MULTILINE)]
missing_archive = [path for path in paths
                   if "xmms-" + version + "/" + path not in archive_files]
if missing_manifest:
    raise SystemExit("not ok - generated manifest includes: " + ", ".join(missing_manifest))
if missing_archive:
    raise SystemExit("not ok - retained archive includes: " + ", ".join(missing_archive))
print("ok - retained Autotools archive includes every Meson distribution input")
PY

tar -xzf "$tmpdir/source/xmms-$version.tar.gz" -C "$tmpdir"
meson setup "$tmpdir/build" "$tmpdir/xmms-$version" --wrap-mode=nodownload >"$tmpdir/meson.log" 2>&1
printf '%s\n' 'ok - Meson configures the retained Autotools source archive'
