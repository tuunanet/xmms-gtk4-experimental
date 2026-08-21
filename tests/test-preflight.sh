#!/bin/sh
set -eu

repo_root=${1:?usage: $0 REPO_ROOT}
preflight="$repo_root/tools/preflight.sh"
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/xmms-preflight-test.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

[ -x "$preflight" ] || fail "provides the canonical preflight command"
grep -F -- '--strict' "$preflight" >/dev/null \
	|| fail "accepts the strict preflight contract"

grep -F 'meson setup' "$preflight" >/dev/null \
	|| fail "configures an isolated Meson build"
grep -F 'meson compile' "$preflight" >/dev/null \
	|| fail "compiles through Meson"
grep -F 'meson test' "$preflight" >/dev/null \
	|| fail "runs the Meson test suite"
grep -F 'tools/run-c-lint.sh' "$preflight" >/dev/null \
	|| fail "runs the maintained C lint gate"
grep -F 'tools/package-deb.sh' "$preflight" >/dev/null \
	|| fail "runs the Debian package gate"
grep -F 'meson dist' "$preflight" >/dev/null \
	|| fail "runs the Meson distribution gate"
grep -F -- '--allow-dirty' "$preflight" >/dev/null \
	|| fail "verifies source distribution from the current worktree"
grep -F 'DEB_SOURCE_ARCHIVE=' "$preflight" >/dev/null \
	|| fail "uses the verified source archive for package builds"
grep -F 'source archive preflight requires DEB_SOURCE_ARCHIVE' "$preflight" >/dev/null \
	|| fail "explains the required source archive outside a Git checkout"
grep -F 'DEB_OUTPUT_DIR=' "$preflight" >/dev/null \
	|| fail "uses one configured package output directory for build and verification"
if grep -E '(pip|curl|wget|wrapdb|subprojects download)' "$preflight" >/dev/null; then
	fail "does not bootstrap or download build tools"
fi

echo "ok - preflight exposes the required Meson gates without bootstrapping"

missing_bin="$tmpdir/missing-bin"
mkdir "$missing_bin"
ln -s "$(command -v dirname)" "$missing_bin/dirname"
missing_log="$tmpdir/missing-meson.log"
if PATH="$missing_bin" "$preflight" >"$missing_log" 2>&1; then
	fail "fails when Meson is unavailable"
fi
grep -F "install system package 'meson'" "$missing_log" >/dev/null \
	|| fail "explains the Meson system-package prerequisite"
echo "ok - preflight fails clearly without Meson"

meson_bin="$tmpdir/meson-bin"
mkdir "$meson_bin"
ln -s "$(command -v dirname)" "$meson_bin/dirname"
printf '%s\n' '#!/bin/sh' 'exit 0' > "$meson_bin/meson"
chmod +x "$meson_bin/meson"
missing_log="$tmpdir/missing-ninja.log"
if PATH="$meson_bin" "$preflight" >"$missing_log" 2>&1; then
	fail "fails when Ninja is unavailable"
fi
grep -F "install system package 'ninja-build'" "$missing_log" >/dev/null \
	|| fail "explains the Ninja system-package prerequisite"
echo "ok - preflight fails clearly without Ninja"

if test -e "$repo_root/.git"; then
	git_bin="$tmpdir/git-bin"
	mkdir "$git_bin"
	ln -s "$(command -v dirname)" "$git_bin/dirname"
	for command in meson ninja xvfb-run xauth python3 clang-format; do
		printf '%s\n' '#!/bin/sh' 'exit 0' > "$git_bin/$command"
		chmod +x "$git_bin/$command"
	done
	missing_log="$tmpdir/missing-git.log"
	if PATH="$git_bin" "$preflight" >"$missing_log" 2>&1; then
		fail "fails when Git is unavailable from a Git checkout"
	fi
	grep -F "install system package 'git'" "$missing_log" >/dev/null \
		|| fail "explains the Git system-package prerequisite"
	echo "ok - preflight fails clearly without Git from a Git checkout"
fi

xvfb_bin="$tmpdir/xvfb-bin"
mkdir "$xvfb_bin"
ln -s "$(command -v dirname)" "$xvfb_bin/dirname"
for command in meson ninja clang-format; do
	printf '%s\n' '#!/bin/sh' 'exit 0' > "$xvfb_bin/$command"
	chmod +x "$xvfb_bin/$command"
done
missing_log="$tmpdir/missing-xvfb.log"
if PATH="$xvfb_bin" "$preflight" >"$missing_log" 2>&1; then
	fail "fails when Xvfb is unavailable"
fi
grep -F "install system package 'xvfb'" "$missing_log" >/dev/null \
	|| fail "explains the Xvfb system-package prerequisite"
echo "ok - preflight fails clearly without Xvfb"

xauth_bin="$tmpdir/xauth-bin"
mkdir "$xauth_bin"
ln -s "$(command -v dirname)" "$xauth_bin/dirname"
for command in meson ninja xvfb-run clang-format; do
	printf '%s\n' '#!/bin/sh' 'exit 0' > "$xauth_bin/$command"
	chmod +x "$xauth_bin/$command"
done
missing_log="$tmpdir/missing-xauth.log"
if PATH="$xauth_bin" "$preflight" >"$missing_log" 2>&1; then
	fail "fails when xauth is unavailable"
fi
grep -F "install system package 'xauth'" "$missing_log" >/dev/null \
	|| fail "explains the xauth system-package prerequisite"
echo "ok - preflight fails clearly without xauth"

python_bin="$tmpdir/python-bin"
mkdir "$python_bin"
ln -s "$(command -v dirname)" "$python_bin/dirname"
for command in meson ninja xvfb-run xauth clang-format; do
	printf '%s\n' '#!/bin/sh' 'exit 0' > "$python_bin/$command"
	chmod +x "$python_bin/$command"
done
missing_log="$tmpdir/missing-python.log"
if PATH="$python_bin" "$preflight" >"$missing_log" 2>&1; then
	fail "fails when Python is unavailable"
fi
grep -F "install system package 'python3'" "$missing_log" >/dev/null \
	|| fail "explains the Python system-package prerequisite"
echo "ok - preflight fails clearly without Python"

grep -F 'require_tool clang-format clang-format' "$preflight" >/dev/null \
	|| fail "checks clang-format before running the build"

clang_format_bin="$tmpdir/missing-clang-format-bin"
mkdir "$clang_format_bin"
ln -s "$(command -v dirname)" "$clang_format_bin/dirname"
for command in meson ninja xvfb-run xauth python3; do
	printf '%s\n' '#!/bin/sh' 'exit 0' > "$clang_format_bin/$command"
	chmod +x "$clang_format_bin/$command"
done
missing_log="$tmpdir/missing-clang-format.log"
if PATH="$clang_format_bin" "$preflight" >"$missing_log" 2>&1; then
	fail "fails when clang-format is unavailable"
fi
grep -F "install system package 'clang-format'" "$missing_log" >/dev/null \
	|| fail "explains the clang-format system-package prerequisite"
echo "ok - preflight fails clearly without clang-format"

clean_environment_verifier="$repo_root/tests/verify-preflight-clean-environment.sh"
[ -x "$clean_environment_verifier" ] \
	|| fail "provides clean-environment preflight verification"
grep -F 'git clone' "$clean_environment_verifier" >/dev/null \
	|| fail "tests preflight from a clean checkout"
grep -F 'DEB_SOURCE_ARCHIVE=' "$clean_environment_verifier" >/dev/null \
	|| fail "tests preflight from an extracted source archive"
grep -F 'tar -x' "$clean_environment_verifier" >/dev/null \
	|| fail "extracts a no-Git source archive for regression coverage"
grep -F 'DEB_OUTPUT_DIR=' "$clean_environment_verifier" >/dev/null \
	|| fail "functionally verifies a custom package output directory"
if grep -E '(pip|curl|wget|wrapdb|subprojects download)' \
	"$clean_environment_verifier" >/dev/null; then
	fail "clean-environment verification does not bootstrap or download tools"
fi
echo "ok - provides no-bootstrap clean-environment verification"
