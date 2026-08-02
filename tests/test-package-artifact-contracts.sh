#!/bin/sh
set -eu

repo_root=${1:?usage: $0 REPOSITORY_ROOT VERIFIER}
verifier=${2:?usage: $0 REPOSITORY_ROOT VERIFIER}
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-package-artifacts.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

for command in ar cc dpkg-deb mktemp tar; do
	command -v "$command" >/dev/null 2>&1 || fail "requires $command"
done

write_control()
{
	root=$1
	package=$2
	cat > "$root/DEBIAN/control" <<EOF
Package: $package
Version: 1:0.0.1-1
Architecture: amd64
Maintainer: XMMS test fixture <tests@example.invalid>
Description: deterministic package-verifier fixture
EOF
}

build_fixture()
{
	fixture=$1
	soname=$2
	runtime_root=$fixture/runtime
	devel_root=$fixture/devel
	artifact_dir=$fixture/artifacts
	build_dir=$fixture/build

	mkdir -p \
		"$runtime_root/DEBIAN" \
		"$runtime_root/usr/bin" \
		"$runtime_root/usr/lib/x86_64-linux-gnu/xmms/Input" \
		"$runtime_root/usr/share/applications" \
		"$runtime_root/usr/share/icons/hicolor/16x16/apps" \
		"$runtime_root/usr/share/man/man1" \
		"$runtime_root/usr/share/xmms" \
		"$devel_root/DEBIAN" \
		"$devel_root/usr/bin" \
		"$devel_root/usr/include/xmms" \
		"$devel_root/usr/lib/x86_64-linux-gnu" \
		"$devel_root/usr/share/aclocal" \
		"$artifact_dir" \
		"$build_dir/meson-dist" \
		"$fixture/source/xmms-0.0.1"
	write_control "$runtime_root" xmms
	write_control "$devel_root" libxmms-dev

	cat > "$runtime_root/usr/bin/xmms" <<'EOF'
#!/bin/sh
if test "${1:-}" = --version; then
	printf '%s\n' 'xmms 0.0.1'
fi
EOF
	chmod 755 "$runtime_root/usr/bin/xmms"
	printf '%s\n' '#!/bin/sh' > "$runtime_root/usr/bin/wmxmms"
	chmod 755 "$runtime_root/usr/bin/wmxmms"
	printf '%s\n' 'int fixture_library(void) { return 0; }' \
		| cc -shared -fPIC -x c - -Wl,-soname,"$soname" \
			-o "$runtime_root/usr/lib/x86_64-linux-gnu/libxmms.so.1"
	printf '%s\n' 'fixture MP3 plugin' \
		> "$runtime_root/usr/lib/x86_64-linux-gnu/xmms/Input/libmpg123.so"
	printf '%s\n' '[Desktop Entry]' > "$runtime_root/usr/share/applications/xmms.desktop"
	printf '%s\n' 'fixture icon' \
		> "$runtime_root/usr/share/icons/hicolor/16x16/apps/xmms.xpm"
	printf '%s\n' 'fixture manual' > "$runtime_root/usr/share/man/man1/xmms.1.gz"
	printf '%s\n' 'fixture manual' > "$runtime_root/usr/share/man/man1/wmxmms.1.gz"
	printf '%s\n' 'fixture Window Maker icon' > "$runtime_root/usr/share/xmms/wmxmms.xpm"

	printf '%s\n' '#!/bin/sh' > "$devel_root/usr/bin/xmms-config"
	chmod 755 "$devel_root/usr/bin/xmms-config"
	printf '%s\n' 'fixture plugin API' > "$devel_root/usr/include/xmms/plugin.h"
	printf '%s\n' 'int fixture_archive(void) { return 0; }' \
		| cc -c -x c - -o "$fixture/fixture.o"
	ar rcs "$devel_root/usr/lib/x86_64-linux-gnu/libxmms.a" "$fixture/fixture.o"
	ln -s libxmms.so.1 "$devel_root/usr/lib/x86_64-linux-gnu/libxmms.so"
	printf '%s\n' 'fixture macro' > "$devel_root/usr/share/aclocal/xmms.m4"

	dpkg-deb --root-owner-group --build \
		"$runtime_root" "$artifact_dir/xmms_0.0.1-1_amd64.deb" >/dev/null
	dpkg-deb --root-owner-group --build \
		"$devel_root" "$artifact_dir/libxmms-dev_0.0.1-1_amd64.deb" >/dev/null
	printf '%s\n' 'deterministic Meson source fixture' \
		> "$fixture/source/xmms-0.0.1/README"
tar -C "$fixture/source" -czf "$build_dir/meson-dist/xmms-0.0.1.tar.gz" xmms-0.0.1
}

run_verifier()
{
	fixture=$1
	MESON_BUILD_DIR="$fixture/build" "$verifier" "$fixture/artifacts"
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

valid_fixture=$tmpdir/valid
build_fixture "$valid_fixture" libxmms.so.1
run_verifier "$valid_fixture"
echo 'ok - verifies deterministic package artifacts'

missing_artifacts=$tmpdir/missing
expect_failure 'rejects a missing package artifact directory' \
	"$verifier" "$missing_artifacts"

wrong_soname_fixture=$tmpdir/wrong-soname
build_fixture "$wrong_soname_fixture" libxmms.so.9
expect_failure 'rejects a runtime library with an incorrect ELF SONAME' \
	sh -c 'MESON_BUILD_DIR="$1/build" "$2" "$1/artifacts"' \
	sh "$wrong_soname_fixture" "$verifier"
