#!/usr/bin/env bash
# land-branch-push.sh — push helper for the solo-local land command.
set -euo pipefail

if [[ -n "${LAND_BRANCH_PUSH_LOADED:-}" ]]; then return 0; fi
LAND_BRANCH_PUSH_LOADED=1

is_protected_branch_rejection() {
  local output="$1"
  printf '%s\n' "$output" |
    grep -qE '(^|[[:space:]])GH006|Changes must be made through a pull request'
}

report_protected_branch_rejection() {
  local land_sha="$1"
  local feature_branch="$2"
  local commit_msg="$3"
  {
    echo "ERROR: Remote protection rejected the solo-local push."
    echo "The script did not create a pull request or rewrite local history."
    echo "Keep branch '$feature_branch' and commit '$land_sha'."
    echo "If a pull request is required, select it explicitly through release-branch."
    echo "Proposed message: $commit_msg"
  } >&2
}

land_push_default_branch() {
  local default_branch="$1"
  local land_sha="$2"
  local feature_branch="$3"
  local commit_msg="$4"
  local push_output=""
  local push_status=0

  if push_output=$(git push origin "$default_branch" 2>&1); then
    return 0
  else
    push_status=$?
  fi
  printf '%s\n' "$push_output" >&2
  if is_protected_branch_rejection "$push_output"; then
    report_protected_branch_rejection "$land_sha" "$feature_branch" "$commit_msg"
  fi
  return "$push_status"
}
