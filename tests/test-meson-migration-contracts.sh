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
echo "ok - records the failed v0.0.3 draft release and active v0.0.4 repair"
grep -Fx '  head: HEAD' "$repo_root/specs/state.yaml" >/dev/null \
	|| fail "uses a symbolic head marker for self-updating evidence"
grep -Fx '  last_tag: v0.0.3' "$repo_root/specs/state.yaml" >/dev/null \
	|| fail "records the immutable failed v0.0.3 tag"
grep -Fx '  target_version: 0.0.4' "$repo_root/specs/state.yaml" >/dev/null \
	|| fail "targets the authorized v0.0.4 repair"
grep -Fx '  version: 0.0.4' "$repo_root/specs/release-plan.yaml" >/dev/null \
	|| fail "plans the v0.0.4 release metadata"
grep -F 'v0.0.4 tagged release validation' \
	"$repo_root/specs/epics/e05-meson-tooling-migration/e05s06-retire-autotools.md" >/dev/null \
	|| fail "requires v0.0.4 tagged release acceptance"
grep -F 'v0.0.4 draft-release acceptance' \
	"$repo_root/specs/epics/e05-meson-tooling-migration/e05s06-tasks.yaml" >/dev/null \
	|| fail "tracks v0.0.4 in the active release task"

grep -Fx '  e05: in_progress' "$repo_root/specs/execution-status.yaml" >/dev/null \
	|| fail "marks e05 repair in progress in the execution ledger"
grep -Fx '  e05s06: in_progress' "$repo_root/specs/execution-status.yaml" >/dev/null \
	|| fail "marks e05s06 repair in progress in the execution ledger"
awk '/^status: / { exit $0 != "status: in_progress" }' \
	"$repo_root/specs/epics/e05-meson-tooling-migration/epic.yaml" \
	|| fail "marks the e05 capsule repair in progress"
awk '
  /^  - id: e05$/ { in_e05 = 1; next }
  in_e05 && /^  - id:/ { exit !in_progress }
  in_e05 && /^    status: in_progress$/ { in_progress = 1 }
  END { exit !in_progress }
' "$repo_root/specs/release-plan.yaml" \
	|| fail "marks e05 repair in progress in the release plan"
grep -Fx 'status: in_progress' \
	"$repo_root/specs/epics/e05-meson-tooling-migration/e05s06-tasks.yaml" >/dev/null \
	|| fail "marks e05s06 repair in progress"
awk '
  /^  - id: t3$/ { in_t3 = 1; next }
  in_t3 && /^  - id:/ { exit !in_progress }
  in_t3 && /^    status: in_progress$/ { in_progress = 1 }
  END { exit !in_progress }
' "$repo_root/specs/epics/e05-meson-tooling-migration/e05s06-tasks.yaml" \
	|| fail "marks tagged draft-release repair in progress"
grep -Fx '  status: in_progress' "$repo_root/specs/state.yaml" >/dev/null \
	|| fail "hands off active e05 repair"
awk '/^wsjf: / { exit $0 != "wsjf: 3.5" }' \
	"$repo_root/specs/epics/e05-meson-tooling-migration/epic.yaml" \
	|| fail "matches the release-plan e05 WSJF"
awk '
  /^  - id: e05s04$/ { in_e05s04 = 1; next }
  in_e05s04 && /^  - id:/ { exit !verified }
  in_e05s04 && /^    status: verified$/ { verified = 1 }
  END { exit !verified }
' "$repo_root/specs/epics/e05-meson-tooling-migration/epic.yaml" \
	|| fail "marks e05s04 verified in the capsule"
invalid_execution="$contract_tmpdir/invalid-execution-status.yaml"
sed 's/^  e05: in_progress$/  e05: verified/' \
	"$repo_root/specs/execution-status.yaml" > "$invalid_execution"
if "$lifecycle_checker" "$repo_root/specs/state.yaml" "$invalid_execution" \
	"$repo_root/specs/release-plan.yaml"; then
	fail "rejects a verified e05 while release repair is active"
fi
echo "ok - synchronizes active e05 release repair"
grep -Fx 'status: completed' "$repo_root/specs/planning-status.yaml" >/dev/null \
	|| fail "marks e05 planning complete"
if grep -F 'e04 lifecycle evidence is being reconciled' \
	"$repo_root/specs/planning-status.yaml" >/dev/null; then
	fail "removes stale e05 planning reconciliation"
fi
echo "ok - records completed e05 planning status"

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
