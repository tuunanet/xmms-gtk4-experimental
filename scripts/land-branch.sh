#!/usr/bin/env bash
# land-branch.sh — Solo-local integrate: squash-merge feature branch onto main and push.
# Requires GIT_BIGPOWERS_LAND=1 for hook exceptions on commit/push to protected branches.
# Usage: bash scripts/land-branch.sh <feature-branch> "<conventional commit message>"
# Run from the primary repository root (not a linked worktree).
set -euo pipefail

# shellcheck source=lib/land-branch-push.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/land-branch-push.sh"

CONVENTIONAL_REGEX='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: .+'

usage_land() {
  echo "Usage: $0 <feature-branch> \"<conventional commit message>\"" >&2
  echo "  Commit verified task changes, then run from the primary repo root after release-branch gates." >&2
  exit 1
}

land_branch_deny() {
  echo "ERROR: $1" >&2
  exit 1
}

[ "$#" -eq 2 ] || usage_land

FEATURE_BRANCH="$1"
COMMIT_MSG="$2"

[ -n "$FEATURE_BRANCH" ] && [ -n "$COMMIT_MSG" ] || usage_land

# Both checks below judge the subject line, not the whole message. The length
# test used to read ${#COMMIT_MSG}, so any Conventional Commit carrying a body
# was rejected no matter how short its subject — the error text said "subject
# line" while the check measured the entire string.
COMMIT_SUBJECT="${COMMIT_MSG%%$'\n'*}"

if [[ ! "$COMMIT_SUBJECT" =~ $CONVENTIONAL_REGEX ]]; then
  land_branch_deny "Commit message must follow Conventional Commits: <type>(<scope>): <subject>"
fi

if [ ${#COMMIT_SUBJECT} -gt 72 ]; then
  land_branch_deny "Commit subject line must be 72 characters or less (got ${#COMMIT_SUBJECT})"
fi

# Block AI agent attribution (P1 — CONVENTIONS.md § Git Attribution)
if echo "$COMMIT_MSG" | grep -qiE '^co[- ]authored[- ]by:' || echo "$COMMIT_MSG" | grep -qiE '\nco[- ]authored[- ]by:'; then
  land_branch_deny "Commit must not include Co-authored-by: footer. All commits must appear as if authored solely by the human user."
fi

# Primary worktree only (.git is a directory, not a gitdir pointer file)
if [ -f .git ]; then
  land_branch_deny "Run from the primary repository root, not a linked worktree (cd to main repo first)"
fi

detect_default_branch() {
  local remote_head
  remote_head=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)
  if [ -n "$remote_head" ]; then
    echo "$remote_head"
    return
  fi
  if git show-ref --verify --quiet refs/heads/main; then
    echo "main"
  elif git show-ref --verify --quiet refs/heads/master; then
    echo "master"
  else
    land_branch_deny "Could not detect default branch (main/master)"
  fi
}

find_branch_worktree() {
  local target="refs/heads/$1"
  git worktree list --porcelain | awk -v target="$target" '
    /^worktree / { path = substr($0, 10) }
    /^branch / && substr($0, 8) == target { print path; exit }
  '
}

require_clean_feature_worktree() {
  if [ -n "$(git -C "$FEATURE_WORKTREE" status --porcelain)" ]; then
    land_branch_deny "Task worktree '$FEATURE_WORKTREE' is not clean. Commit or remove its changes before landing."
  fi
}

DEFAULT_BRANCH=$(detect_default_branch)
REPO_ROOT=$(pwd)
CURRENT_BRANCH=$(git branch --show-current)

echo "==> Land branch: $FEATURE_BRANCH -> $DEFAULT_BRANCH"
echo "    Repo root: $REPO_ROOT"

if [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
  land_branch_deny "Primary checkout must be on $DEFAULT_BRANCH before landing"
fi

if [ -n "$(git status --porcelain)" ]; then
  land_branch_deny "Working tree on $DEFAULT_BRANCH is not clean. Stash or commit first."
fi

if ! git show-ref --verify --quiet "refs/heads/$FEATURE_BRANCH"; then
  land_branch_deny "Feature branch '$FEATURE_BRANCH' does not exist"
fi

# Scan all commits in feature branch for Co-authored-by: footers
if git log "$DEFAULT_BRANCH..$FEATURE_BRANCH" --format="%B" 2>/dev/null | grep -qiE '^co[- ]authored[- ]by:'; then
  land_branch_deny "Feature branch '$FEATURE_BRANCH' contains Co-authored-by: footer(s). Amend commits to remove all AI agent attribution before landing."
fi

for protected in main master; do
  if [ "$FEATURE_BRANCH" = "$protected" ]; then
    land_branch_deny "Cannot land protected branch '$FEATURE_BRANCH'"
  fi
done

FEATURE_WORKTREE=$(find_branch_worktree "$FEATURE_BRANCH")
if [ -z "$FEATURE_WORKTREE" ]; then
  land_branch_deny "Feature branch '$FEATURE_BRANCH' must be checked out in an isolated task worktree"
fi
require_clean_feature_worktree
FEATURE_SHA_BEFORE_VERIFY=$(git rev-parse "$FEATURE_BRANCH")

run_verify_suite() {
  local verify_root="$1"
  (
    cd "$verify_root"
    echo "==> Running pre-land verification in $verify_root..."
    if [ ! -x tools/preflight.sh ]; then
      land_branch_deny "Canonical project preflight is missing or not executable."
    fi
    tools/preflight.sh
  )
}

run_verify_suite "$FEATURE_WORKTREE"
require_clean_feature_worktree
if [ "$(git rev-parse "$FEATURE_BRANCH")" != "$FEATURE_SHA_BEFORE_VERIFY" ]; then
  land_branch_deny "Feature branch '$FEATURE_BRANCH' changed during verification; run the land command again"
fi

echo "==> Updating $DEFAULT_BRANCH"
git checkout "$DEFAULT_BRANCH"
if [ -n "$(git status --porcelain)" ]; then
  land_branch_deny "Working tree on $DEFAULT_BRANCH is not clean. Stash or commit first."
fi

if git remote get-url origin >/dev/null 2>&1; then
  git pull --ff-only origin "$DEFAULT_BRANCH" || land_branch_deny "git pull --ff-only failed; resolve before landing"
  if [ "$(git rev-parse "$DEFAULT_BRANCH")" != "$(git rev-parse "origin/$DEFAULT_BRANCH")" ]; then
    land_branch_deny "Local $DEFAULT_BRANCH differs from origin/$DEFAULT_BRANCH; reconcile it before landing"
  fi
fi

if ! git merge-base --is-ancestor "$DEFAULT_BRANCH" "$FEATURE_BRANCH" 2>/dev/null; then
  land_branch_deny "Feature branch '$FEATURE_BRANCH' is not based on current $DEFAULT_BRANCH (rebase or recreate branch)"
fi

export GIT_BIGPOWERS_LAND=1

echo "==> Squash merge $FEATURE_BRANCH"
git merge --squash "$FEATURE_BRANCH"
if git diff-index --quiet HEAD -- 2>/dev/null; then
  land_branch_deny "Squash merge produced no changes (already merged?)"
fi

git commit -m "$COMMIT_MSG"
LAND_SHA=$(git rev-parse --short HEAD)
echo "==> Land commit: $LAND_SHA"

if git remote get-url origin >/dev/null 2>&1; then
  echo "==> Pushing $DEFAULT_BRANCH to origin"
  if ! land_push_default_branch "$DEFAULT_BRANCH" "$LAND_SHA" "$FEATURE_BRANCH" "$COMMIT_MSG"; then
    land_branch_deny "git push origin $DEFAULT_BRANCH failed"
  fi
fi

# Worktree cleanup
echo "==> Removing worktree $FEATURE_WORKTREE"
git worktree remove "$FEATURE_WORKTREE" ||
  land_branch_deny "Task worktree cleanup failed. Preserve it and inspect the landed commit."
git worktree prune 2>/dev/null || true

if git show-ref --verify --quiet "refs/heads/$FEATURE_BRANCH"; then
  git branch -D "$FEATURE_BRANCH"
fi

git checkout "$DEFAULT_BRANCH"

echo ""
echo "Land complete."
echo "  Branch:   $FEATURE_BRANCH (removed)"
echo "  Commit:   $LAND_SHA on $DEFAULT_BRANCH"
echo "  Message:  $COMMIT_MSG"
echo "  cwd:      $(pwd)"
echo "  current:  $(git branch --show-current)"
echo ""
echo "semantic-release will pick up the push to $DEFAULT_BRANCH when configured."
