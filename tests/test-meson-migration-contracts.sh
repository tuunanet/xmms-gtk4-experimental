#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

lifecycle_checker="$repo_root/tools/validate-lifecycle-state.py"
[ -x "$lifecycle_checker" ] || fail "provides lifecycle validation for the completed release dispatch"
"$lifecycle_checker" \
	"$repo_root/specs/state.yaml" \
	"$repo_root/specs/execution-status.yaml" \
	"$repo_root/specs/release-plan.yaml"
echo "ok - records the completed v0.0.1 draft pre-release"

baseline_checker="$repo_root/tools/verify-build-baseline.sh"
[ -x "$baseline_checker" ] || fail "provides a legacy build baseline verifier"
"$baseline_checker" "$repo_root"
test -f "$repo_root/specs/adr/ADR-0002-meson-tooling-migration.md" \
	|| fail "records the Meson migration decision"
echo "ok - freezes the legacy build and delivery contract"

policy_checker="$repo_root/tools/verify-meson-toolchain-policy.sh"
[ -x "$policy_checker" ] || fail "provides a Meson system-tool policy verifier"
"$policy_checker"

policy_tmpdir=$(mktemp -d)
trap 'rm -rf "$policy_tmpdir"' EXIT HUP INT TERM
mkdir -p "$policy_tmpdir/bin"
printf '%s\n' '#!/bin/sh' 'echo 1.3.2' > "$policy_tmpdir/bin/meson"
printf '%s\n' '#!/bin/sh' 'echo 1.6' > "$policy_tmpdir/bin/ninja"
chmod +x "$policy_tmpdir/bin/meson" "$policy_tmpdir/bin/ninja"
PATH="$policy_tmpdir/bin:/usr/bin:/bin" "$policy_checker" --check-tools
if PATH="/usr/bin:/bin" "$policy_checker" --check-tools >/dev/null 2>&1; then
	fail "fails fast when Meson is unavailable"
fi
"$policy_checker" --setup-args | grep -Fx -- '--wrap-mode=nodownload' >/dev/null \
	|| fail "requires Meson no-download setup mode"
echo "ok - enforces system-only Meson and Ninja tooling"
