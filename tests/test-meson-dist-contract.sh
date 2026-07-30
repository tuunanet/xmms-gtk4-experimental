#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
verifier=$repo_root/tools/verify-meson-dist.sh

fail()
{
  printf '%s\n' "not ok - $1" >&2
  exit 1
}

require_text()
{
  grep -F -- "$1" "$verifier" >/dev/null || fail "distribution verifier contains $1"
}

test -x "$verifier" || fail 'project-owned Meson distribution verifier exists'
require_text 'meson dist'
require_text 'tar -x'
require_text 'meson setup'
require_text 'meson compile'
require_text 'meson test'
require_text 'verify-meson-install-layout.sh'

printf '%s\n' 'ok - Meson distribution verifier contract'
