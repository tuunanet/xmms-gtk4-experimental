#!/bin/sh
set -eu

srcdir=${1:-.}
srcdir=$(cd "$srcdir" && pwd)
failures=0

ok() { echo "ok - $1"; }
not_ok() { echo "not ok - $1" >&2; failures=$((failures + 1)); }
require_file() {
	if test -f "$srcdir/$1"; then ok "includes $1"; else not_ok "includes $1"; fi
}
require_text() {
	if test -f "$srcdir/$1" && grep -F -- "$2" "$srcdir/$1" >/dev/null; then
		ok "$3"
	else
		not_ok "$3"
	fi
}
require_absent_text() {
	if test -f "$srcdir/$1" && ! grep -F -- "$2" "$srcdir/$1" >/dev/null; then
		ok "$3"
	else
		not_ok "$3"
	fi
}
require_order() {
	first_line=$(grep -n -F -- "$2" "$srcdir/$1" 2>/dev/null |
		head -n 1 | cut -d: -f1 || true)
	second_line=$(grep -n -F -- "$3" "$srcdir/$1" 2>/dev/null |
		head -n 1 | cut -d: -f1 || true)
	if test -n "$first_line" && test -n "$second_line" && \
		test "$first_line" -lt "$second_line"; then
		ok "$4"
	else
		not_ok "$4"
	fi
}

for file in \
	.github/workflows/package-release.yml \
	packaging/debian/control packaging/debian/rules \
	tools/build-deb.sh tools/package-deb.sh \
	tools/preflight.sh tools/verify-release-artifacts.sh \
	tests/test-package-artifact-contracts.sh \
	tests/verify-debian-package-contract.sh \
	tests/verify-no-autotools-artifacts.sh
do
	require_file "$file"
done

require_text .github/workflows/package-release.yml 'workflow_dispatch:' \
	'exposes manual release packaging'
require_text .github/workflows/package-release.yml 'version:' \
	'accepts a requested release version'
require_text .github/workflows/package-release.yml 'refs/tags/v${VERSION}' \
	'guards the matching release tag'
require_text .github/workflows/package-release.yml 'git cat-file -t' \
	'requires an annotated release tag'
require_text .github/workflows/package-release.yml 'target_id: linuxmint' \
	'packages the Linux Mint target'
require_text .github/workflows/package-release.yml 'target_id: ubuntu' \
	'packages the Ubuntu target'
require_text .github/workflows/package-release.yml 'contents: write' \
	'grants release publication permission only to the draft job'
require_text .github/workflows/package-release.yml 'sha256sum --check SHA256SUMS' \
	'verifies release asset checksums'
require_text .github/workflows/package-release.yml 'gh release create' \
	'creates the GitHub release from verified assets'
require_text .github/workflows/package-release.yml '--draft' \
	'creates an unpublished draft release'
require_text .github/workflows/package-release.yml 'meson' \
	'installs Meson for target package builds'
require_text .github/workflows/package-release.yml '            git' \
	'installs Git for target package source checkout'
require_order .github/workflows/package-release.yml \
	'- name: Install package build dependencies' '- name: Check out selected ref' \
	'installs target dependencies before source checkout'
require_text .github/workflows/package-release.yml \
	'git config --global --add safe.directory "${GITHUB_WORKSPACE}"' \
	'trusts only the checked-out workspace for Git source distribution'
require_absent_text .github/workflows/package-release.yml 'safe.directory "*"' \
	'does not trust every repository for Git source distribution'
require_order .github/workflows/package-release.yml \
	'- name: Check out selected ref' '- name: Trust checked-out workspace' \
	'trusts the workspace only after checkout'
require_order .github/workflows/package-release.yml \
	'- name: Trust checked-out workspace' '- name: Build target packages' \
	'trusts the workspace before Meson source distribution'
require_text .github/workflows/package-release.yml 'tools/package-deb.sh' \
	'builds target packages through the Meson package helper'
require_absent_text .github/workflows/package-release.yml './configure --disable-esd' \
	'does not configure target packages through Autotools'
require_absent_text .github/workflows/package-release.yml 'make dist-gzip' \
	'does not create target source archives through Autotools'
require_absent_text .github/workflows/package-release.yml 'configure.in' \
	'does not describe a removed configure source as a version authority'

require_text packaging/debian/rules '--buildsystem=meson' \
	'uses the Meson debhelper backend'
require_text packaging/debian/rules '--wrap-mode=nodownload' \
	'prevents the inner Debian Meson configure from downloading wraps'
require_absent_text packaging/debian/rules 'dh_autoreconf' \
	'does not retain an Autotools regeneration override'
require_absent_text packaging/debian/control 'Autoconf' \
	'does not promise a removed plugin build macro'

require_text tools/package-deb.sh 'for command in meson ninja python3 xvfb-run; do' \
	'requires Xvfb for headless source-distribution tests'
require_text tools/package-deb.sh 'xvfb-run --auto-servernum meson dist' \
	'creates source archives through Meson in an Xvfb session'
require_text tools/package-deb.sh 'DEB_SOURCE_ARCHIVE' \
	'accepts an explicit Meson source archive outside Git'
require_text tools/package-deb.sh 'requires DEB_SOURCE_ARCHIVE outside a Git checkout' \
	'fails clearly when extracted source lacks its supplied archive'
require_absent_text tools/package-deb.sh 'make dist-gzip' \
	'does not fall back to retained source distribution'
require_absent_text tools/package-deb.sh './configure before make deb' \
	'does not direct callers to removed Autotools commands'
require_text tools/package-deb.sh '--wrap-mode=nodownload' \
	'prevents package builds from downloading dependencies'
require_text tools/build-deb.sh 'lintian --fail-on error' \
	'runs Debian package policy checks'
require_text tools/build-deb.sh 'DEB_SOURCE_ARCHIVE="$source_archive" dpkg-buildpackage' \
	'validates package tests against the supplied Meson source archive'

for package in ' clang-format,' ' cppcheck,' ' git,' ' lintian,' ' meson (>= 1.3.2),' ' ninja-build,' ' xauth,'; do
	require_text packaging/debian/control "$package" \
		"declares ${package# } for package verification"
done

require_text tools/verify-release-artifacts.sh 'dpkg-deb -x' \
	'extracts release packages without installing them'
require_absent_text tools/verify-release-artifacts.sh 'sudo' \
	'never elevates release verification privileges'

if test "$failures" -ne 0; then
	echo "$failures package recipe checks failed" >&2
	exit 1
fi
