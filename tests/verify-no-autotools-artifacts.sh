#!/bin/sh
set -eu

repo_root=${1:?usage: verify-no-autotools-artifacts.sh REPOSITORY_ROOT}
scan_root=$repo_root
tmpdir=

cleanup()
{
	test -z "$tmpdir" || rm -rf "$tmpdir"
}
trap cleanup EXIT HUP INT TERM

if test -n "${DEB_SOURCE_ARCHIVE:-}"; then
	test -f "$DEB_SOURCE_ARCHIVE" || {
		echo "error: requested source archive not found: $DEB_SOURCE_ARCHIVE" >&2
		exit 2
	}
	tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-no-autotools-source.XXXXXX")
	tar -xf "$DEB_SOURCE_ARCHIVE" -C "$tmpdir"
	scan_root=$tmpdir
	tracked_files=$(cd "$scan_root" && find . \( -type f -o -type l \) -printf '%P\n')
elif test -e "$repo_root/.git"; then
	tracked_files=$(git -C "$repo_root" ls-files)
else
	tracked_files=$(cd "$repo_root" && find . \( -type f -o -type l \) -printf '%P\n')
fi

forbidden=$(printf '%s\n' "$tracked_files" | grep -E '(^|/)(ABOUT-NLS|Makefile(\..*)?|configure(\.(ac|in))?|aclocal\.m4|acinclude\.m4|config\.(guess|sub|h(\.in)?|log|status|cache|rpath)|depcomp|install-sh|ltmain\.sh|libtool|missing|mkinstalldirs|stamp-h[0-9]*|i18n\.h(\.in)?)$|(^|/)(autom4te\.cache|\.deps)(/|$)|\.(la|lo|lai)$' || true)
legacy_contracts=$(printf '%s\n' "$tracked_files" | grep -E '(^|/)tests/test-(autotools-(meson-dist|package-deb)|intl-generated-sources)\.sh$' || true)
legacy_registrations=$(find "$scan_root" -path '*/tests/meson.build' \( -type f -o -type l \) \
	-exec grep -lE "test\('(autotools-(meson-dist|package-deb)|intl-generated-sources)'" {} \; \
	| sed "s|^$scan_root/||")
if [ -n "$legacy_registrations" ]; then
	legacy_contracts="${legacy_contracts}
${legacy_registrations}"
fi
retired_support=$(printf '%s\n' "$tracked_files" | grep -E '(^|/)(config\.rpath|libxmms/acinclude\.m4|xmms-config\.in|xmms\.m4|intl(/|$)|po/(ChangeLog|Makevars|POTFILES(\.in)?|Rules-quot|stamp-po|boldquot\.sed|en@boldquot\.header|en@quot\.header|insert-header\.sin|quot\.sed|remove-potcdate\.(sed|sin)|xmms\.pot))' || true)
for retired in "$legacy_contracts" "$retired_support"; do
	if [ -n "$forbidden" ] && [ -n "$retired" ]; then
		forbidden="${forbidden}
${retired}"
	elif [ -n "$retired" ]; then
		forbidden=$retired
	fi
done

if [ -n "$forbidden" ]; then
	echo 'not ok - tracked Autotools artifacts are absent' >&2
	printf '%s\n' "$forbidden" >&2
	exit 1
fi

echo 'ok - tracked Autotools artifacts are absent'
