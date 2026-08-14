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

# Test the preflight implementation under development against a fresh Git
# checkout, then make its release version dirty without committing it.
cp "$repo_root/tools/preflight.sh" "$checkout/tools/preflight.sh"
cp "$repo_root/tools/package-deb.sh" "$checkout/tools/package-deb.sh"
cp "$repo_root/README.md" "$checkout/README.md"
cp "$repo_root/CONTRIBUTING.md" "$checkout/CONTRIBUTING.md"
current_version=$(sed -n \
	"/^project(/,/^)/s/^[[:space:]]*version:[[:space:]]*'\\([^']*\\)'.*/\\1/p" \
	"$checkout/meson.build")
old_ifs=$IFS
IFS=.
set -- $current_version
IFS=$old_ifs
test "$#" -eq 3 || fail "reads the Meson release version"
dirty_version="$1.$2.$(( $3 + 1 ))"
sed -i "s/version: '$current_version'/version: '$dirty_version'/" \
	"$checkout/meson.build"
rm "$checkout/docs/history/prior-fork-changelog.md"
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
git -C "$checkout" status --porcelain | grep -Fx ' M meson.build' >/dev/null \
	|| fail "preflight leaves the dirty release version intact"
git -C "$checkout" status --porcelain | grep -Fx ' D docs/history/prior-fork-changelog.md' >/dev/null \
	|| fail "preflight leaves the tracked deletion intact"

source_archive=$(find "$checkout/build-meson-preflight/meson-dist" -maxdepth 1 \
	-name "xmms-$dirty_version.tar.gz" -print -quit)
test -f "$source_archive" \
	|| fail "Git preflight creates a source archive for the dirty release version"
archive_root="$tmpdir/source-archive"
mkdir "$archive_root"
tar -xzf "$source_archive" -C "$archive_root"
source_tree=$(find "$archive_root" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$source_tree" || fail "source archive extracts a project directory"
test ! -e "$source_tree/.git" || fail "source archive has no Git metadata"
archive_version=$(sed -n \
	"/^project(/,/^)/s/^[[:space:]]*version:[[:space:]]*'\\([^']*\\)'.*/\\1/p" \
	"$source_tree/meson.build")
test "$archive_version" = "$dirty_version" \
	|| fail "source archive contains the dirty release version"
test ! -e "$source_tree/docs/history/prior-fork-changelog.md" \
	|| fail "source archive preserves the tracked deletion"

runtime=$(find "$git_output_dir" -maxdepth 1 -type f -name 'xmms_*.deb' -print -quit)
stage_dir="$tmpdir/package-stage"
dpkg-deb -x "$runtime" "$stage_dir"
library_dir=$(find "$stage_dir/usr/lib" -mindepth 1 -maxdepth 1 -type d -print -quit)
test "$(LD_LIBRARY_PATH="$library_dir" "$stage_dir/usr/bin/xmms" --version)" = \
	"xmms $dirty_version" \
	|| fail "extracted package reports the dirty release version"

DEB_SOURCE_ARCHIVE="$source_archive" "$source_tree/tools/preflight.sh"

fifo_checkout="$tmpdir/fifo-checkout"
git clone --quiet --no-local "$repo_root" "$fifo_checkout"
cp "$repo_root/tools/preflight.sh" "$fifo_checkout/tools/preflight.sh"
mkfifo "$fifo_checkout/preflight-input.fifo"
fifo_log="$tmpdir/fifo.log"
if DEB_OUTPUT_DIR="$tmpdir/fifo-deb-artifacts" \
	"$fifo_checkout/tools/preflight.sh" >"$fifo_log" 2>&1; then
	fail "preflight rejects an unsupported untracked FIFO"
fi
grep -F 'error: unsupported source snapshot entry: preflight-input.fifo' \
	"$fifo_log" >/dev/null \
	|| fail "preflight explains an unsupported untracked FIFO"

echo "ok - dirty-worktree and extracted-source preflight use declared system tools only"
