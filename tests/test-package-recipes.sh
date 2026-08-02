#!/bin/sh
set -eu

srcdir=${1:-.}
srcdir=$(cd "$srcdir" && pwd)
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
	CLAUDE.md \
	CONVENTIONS.md \
	scripts/land-branch.sh \
	scripts/lib/land-branch-push.sh \
	specs/WORKFLOW-solo-git.md \
	specs/workflows/solo-git.yaml \
	tests/test-c-lint.sh \
	tests/test-solo-git-workflow.sh \
	tests/test-gtk3-play-button-proof.c \
	tests/test-pbutton-baseline.c \
	tests/test-ui-control.c \
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

require_text .github/workflows/package-release.yml 'workflow_dispatch:' \
	'exposes a manual release-package dispatch'
require_text .github/workflows/package-release.yml 'version:' \
	'requires a release version input'
require_text .github/workflows/package-release.yml 'refs/tags/v${VERSION}' \
	'guards the matching release tag'
require_text .github/workflows/package-release.yml 'git cat-file -t' \
	'requires an annotated release tag'
require_text .github/workflows/package-release.yml 'target_id: linuxmint' \
	'packages the Linux Mint target'
require_text .github/workflows/package-release.yml 'target_id: ubuntu' \
	'packages the Ubuntu target'
require_text .github/workflows/package-release.yml 'libgtk-3-dev' \
	'installs the GTK3 proof dependency'
require_text .github/workflows/package-release.yml 'contents: write' \
	'limits release mutation to an explicit write permission'
require_text .github/workflows/package-release.yml 'sha256sum --check SHA256SUMS' \
	'verifies release asset checksums'
require_text .github/workflows/package-release.yml 'gh release create' \
	'creates a GitHub release through the CLI'
require_text .github/workflows/package-release.yml '--draft' \
	'creates an unpublished draft release'
require_text .github/workflows/package-release.yml 'XMMS GTK4 Experimental' \
	'uses fork branding in release metadata'
require_absent_text .github/workflows/package-release.yml 'XMMS GTK2' \
	'does not use the donor project branding'
require_text docs/releases.md 'package-release.yml' \
	'documents the generic release-package workflow'
require_text docs/releases.md 'Linux Mint 22.3' \
	'documents the Linux Mint release target'
require_text docs/releases.md 'Ubuntu 26.04' \
	'documents the Ubuntu release target'
require_text docs/releases.md 'annotated `vVERSION` tag' \
	'documents matching annotated-tag dispatch'
require_text docs/architecture/build-and-test.md 'package-release.yml' \
	'documents the checked-in release workflow'
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
require_text tests/Makefile 'test-pbutton-baseline:' \
	'runs Play-button migration baselines from make check'
require_text Makefile.am 'tests/test-pbutton-baseline.c' \
	'distributes the Play-button migration baseline'
require_text tests/Makefile 'test-ui-control:' \
	'runs the toolkit-neutral control tests from make check'
require_text Makefile.am 'tests/test-ui-control.c' \
	'distributes the toolkit-neutral control tests'
require_text tests/Makefile 'test-gtk3-play-button-proof:' \
	'runs the isolated GTK3 Play-button proof from make check'
require_text Makefile.am 'tests/test-gtk3-play-button-proof.c' \
	'distributes the isolated GTK3 Play-button proof'
require_text Makefile.am '.github/workflows/package-release.yml' \
	'distributes the generic release-package workflow'
require_text Makefile.in '.github/workflows/package-release.yml' \
	'ships the generic release-package workflow manifest entry'
require_text specs/state.yaml 'workflow_mode: solo-git' \
	'enables solo Git integration in lifecycle state'
require_text CLAUDE.md 'release-branch` in `solo-local` mode' \
	'documents solo-local integration for agents'
require_text CONVENTIONS.md 'NEVER commit directly on `main` outside `land-branch.sh`' \
	'protects main from direct task commits'
require_text CONTRIBUTING.md 'Maintainers use the [Solo Git workflow]' \
	'documents solo-local integration for maintainers'
require_text docs/releases.md 'use `release-branch` in' \
	'lands release preparation through the selected integration mode'
require_text Makefile.am 'scripts/land-branch.sh' \
	'distributes the solo-local land command'
require_text Makefile.in 'scripts/land-branch.sh' \
	'ships the solo-local land command manifest entry'
require_text Makefile.am 'specs/workflows/solo-git.yaml' \
	'distributes the solo Git workflow recipe'
require_text Makefile.am 'tests/test-solo-git-workflow.sh' \
	'distributes the Solo Git workflow contract test'
require_text Makefile.in 'tests/test-solo-git-workflow.sh' \
	'ships the Solo Git workflow contract test manifest entry'
require_text Makefile.in 'tests/meson.build' \
	'ships the Meson test registry in the Autotools source archive'
require_text tests/Makefile 'test-solo-git-workflow' \
	'runs the Solo Git workflow contract from make check'
require_text tests/meson.build "test('solo-git-workflow'" \
	'runs the Solo Git workflow contract from Meson'
require_text configure.in '--disable-gtk3-proof' \
	'exposes an explicit GTK3 proof configure policy'
require_text configure.in 'gtk+-3.0 >= 3.24' \
	'detects the supported GTK3 bridge version'
require_text packaging/debian/control 'libgtk-3-dev' \
	'declares the GTK3 proof build dependency'
require_text docs/architecture/ui-interaction.md 'GTK2 → GTK3 → GTK4' \
	'documents the staged toolkit migration'
require_text docs/architecture/plugin-system.md 'GTK-major linkage' \
	'documents plugin toolkit compatibility'
require_text docs/architecture/build-and-test.md 'test-gtk3-play-button-proof' \
	'documents the isolated GTK3 proof gate'
require_text Makefile.am 'docs/architecture/ui-interaction.md' \
	'distributes the staged UI migration architecture'
require_text Makefile.am 'docs/architecture/plugin-system.md' \
	'distributes the plugin toolkit compatibility policy'
require_text Makefile.am 'specs/adr/ADR-0001-staged-gtk-migration.md' \
	'distributes the staged GTK migration decision'
require_text Makefile.am 'tools/cppcheck-suppressions.txt' \
	'distributes the C lint baseline'
require_text Makefile.am 'docs/architecture/build-and-test.md' \
	'distributes the C lint architecture guide'
require_text Makefile.am 'tools/build-deb.sh' \
	'builds Debian packages through the shared helper'
require_text packaging/debian/control ' cppcheck,' \
	'declares the C analyzer as a Debian build dependency'
require_text CONTRIBUTING.md 'make lint' \
	'documents the local C lint command'
require_text CONTRIBUTING.md 'suppression baseline' \
	'documents controlled lint baseline maintenance'
require_text docs/architecture/build-and-test.md 'Cppcheck' \
	'documents the C lint architecture'
require_text docs/architecture/build-and-test.md 'tools/cppcheck-suppressions.txt' \
	'documents the lint baseline path'
require_text packaging/xmms.desktop 'Name=XMMS GTK4 Experimental' \
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
