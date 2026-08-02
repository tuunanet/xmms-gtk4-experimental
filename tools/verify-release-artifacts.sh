#!/bin/sh
set -eu

artifact_dir=${1:?usage: $0 ARTIFACT_DIRECTORY}
repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
build_dir=${MESON_BUILD_DIR:-$repo_root/build-meson}

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

require_single_package()
{
	package=$(find "$artifact_dir" -maxdepth 1 -type f -name "$1" -print)
	test -n "$package" \
		&& test -z "$(printf '%s\n' "$package" | sed -n '2p')" \
		|| fail "$2"
	printf '%s\n' "$package"
}

for command in dpkg-deb mktemp sha256sum; do
	command -v "$command" >/dev/null 2>&1 || fail "requires $command"
done

if test ! -d "$artifact_dir"; then
	fail 'requires an artifact directory'
fi

artifact_dir=$(CDPATH= cd -- "$artifact_dir" && pwd)
runtime=$(require_single_package 'xmms_*.deb' 'contains exactly one xmms package')
development=$(require_single_package 'libxmms-dev_*.deb' \
	'contains exactly one libxmms-dev package')

runtime_version=$(dpkg-deb --field "$runtime" Version)
development_version=$(dpkg-deb --field "$development" Version)
test "$(dpkg-deb --field "$runtime" Package)" = xmms \
	|| fail 'runtime package metadata identifies xmms'
test "$(dpkg-deb --field "$development" Package)" = libxmms-dev \
	|| fail 'development package metadata identifies libxmms-dev'
test "$runtime_version" = "$development_version" \
	|| fail 'runtime and development package versions match'
test "$(dpkg-deb --field "$runtime" Architecture)" = \
	"$(dpkg-deb --field "$development" Architecture)" \
	|| fail 'runtime and development package architectures match'

upstream_version=${runtime_version#*:}
upstream_version=${upstream_version%%-*}
source_archive="$build_dir/meson-dist/xmms-$upstream_version.tar.gz"
test -f "$source_archive" \
	|| fail "finds the Meson source archive for $upstream_version"

"$repo_root/tests/verify-debian-package-contract.sh" "$artifact_dir"

stage_dir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-release-artifacts.XXXXXX")
trap 'rm -rf "$stage_dir"' EXIT HUP INT TERM
install_root=$stage_dir/install
target_dir=$stage_dir/target
release_dir=$stage_dir/release-assets
mkdir -p "$install_root" "$target_dir" "$release_dir"
dpkg-deb -x "$runtime" "$install_root"
dpkg-deb -x "$development" "$install_root"

library_dir=$(find "$install_root/usr/lib" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$library_dir" || fail 'extracts the runtime library directory'
test "$(LD_LIBRARY_PATH="$library_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
	"$install_root/usr/bin/xmms" --version)" = "xmms $upstream_version" \
	|| fail 'smoke-tests the extracted xmms binary'

cp "$runtime" "$development" "$source_archive" "$target_dir/"
{
	printf 'XMMS version: %s\n' "$upstream_version"
	printf 'Package version: %s\n' "$runtime_version"
	printf 'Package architecture: %s\n\n' \
		"$(dpkg-deb --field "$runtime" Architecture)"
	for package in "$runtime" "$development"; do
		printf '[%s]\n' "$(basename "$package")"
		dpkg-deb --field "$package" Package Version Architecture Depends Recommends
		printf '\n'
	done
} > "$target_dir/PACKAGE-METADATA.txt"

(
	cd "$target_dir"
	sha256sum ./*.deb > PACKAGES-SHA256SUMS
	sha256sum --check PACKAGES-SHA256SUMS
	sha256sum ./*.deb ./*.tar.gz PACKAGE-METADATA.txt > SHA256SUMS
	sha256sum --check SHA256SUMS
)

cp "$target_dir"/*.deb "$target_dir"/*.tar.gz "$release_dir/"
cp "$target_dir/PACKAGE-METADATA.txt" \
	"$release_dir/PACKAGE-METADATA-local.txt"
cp "$target_dir/PACKAGES-SHA256SUMS" \
	"$release_dir/PACKAGES-SHA256SUMS-local"
{
	printf 'XMMS version: %s\n' "$upstream_version"
	printf 'Artifact source: %s\n' "$artifact_dir"
	printf 'Verification target: local\n'
} > "$release_dir/RELEASE-METADATA.txt"

(
	cd "$release_dir"
	LC_ALL=C sha256sum \
		./*.deb \
		./*.tar.gz \
		PACKAGE-METADATA-local.txt \
		PACKAGES-SHA256SUMS-local \
		RELEASE-METADATA.txt > SHA256SUMS
	sha256sum --check SHA256SUMS
)

echo 'ok - Meson release artifacts preserve package, smoke, and checksum contracts'
