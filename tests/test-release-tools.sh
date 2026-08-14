#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}
checker="$repo_root/tools/check-release-version.sh"
extractor="$repo_root/tools/extract-release-notes.sh"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

expect_failure()
{
	name=$1
	shift
	if "$@" >/dev/null 2>&1; then
		fail "$name"
	fi
	echo "ok - $name"
}

write_fixture()
{
	root=$1
	version=$2
	mkdir -p "$root"
	cat > "$root/meson.build" <<EOF
project('xmms', 'c', version: '$version')
EOF
	cat > "$root/CHANGELOG.md" <<EOF
# Changelog

## [Unreleased]

## [$version] - 2026-07-26

### Added
- Release automation fixture.

## [1.2.11] - 2007-11-16

Historical entry.
EOF
}

fixture="$tmpdir/valid"
write_fixture "$fixture" 1.3.0

actual=$($checker 1.3.0 "$fixture")
[ "$actual" = 1.3.0 ] || fail "reports the validated version"
echo "ok - validates matching release metadata"

mismatched_meson="$tmpdir/mismatched-meson"
write_fixture "$mismatched_meson" 1.3.0
sed "s/version: '1.3.0'/version: '9.9.9'/" "$mismatched_meson/meson.build" \
	> "$mismatched_meson/meson.build.new"
mv "$mismatched_meson/meson.build.new" "$mismatched_meson/meson.build"
expect_failure "rejects a mismatched Meson project version" \
	"$checker" 1.3.0 "$mismatched_meson"

expect_failure "rejects a mismatched requested version" \
	"$checker" 1.3.1 "$fixture"
expect_failure "rejects a non-SemVer requested version" \
	"$checker" '1.3.0; echo unsafe' "$fixture"

missing="$tmpdir/missing-changelog"
write_fixture "$missing" 1.3.0
sed '/^## \[1.3.0\]/,/^## \[1.2.11\]/d' "$missing/CHANGELOG.md" > "$missing/CHANGELOG.new"
mv "$missing/CHANGELOG.new" "$missing/CHANGELOG.md"
expect_failure "requires a versioned changelog entry" \
	"$checker" 1.3.0 "$missing"

duplicate="$tmpdir/duplicate-changelog"
write_fixture "$duplicate" 1.3.0
cat >> "$duplicate/CHANGELOG.md" <<EOF

## [1.3.0] - 2026-07-27

Duplicate entry.
EOF
expect_failure "rejects duplicate changelog entries" \
	"$checker" 1.3.0 "$duplicate"

notes="$tmpdir/release-notes.md"
$extractor 1.3.0 "$notes" "$fixture/CHANGELOG.md"
grep -Fq '### Added' "$notes" || fail "extracts release section headings"
grep -Fq 'Release automation fixture.' "$notes" || fail "extracts release notes"
if grep -Fq 'Historical entry.' "$notes"; then
	fail "stops notes at the next version"
fi
echo "ok - extracts only the selected changelog section"

empty="$tmpdir/empty-changelog.md"
cat > "$empty" <<EOF
## [1.3.0] - 2026-07-26

## [1.2.11] - 2007-11-16
EOF
expect_failure "rejects empty release notes" \
	"$extractor" 1.3.0 "$tmpdir/empty-notes.md" "$empty"
