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
if baseline.get("legacy_toolchain") != "autotools-libtool":
    raise SystemExit("error: baseline must identify the legacy toolchain")

for relative_path in baseline["source_manifests"] + baseline["generated_artifacts"]:
    if not (root / relative_path).is_file():
        raise SystemExit(f"error: missing baseline artifact: {relative_path}")

configure = (root / "configure.in").read_text(encoding="utf-8")
for option in baseline["configuration"]["options"]:
    if f"AC_ARG_ENABLE([{option}]" not in configure:
        raise SystemExit(f"error: missing legacy option: {option}")

makefile = (root / "Makefile.am").read_text(encoding="utf-8")
for family in baseline["outputs"]["plugin_families"]:
    if family not in makefile:
        raise SystemExit(f"error: missing plugin family from build order: {family}")

for relative_path in baseline["test_contract"]["shell_contracts"]:
    if not (root / relative_path).is_file():
        raise SystemExit(f"error: missing test contract: {relative_path}")

rules = (root / "packaging/debian/rules").read_text(encoding="utf-8")
if "./configure" not in rules:
    raise SystemExit("error: Debian rules no longer expose the legacy baseline")
workflow = (root / baseline["delivery_contract"]["release_workflow"]).read_text(encoding="utf-8")
if "./configure --disable-esd" not in workflow:
    raise SystemExit("error: release workflow no longer exposes the legacy baseline")

print("ok - legacy build baseline matches the tracked delivery contract")
PY
