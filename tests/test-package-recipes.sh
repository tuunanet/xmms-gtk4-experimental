#!/bin/sh
set -eu

srcdir=${1:-.}
failures=0

ok()
{
	echo "ok - $1"
}

not_ok()
{
	echo "not ok - $1" >&2
	failures=$((failures + 1))
}

require_file()
{
	if test -f "$srcdir/$1"; then
		ok "includes $1"
	else
		not_ok "includes $1"
	fi
}

require_text()
{
	file=$1
	text=$2
	description=$3
	if test -f "$srcdir/$file" && grep -F -- "$text" "$srcdir/$file" >/dev/null; then
		ok "$description"
	else
		not_ok "$description"
	fi
}

require_absent_text()
{
	file=$1
	text=$2
	description=$3
	if test -f "$srcdir/$file" && ! grep -F -- "$text" "$srcdir/$file" >/dev/null; then
		ok "$description"
	else
		not_ok "$description"
	fi
}

for file in \
	.github/workflows/package-release.yml \
	packaging/xmms.desktop \
	packaging/debian/control \
	packaging/debian/copyright \
	packaging/debian/libxmms-dev.install \
	packaging/debian/rules \
	packaging/debian/source/format \
	packaging/debian/xmms.install \
	packaging/rpm/xmms.spec.in
do
	require_file "$file"
done

require_text .github/workflows/package-release.yml 'workflow_dispatch:' \
	'requires manual package publication'
require_text .github/workflows/package-release.yml 'container: fedora:42' \
	'builds RPMs in the declared Fedora target'
require_text .github/workflows/package-release.yml 'runs-on: ubuntu-24.04' \
	'builds DEBs on the declared Ubuntu target'
require_text .github/workflows/package-release.yml 'runtime=$(realpath' \
	'installs Debian artifacts by explicit local paths'
require_text .github/workflows/package-release.yml \
	'rm -rf "$source_dir/packaging" "$source_dir/debian"' \
	'replaces bundled recipes without nesting directories'
require_text .github/workflows/package-release.yml \
	'must be an unpublished draft release' \
	'requires packages to be attached before publication'
require_text .github/workflows/package-release.yml \
	'Refusing to replace existing release asset' \
	'protects draft package assets from replacement'
require_text .github/workflows/package-release.yml "tr '~' '.'" \
	'uses GitHub-safe Debian asset names'
require_absent_text .github/workflows/package-release.yml \
	'must be a published stable release' \
	'does not require an already immutable release'
require_absent_text .github/workflows/package-release.yml '--clobber' \
	'never clobbers release package assets'
require_text packaging/xmms.desktop 'Name=XMMS Classic' \
	'uses current branding in the desktop entry'
require_text packaging/xmms.desktop 'Exec=xmms %U' \
	'preserves the xmms executable name'
require_absent_text packaging/xmms.desktop 'Encoding=' \
	'does not use the obsolete desktop Encoding key'
require_text packaging/debian/control 'Package: xmms' \
	'defines the Debian runtime package'
require_text packaging/debian/control 'Package: libxmms-dev' \
	'defines the Debian development package'
require_text packaging/debian/rules './configure' \
	'configures the Debian build explicitly'
require_text packaging/debian/rules 'override_dh_autoreconf:' \
	'preserves the shipped legacy Autotools files'
require_text packaging/debian/rules 'optimize=-lto' \
	'disables LTO for the legacy bundled libtool'
require_text packaging/debian/rules 'DEB_BUILD_OPTIONS' \
	'honors Debian package test controls'
require_text packaging/debian/rules '--disable-esd' \
	'disables the obsolete ESD plugin in Debian builds'
require_text packaging/rpm/xmms.spec.in 'Name:           xmms' \
	'preserves the RPM package name'
require_text packaging/rpm/xmms.spec.in 'Version:        @VERSION@' \
	'requires an explicit RPM release version'
require_text packaging/rpm/xmms.spec.in '%global _lto_cflags %{nil}' \
	'disables LTO for the legacy bundled libtool in RPM builds'
require_text packaging/rpm/xmms.spec.in \
	'-Wno-error=incompatible-pointer-types' \
	'permits known GTK callback conversions with Fedora GCC'
require_text packaging/rpm/xmms.spec.in 'chrpath --delete' \
	'removes redundant standard-library runpaths from RPM binaries'
require_text packaging/rpm/xmms.spec.in '%check' \
	'runs package-level RPM checks'
require_text packaging/rpm/xmms.spec.in '%package devel' \
	'defines the RPM development package'
require_absent_text packaging/rpm/xmms.spec.in '%{_libdir}/xmms/**/*.la' \
	'does not package libtool archives'

if test "$failures" -ne 0; then
	echo "$failures package recipe checks failed" >&2
	exit 1
fi
