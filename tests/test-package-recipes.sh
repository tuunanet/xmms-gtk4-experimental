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
	tests/test-c-lint.sh \
	tools/cppcheck-suppressions.txt \
	tools/run-c-lint.sh \
	packaging/xmms.desktop \
	packaging/debian/control \
	packaging/debian/copyright \
	packaging/debian/libxmms-dev.install \
	packaging/debian/rules \
	packaging/debian/source/format \
	packaging/debian/xmms.install \
	tools/build-deb.sh
do
	require_file "$file"
done

require_text Makefile.am 'deb:' \
	'exposes a top-level make deb target'
require_text Makefile.am '$(MAKE) dist-gzip' \
	'creates a source archive for local Debian builds'
require_text Makefile.am '.PHONY: deb lint' \
	'exposes lint as a phony top-level target'
require_text Makefile.am 'lint:' \
	'exposes the public C lint target'
require_text Makefile.am 'tools/run-c-lint.sh' \
	'runs C lint through the shared helper'
require_text Makefile.in 'lint:' \
	'ships the generated C lint target'
require_text tests/Makefile 'test-c-lint:' \
	'runs C lint contract tests from make check'
require_text Makefile.am 'tools/cppcheck-suppressions.txt' \
	'distributes the C lint baseline'
require_text Makefile.am 'docs/architecture/build-and-test.md' \
	'distributes the C lint architecture guide'
require_text Makefile.am 'tools/build-deb.sh' \
	'builds Debian packages through the shared helper'
require_text .github/workflows/ci.yml 'cppcheck \' \
	'installs the supported C analyzer in full CI'
require_text .github/workflows/ci.yml 'name: Lint C sources' \
	'runs C lint as a named CI step'
require_text .github/workflows/ci.yml 'timeout-minutes: 5' \
	'bounds the C lint CI step'
require_text .github/workflows/ci.yml 'run: make lint' \
	'reuses the public C lint target in CI'
require_absent_text .github/workflows/ci.yml "- '!tools/**'" \
	'keeps lint control tools build-affecting'
require_absent_text .github/workflows/ci.yml "- '!tests/**'" \
	'keeps lint contract tests build-affecting'
require_text CONTRIBUTING.md 'make lint' \
	'documents the local C lint command'
require_text CONTRIBUTING.md 'suppression baseline' \
	'documents controlled lint baseline maintenance'
require_text docs/architecture/build-and-test.md 'Cppcheck' \
	'documents the C lint architecture'
require_text docs/architecture/build-and-test.md 'tools/cppcheck-suppressions.txt' \
	'documents the lint baseline path'
require_text .github/workflows/ci.yml 'make deb' \
	'builds Debian packages before release candidates'
require_text .github/workflows/release-candidate.yml 'make deb' \
	'builds candidate Debian packages through the public target'
require_text .github/workflows/release-candidate.yml \
	'sha256sum "$archive" *.deb' \
	'includes Debian packages in candidate checksums'
require_text .github/workflows/release-candidate.yml \
	'sudo apt-get install -y "$runtime" "$devel"' \
	'installs candidate Debian packages before upload'
require_text .github/workflows/package-release.yml 'make deb' \
	'reuses the public target for final Debian packages'
require_text .github/workflows/package-release.yml 'workflow_dispatch:' \
	'requires manual package publication'
require_text .github/workflows/package-release.yml 'runs-on: ubuntu-24.04' \
	'builds DEBs on the declared Ubuntu target'
require_absent_text .github/workflows/package-release.yml 'container: fedora:42' \
	'does not build RPM packages'
require_absent_text .github/workflows/package-release.yml 'build-rpm' \
	'does not define an RPM package job'
require_text .github/workflows/package-release.yml 'runtime=$(realpath' \
	'installs Debian artifacts by explicit local paths'
require_text .github/workflows/package-release.yml \
	'rm -rf "$source_dir/packaging"' \
	'replaces bundled recipes without nesting directories'
require_text .github/workflows/package-release.yml \
	'must be an unpublished draft release' \
	'requires packages to be attached before publication'
require_text .github/workflows/package-release.yml \
	'Draft releases and their assets are only visible to tokens with write' \
	'grants draft validation the permission needed to read unpublished assets'
require_text .github/workflows/package-release.yml \
	'Refusing to replace existing release asset' \
	'protects draft package assets from replacement'
require_text .github/workflows/package-release.yml "tr '~' '.'" \
	'uses GitHub-safe Debian asset names'
require_text .github/workflows/package-release.yml \
	'/usr/lib/x86_64-linux-gnu/xmms/Input/libmpg123.so' \
	'checks installed Debian MP3 plugin linkage'
require_text .github/workflows/package-release.yml \
	"grep 'undefined symbol: .*_ZGV'" \
	'rejects unresolved vector math symbols in packaged MP3 plugins'
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
require_text tools/build-deb.sh 'dpkg-buildpackage --build=binary --no-sign' \
	'builds unsigned binary Debian packages'
require_text tools/build-deb.sh "grep 'undefined symbol: .*_ZGV'" \
	'checks packaged MP3 plugin vector math linkage'
require_text tools/build-deb.sh 'lintian --fail-on error' \
	'runs Debian package policy checks from make deb'
require_absent_text tools/build-deb.sh 'sudo' \
	'never elevates privileges from make deb'
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
require_text packaging/debian/rules '-Wno-error=incompatible-pointer-types' \
	'permits legacy GTK callbacks with newer Ubuntu GCC'
require_text packaging/debian/rules 'DEB_BUILD_OPTIONS' \
	'honors Debian package test controls'
require_text packaging/debian/rules '--disable-esd' \
	'disables the obsolete ESD plugin in Debian builds'
require_absent_text Makefile.am 'xmms.spec' \
	'does not ship legacy RPM package metadata'
require_absent_text Makefile.am 'packaging/rpm' \
	'does not ship modern RPM package recipes'

if test "$failures" -ne 0; then
	echo "$failures package recipe checks failed" >&2
	exit 1
fi
