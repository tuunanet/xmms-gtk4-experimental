# e05s05: Make Meson preflight the agent and contributor contract

**type:** docs
**risk:** P1
**context:** developer and agent workflow

## Context

Agent instructions currently prescribe configure/make commands and do not offer
a single canonical preflight. The final operational contract must be explicit,
fail fast for missing system tools, and share one versioned wrapper across
agents, contributors, and CI-facing documentation.

## Requirements

#### MODIFIED: Build preflight contract

**Before:** CLAUDE.md and related documents name configure/make commands.
**After:** They name `tools/preflight.sh` and its scoped Meson-era gates.

## Steps

1. Add fail-fast system-tool Meson preflight wrapper → verify: `tests/test-preflight.sh "$PWD" && tools/preflight.sh`
2. Update agent, contributor, architecture, release, workflow, and active spec contracts → verify: `tests/test-meson-documentation-contract.sh "$PWD"`
3. Prove clean-environment no-bootstrap behavior → verify: `tests/verify-preflight-clean-environment.sh`

## Test traceability

- SC-e05s05-P1-01
- SC-e05s05-P1-02

## Acceptance criteria

- Given missing Meson or Ninja, when preflight runs, then it fails with an
  actionable system-package message and never uses pip or downloads a wrap.
- Given a supported environment, when an agent follows CLAUDE.md, then one
  documented command runs the appropriate Meson gates.

## Out of scope

This story does not remove Autotools files; e05s06 does after all gates pass.
