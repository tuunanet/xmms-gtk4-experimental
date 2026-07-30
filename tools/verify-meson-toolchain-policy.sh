#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
policy="$repo_root/specs/tech-architecture/e05-meson-toolchain-policy.json"
mode=${1:---check-policy}

read_policy()
{
	python3 - "$policy" "$1" <<'PY'
import json
import sys

policy = json.load(open(sys.argv[1], encoding="utf-8"))
field = sys.argv[2]
if policy.get("schema_version") != 1:
    raise SystemExit("unsupported policy schema")
if field == "setup_args":
    print("\n".join(policy["meson_setup_arguments"]))
else:
    print(policy[field]["command"])
    print(policy[field]["minimum_version"])
    print(policy[field]["system_package"])
PY
}

check_policy()
{
	python3 - "$policy" "$repo_root" <<'PY'
import json
import sys
from pathlib import Path

policy = json.load(open(sys.argv[1], encoding="utf-8"))
root = Path(sys.argv[2])
if policy.get("dependency_source") != "system-pkg-config-only":
    raise SystemExit("error: dependencies must be system/pkg-config only")
if policy.get("meson_setup_arguments") != ["--wrap-mode=nodownload"]:
    raise SystemExit("error: Meson must use no-download setup mode")
forbidden = set(policy.get("forbidden", []))
for item in ("pip bootstrap", "WrapDB downloads", "Meson subprojects", "implicit network dependency resolution"):
    if item not in forbidden:
        raise SystemExit(f"error: policy does not forbid {item}")
if (root / "subprojects").exists() or list(root.rglob("*.wrap")):
    raise SystemExit("error: tracked Meson subprojects or wraps are prohibited")
PY
}

check_tool()
{
	tool=$1
	minimum=$2
	package=$3
	if ! command -v "$tool" >/dev/null 2>&1; then
		echo "error: install system package '$package' to provide $tool >= $minimum" >&2
		exit 1
	fi
	actual=$($tool --version)
	python3 - "$tool" "$actual" "$minimum" <<'PY'
import re
import sys

def version(value):
    match = re.search(r"\d+(?:\.\d+)+", value)
    if not match:
        raise SystemExit(f"error: cannot parse {sys.argv[1]} version: {value}")
    return tuple(int(part) for part in match.group(0).split("."))

actual = version(sys.argv[2])
minimum = version(sys.argv[3])
length = max(len(actual), len(minimum))
actual += (0,) * (length - len(actual))
minimum += (0,) * (length - len(minimum))
if actual < minimum:
    raise SystemExit(
        f"error: {sys.argv[1]} {sys.argv[2]} is below required {sys.argv[3]}"
    )
PY
}

case "$mode" in
	--check-policy)
		check_policy
		;;
	--check-tools)
		set -- $(read_policy meson)
		check_tool "$1" "$2" "$3"
		set -- $(read_policy ninja)
		check_tool "$1" "$2" "$3"
		;;
	--setup-args)
		read_policy setup_args
		;;
	*)
		echo "usage: $0 [--check-policy|--check-tools|--setup-args]" >&2
		exit 2
		;;
esac
