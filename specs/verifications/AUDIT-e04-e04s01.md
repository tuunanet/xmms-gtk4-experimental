# Audit: e04s01 generic release-packaging workflow

**Reviewed range:** `58c4f24...0ca0faa` plus verification records
**Result:** PASS for reviewability and local contracts; post-merge tag dispatch remains pending.

## Checklist

- [x] **Scope:** The change adds only the requested manual release-packaging
  workflow, static package contracts, source-distribution wiring, and matching
  documentation. It does not add PR/push CI, templates, Dependabot, targets, or
  runtime changes.
- [x] **Supply chain:** The workflow adopts the donor's pinned checkout and
  artifact action commit SHAs; all build libraries remain distribution packages.
- [x] **Security:** Manual dispatch only, matching annotated-tag/main-ancestry
  validation, quoted/validated version input, read-only default permission,
  write permission only in the draft-release job, checksum verification, and
  published-release rejection are present. `specs/security/REVIEW.md` has zero
  reportable HIGH findings.
- [x] **Compatibility:** Debian package names, build helper, plugin ABI,
  `libxmms`, socket, configuration, skins, and production GTK2 process are
  unchanged. GTK3 headers are added only to the isolated package build
  environment so its existing proof remains exercised.
- [x] **Tests:** Static contracts cover workflow trigger, tag guard, target
  matrix, GTK3 dependency, permissions, checksum, draft release, branding,
  documentation, and source distribution. Full lint, Xvfb `make check`, and
  `make distcheck` pass.
- [x] **Clarity:** The workflow has one orchestration responsibility; its
  generic filename reflects two targets. Documentation replaces stale references
  to workflows that are not checked in.
- [x] **Defect handling:** The source-archive omission discovered by distcheck
  is logged in BUG-2026-07-29T231000, tested RED, repaired in both manifests,
  and proved by a passing distcheck.

## Fowler smell review

No Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive
Obsession, Message Chains, or Middle Man smell was introduced. The vendor-like
workflow deliberately retains the donor's explicit steps rather than hiding
release safeguards behind an untested local wrapper.

## Remaining acceptance gate

A real GitHub Actions run cannot occur until this workflow is merged to `main`
and an annotated matching release tag exists. Dispatching it then, inspecting
both target artifacts, and reviewing the draft release is mandatory before a
release is published.
