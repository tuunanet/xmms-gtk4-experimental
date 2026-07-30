#!/bin/sh
set -eu

build_dir=${1:?usage: verify-build-parity.sh BUILD_DIR}
repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
baseline="$repo_root/specs/tech-architecture/e05-legacy-build-baseline.json"

python3 - "$build_dir" "$baseline" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

build_dir = Path(sys.argv[1]).resolve()
baseline_path = Path(sys.argv[2])


def fail(message):
    raise SystemExit(f"error: {message}")


def introspect(kind):
    try:
        result = subprocess.run(
            ["meson", "introspect", str(build_dir), kind],
            check=True,
            capture_output=True,
            encoding="utf-8",
        )
        return json.loads(result.stdout)
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        fail(f"cannot inspect Meson {kind}: {error}")


try:
    baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError) as error:
    fail(f"cannot read legacy baseline: {error}")

if baseline.get("schema_version") != 1:
    fail("unsupported legacy baseline schema")
if baseline.get("legacy_toolchain") != "autotools-libtool":
    fail("baseline must identify the Autotools/libtool authority")

options = {option["name"] for option in introspect("--buildoptions")}
dependencies = {dependency["name"] for dependency in introspect("--dependencies")}
targets = introspect("--targets")

for option in baseline["configuration"]["options"]:
    if option not in options:
        fail(f"Meson omits legacy option: {option}")

for dependency in baseline["configuration"]["required_pkg_config_modules"]:
    if dependency not in dependencies:
        fail(f"Meson omits required dependency: {dependency}")


def target_outputs(target):
    return [Path(filename) for filename in target.get("filename", [])]


def has_output(relative_path):
    expected = build_dir / relative_path
    return any(expected in target_outputs(target) and expected.is_file() for target in targets)


for executable in baseline["outputs"]["executables"]:
    if not has_output(Path(executable) / executable):
        fail(f"Meson omits legacy executable: {executable}")

library_name = baseline["outputs"]["library"]
if not any(
    output.name.startswith(f"{library_name}.so") and output.is_file()
    for target in targets
    for output in target_outputs(target)
):
    fail(f"Meson omits legacy library: {library_name}")

for family in baseline["outputs"]["plugin_families"]:
    if not any(
        target["type"] == "shared module"
        and any(output.is_relative_to(build_dir / family) and output.is_file()
                for output in target_outputs(target))
        for target in targets
    ):
        fail(f"Meson omits legacy plugin family: {family}")

proof = Path(baseline["outputs"]["isolated_gtk3_proof"])
proof_target = next(
    (target for target in targets if build_dir / proof in target_outputs(target)),
    None,
)
if proof_target is None or not (build_dir / proof).is_file():
    fail("Meson omits the isolated GTK3 proof")
proof_dependencies = set(proof_target.get("dependencies", []))
if "gtk+-3.0" not in proof_dependencies:
    fail("the GTK3 proof does not declare GTK3")
if "gtk+-2.0" in proof_dependencies:
    fail("the GTK3 proof declares GTK2")

print("ok - Meson build matches the frozen legacy option and output inventory")
PY
