#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-preflight-clean.XXXXXX")
checkout="$tmpdir/checkout"
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

git clone --quiet --no-local "$repo_root" "$checkout"
test -z "$(git -C "$checkout" status --porcelain)" \
	|| fail "creates a clean checkout"
test ! -e "$checkout/build-meson-preflight" \
	|| fail "starts without a pre-existing Meson build"
printf '\npreflight dirty-worktree regression\n' >> "$checkout/README.md"
git_output_dir="$tmpdir/git-deb-artifacts"

DEB_OUTPUT_DIR="$git_output_dir" "$checkout/tools/preflight.sh"

test -d "$checkout/build-meson-preflight" \
	|| fail "preflight creates its isolated Meson build"
test ! -d "$checkout/subprojects/packagecache" \
	|| fail "preflight does not download Meson wraps"
test -f "$git_output_dir"/xmms_*.deb \
	|| fail "preflight writes the runtime package to DEB_OUTPUT_DIR"
test -f "$git_output_dir"/libxmms-dev_*.deb \
	|| fail "preflight writes the development package to DEB_OUTPUT_DIR"
test ! -e "$checkout/deb-artifacts" \
	|| fail "preflight does not use the default package directory when overridden"
test "$(git -C "$checkout" status --porcelain)" = " M README.md" \
	|| fail "preflight leaves no unignored build or package artifacts"

source_archive=$(find "$checkout/build-meson-preflight/meson-dist" -maxdepth 1 \
	-name 'xmms-*.tar.gz' -print -quit)
test -f "$source_archive" || fail "Git preflight creates a source archive"
archive_root="$tmpdir/source-archive"
mkdir "$archive_root"
tar -xzf "$source_archive" -C "$archive_root"
source_tree=$(find "$archive_root" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$source_tree" || fail "source archive extracts a project directory"
test ! -e "$source_tree/.git" || fail "source archive has no Git metadata"
DEB_SOURCE_ARCHIVE="$source_archive" "$source_tree/tools/preflight.sh"

echo "ok - dirty-worktree and extracted-source preflight use declared system tools only"
