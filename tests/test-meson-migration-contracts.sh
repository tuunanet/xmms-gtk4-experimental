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
contract_tmpdir=$(mktemp -d)
trap 'rm -rf "$contract_tmpdir"' EXIT HUP INT TERM
advanced_state="$contract_tmpdir/state.yaml"
sed 's/^active_story_id:.*/active_story_id: e05s99/' \
	"$repo_root/specs/state.yaml" > "$advanced_state"
"$lifecycle_checker" \
	"$advanced_state" \
	"$repo_root/specs/execution-status.yaml" \
	"$repo_root/specs/release-plan.yaml"
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

policy_tmpdir="$contract_tmpdir/policy"
mkdir -p "$policy_tmpdir/bin"
printf '%s\n' '#!/bin/sh' 'echo 1.3.2' > "$policy_tmpdir/bin/meson"
printf '%s\n' '#!/bin/sh' 'echo 1.6' > "$policy_tmpdir/bin/ninja"
chmod +x "$policy_tmpdir/bin/meson" "$policy_tmpdir/bin/ninja"
PATH="$policy_tmpdir/bin:/usr/bin:/bin" "$policy_checker" --check-tools
missing_tool_dir="$contract_tmpdir/missing-tool-bin"
mkdir -p "$missing_tool_dir"
ln -s "$(command -v dirname)" "$missing_tool_dir/dirname"
ln -s "$(command -v python3)" "$missing_tool_dir/python3"
missing_tool_log="$contract_tmpdir/missing-tool.log"
if PATH="$missing_tool_dir" "$policy_checker" --check-tools \
	>"$missing_tool_log" 2>&1; then
	fail "fails fast when Meson is unavailable"
fi
grep -F "install system package 'meson'" "$missing_tool_log" >/dev/null \
	|| fail "explains how to install missing Meson"
"$policy_checker" --setup-args | grep -Fx -- '--wrap-mode=nodownload' >/dev/null \
	|| fail "requires Meson no-download setup mode"
echo "ok - enforces system-only Meson and Ninja tooling"
