#!/bin/sh
set -eu

repo_root=${1:?usage: $0 REPOSITORY_ROOT}
verifier=$repo_root/tests/verify-no-autotools-artifacts.sh
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-no-autotools-artifacts.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

expect_rejected()
{
	root=$1
	path=$2
	mode=$3
	entry_type=$4
	log=$tmpdir/rejected.log

	mkdir -p "$root/$(dirname "$path")"
	if test "$entry_type" = symlink; then
		ln -s missing-autotools-artifact "$root/$path"
	else
		: > "$root/$path"
	fi
	if test "$mode" = git; then
		git -C "$root" add -f "$path"
	fi
	if "$verifier" "$root" >"$log" 2>&1; then
		fail "rejects $path from a $mode source tree"
	fi
	grep -Fx "$path" "$log" >/dev/null \
		|| fail "reports $path from a $mode source tree"
	if test "$mode" = git; then
		git -C "$root" reset --quiet HEAD -- "$path"
	fi
	rm -f "$root/$path"
	rmdir "$root/$(dirname "$path")" 2>/dev/null || true
}

expect_registration_symlink_rejected()
{
	root=$1
	mode=$2
	log=$tmpdir/registration-rejected.log
	registration=$root/tests/meson.build
	backup=$root/tests/meson.build.backup
	target=$root/tests/retired-meson.build

	mv "$registration" "$backup"
	printf "%s\n" "test('autotools-meson-dist', find_program('true'))" > "$target"
	ln -s retired-meson.build "$registration"
	if test "$mode" = git; then
		git -C "$root" add -f tests/meson.build tests/retired-meson.build
	fi
	if "$verifier" "$root" >"$log" 2>&1; then
		fail "rejects a symlinked retired test registration from a $mode source tree"
	fi
	grep -Fx 'tests/meson.build' "$log" >/dev/null \
		|| fail "reports a symlinked retired test registration from a $mode source tree"
	if test "$mode" = git; then
		git -C "$root" reset --quiet HEAD -- tests/meson.build tests/retired-meson.build
	fi
	rm -f "$registration" "$target"
	mv "$backup" "$registration"
}

test -x "$verifier" || fail "provides the forbidden-artifact verifier"
if grep -Eq '^/(po/POTFILES|po/remove-potcdate\.sed|xmms/i18n\.h)$|^\.libs/$' \
	"$repo_root/.gitignore"; then
	fail "does not ignore retired Autotools or libtool artifacts"
fi
if test -e "$repo_root/.git"; then
	mkdir "$tmpdir/archive" "$tmpdir/git-source"
	git -C "$repo_root" archive HEAD | tar -x -C "$tmpdir/archive"
	git -C "$repo_root" archive HEAD | tar -x -C "$tmpdir/git-source"
	git -C "$tmpdir/git-source" init --quiet
	git -C "$tmpdir/git-source" config user.email test@example.invalid
	git -C "$tmpdir/git-source" config user.name 'XMMS test'
	git -C "$tmpdir/git-source" add .
	git -C "$tmpdir/git-source" commit --quiet -m baseline
	test ! -e "$tmpdir/archive/.git" || fail "creates an extracted source fixture"
else
	archive_root=$repo_root
fi

for legacy_path in \
	ABOUT-NLS \
	Makefile \
	Makefile.am \
	Makefile.in \
	configure \
	configure.ac \
	configure.in \
	aclocal.m4 \
	acinclude.m4 \
	config.guess \
	config.sub \
	config.h \
	config.h.in \
	config.log \
	config.status \
	config.cache \
	config.rpath \
	depcomp \
	install-sh \
	ltmain.sh \
	libtool \
	missing \
	mkinstalldirs \
	stamp-h1 \
	autom4te.cache/traces.0 \
	.deps/legacy.Po \
	libxmms/libxmms.la \
	libxmms/libxmms.lo \
	libxmms/libxmms.lai \
	libxmms/acinclude.m4 \
	xmms-config.in \
	xmms.m4 \
	xmms/i18n.h \
	xmms/i18n.h.in \
	intl/plural.c \
	po/Makevars \
	po/POTFILES \
	po/POTFILES.in \
	po/Rules-quot \
	po/stamp-po \
	po/boldquot.sed \
	po/ChangeLog \
	po/en@boldquot.header \
	po/en@quot.header \
	po/insert-header.sin \
	po/quot.sed \
	po/remove-potcdate.sed \
	po/remove-potcdate.sin \
	po/xmms.pot \
	tests/test-autotools-meson-dist.sh \
	tests/test-autotools-package-deb.sh \
	tests/test-intl-generated-sources.sh \
	debian/config.h \
	obj-hidden/config.h \
	build-hidden/config.h
do
	if test -e "$repo_root/.git"; then
		expect_rejected "$tmpdir/git-source" "$legacy_path" git file
		expect_rejected "$tmpdir/archive" "$legacy_path" archive file
	fi
done

for legacy_symlink in \
	configure.ac \
	autom4te.cache \
	.deps \
	libxmms/libxmms.la \
	libxmms/libxmms.lo \
	libxmms/libxmms.lai \
	xmms/i18n.h \
	po/POTFILES \
	po/remove-potcdate.sed \
	intl \
	tests/test-autotools-meson-dist.sh \
	tests/test-autotools-package-deb.sh \
	tests/test-intl-generated-sources.sh
do
	if test -e "$repo_root/.git"; then
		expect_rejected "$tmpdir/git-source" "$legacy_symlink" git symlink
		expect_rejected "$tmpdir/archive" "$legacy_symlink" archive symlink
	fi
done

if test -e "$repo_root/.git"; then
	expect_registration_symlink_rejected "$tmpdir/git-source" git
	expect_registration_symlink_rejected "$tmpdir/archive" archive
fi

if test -e "$repo_root/.git"; then
	mkdir -p "$tmpdir/package-source/xmms-0.0.1"
	git -C "$repo_root" archive HEAD | tar -x -C "$tmpdir/package-source/xmms-0.0.1"
	tar -C "$tmpdir/package-source" -czf "$tmpdir/source.tar.gz" xmms-0.0.1
	mkdir "$tmpdir/package-source/xmms-0.0.1/obj-x86_64-linux-gnu"
	: > "$tmpdir/package-source/xmms-0.0.1/obj-x86_64-linux-gnu/config.h"
	if ! DEB_SOURCE_ARCHIVE="$tmpdir/source.tar.gz" \
		"$verifier" "$tmpdir/package-source/xmms-0.0.1"; then
		fail "validates the supplied source archive before package output"
	fi

	mkdir -p "$tmpdir/multi-root-source/000-clean" \
		"$tmpdir/multi-root-source/xmms-0.0.1"
	: > "$tmpdir/multi-root-source/000-clean/README"
	: > "$tmpdir/multi-root-source/xmms-0.0.1/configure.ac"
	tar -C "$tmpdir/multi-root-source" -czf "$tmpdir/multi-root-source.tar.gz" \
		000-clean xmms-0.0.1
	if DEB_SOURCE_ARCHIVE="$tmpdir/multi-root-source.tar.gz" \
		"$verifier" "$repo_root" >"$tmpdir/multi-root-rejected.log" 2>&1; then
		fail "rejects artifacts beneath every source archive root"
	fi
	grep -Fx 'xmms-0.0.1/configure.ac' "$tmpdir/multi-root-rejected.log" >/dev/null \
		|| fail "reports artifacts beneath a non-leading source archive root"
else
	"$verifier" "$repo_root"
fi

echo 'ok - forbidden-artifact verification rejects every legacy source class'
