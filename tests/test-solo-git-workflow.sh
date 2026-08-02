#!/usr/bin/env bash
set -euo pipefail

srcdir=${1:-.}
srcdir=$(cd "$srcdir" && pwd)
failures=0

ok() {
  echo "ok - $1"
}

not_ok() {
  echo "not ok - $1" >&2
  failures=$((failures + 1))
}

if bash -n "$srcdir/scripts/land-branch.sh" \
  "$srcdir/scripts/lib/land-branch-push.sh"; then
  ok 'parses the solo-local land scripts'
else
  not_ok 'parses the solo-local land scripts'
fi

if ! grep -F 'gh pr create' "$srcdir/scripts/lib/land-branch-push.sh" >/dev/null; then
  ok 'does not open a pull request from solo-local mode'
else
  not_ok 'does not open a pull request from solo-local mode'
fi

if ! grep -F -- '--skip-verify' "$srcdir/scripts/land-branch.sh" >/dev/null; then
  ok 'does not expose a verification bypass'
else
  not_ok 'does not expose a verification bypass'
fi

if grep -F 'elif [ -f meson.build ]; then' \
  "$srcdir/scripts/land-branch.sh" >/dev/null; then
  ok 'prefers the isolated Meson Preflight'
else
  not_ok 'prefers the isolated Meson Preflight'
fi

if bash -c '
  git() {
    echo "remote: error: GH006: Changes must be made through a pull request" >&2
    return 1
  }
  . "$1"
  set +e
  output=$(land_push_default_branch main deadbeef feature/test "chore(test): guard" 2>&1)
  status=$?
  test "$status" -eq 1 && printf "%s\n" "$output" |
    grep -F "did not create a pull request" >/dev/null
' bash "$srcdir/scripts/lib/land-branch-push.sh"; then
  ok 'stops when remote protection rejects a solo-local push'
else
  not_ok 'stops when remote protection rejects a solo-local push'
fi

land_tmp=$(mktemp -d)
trap 'rm -rf "$land_tmp"' EXIT
if (
  set -euo pipefail
  mkdir -p "$land_tmp/repo/scripts/lib"
  cp "$srcdir/scripts/land-branch.sh" "$land_tmp/repo/scripts/"
  cp "$srcdir/scripts/lib/land-branch-push.sh" "$land_tmp/repo/scripts/lib/"
  cd "$land_tmp/repo"
  git init -q -b main
  git config user.name 'Solo Workflow Test'
  git config user.email 'solo-workflow@example.invalid'
  touch baseline
  git add .
  git commit -q -m 'chore(test): create baseline'
  git init -q --bare "$land_tmp/origin.git"
  git remote add origin "$land_tmp/origin.git"
  git push -q -u origin main
  git worktree add -q "$land_tmp/task-worktree" -b feature/test
  echo landed >"$land_tmp/task-worktree/result"
  if BP_PREFLIGHT=true bash scripts/land-branch.sh \
    feature/test 'chore(test): reject dirty feature' >"$land_tmp/dirty.log" 2>&1; then
    exit 1
  fi
  grep -F 'is not clean' "$land_tmp/dirty.log" >/dev/null
  test "$(git log -1 --format=%s)" = 'chore(test): create baseline'
  git -C "$land_tmp/task-worktree" add result
  git -C "$land_tmp/task-worktree" commit -q -m 'chore(test): prepare feature'
  echo local >local-only
  git add local-only
  git commit -q -m 'chore(test): create local-only main commit'
  if BP_PREFLIGHT=true bash scripts/land-branch.sh \
    feature/test 'chore(test): reject ahead main' >"$land_tmp/ahead.log" 2>&1; then
    exit 1
  fi
  grep -F 'differs from origin/main' "$land_tmp/ahead.log" >/dev/null
  test -d "$land_tmp/task-worktree"
  git push -q origin main
  git -C "$land_tmp/task-worktree" merge -q main \
    -m 'chore(test): update feature base'
  BP_PREFLIGHT='test "$(git branch --show-current)" = feature/test && test -f result' \
    bash scripts/land-branch.sh feature/test \
    'chore(test): land feature' >"$land_tmp/land.log"
  test "$(git branch --show-current)" = main
  test "$(git log -1 --format=%s)" = 'chore(test): land feature'
  test "$(git --git-dir="$land_tmp/origin.git" log -1 --format=%s main)" = \
    'chore(test): land feature'
  test -f result
  test ! -d "$land_tmp/task-worktree"
  ! git show-ref --verify --quiet refs/heads/feature/test
); then
  ok 'guards state, squash-lands, pushes, and cleans the task worktree'
else
  not_ok 'guards state, squash-lands, pushes, and cleans the task worktree'
fi

if [ "$failures" -ne 0 ]; then
  echo "$failures Solo Git workflow checks failed" >&2
  exit 1
fi
