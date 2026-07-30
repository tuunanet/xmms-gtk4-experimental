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
