#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}
baseline="$repo_root/specs/tech-architecture/e05-legacy-build-baseline.json"

fail()
{
	echo "error: $1" >&2
	exit 1
}

python3 - "$repo_root" "$baseline" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
baseline_path = Path(sys.argv[2])
try:
    baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError) as error:
    raise SystemExit(f"error: cannot read baseline: {error}")

if baseline.get("schema_version") != 1:
    raise SystemExit("error: unsupported baseline schema")
if baseline.get("toolchain") != "meson":
    raise SystemExit("error: baseline must identify Meson as the sole toolchain")

for relative_path in ("meson.build", "tests/meson.build",
                      "tests/verify-no-autotools-artifacts.sh"):
    if not (root / relative_path).is_file():
        raise SystemExit(f"error: missing Meson baseline input: {relative_path}")

meson_build = (root / "meson.build").read_text(encoding="utf-8")
for option in baseline["configuration"]["options"]:
    if f"option('{option}'" not in (root / "meson_options.txt").read_text(encoding="utf-8"):
        raise SystemExit(f"error: missing Meson option: {option}")

for family in baseline["outputs"]["plugin_families"]:
    if f"subdir('{family}/" not in meson_build:
        raise SystemExit(f"error: missing Meson plugin family: {family}")

for relative_path in baseline["test_contract"]["shell_contracts"]:
    if not (root / relative_path).is_file():
        raise SystemExit(f"error: missing test contract: {relative_path}")

workflow = (root / baseline["delivery_contract"]["release_workflow"]).read_text(encoding="utf-8")
if "tools/package-deb.sh" not in workflow:
    raise SystemExit("error: release workflow no longer exposes the Meson package baseline")

print("ok - Meson source and delivery baseline remain intact")
PY
