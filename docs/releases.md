# Release process

XMMS GTK4 Experimental uses deliberate, manually tested releases. Verified
maintainer work normally lands through the Solo Git workflow; external or
explicitly selected pull requests remain supported. An immutable annotated
`v*` tag on `main` identifies the exact source that may be packaged. The checked-in
**Linux packages and release** workflow (`.github/workflows/package-release.yml`)
is manually dispatched from that tag and creates or resumes an unpublished
draft GitHub Release. A maintainer publishes the draft only after reviewing its
assets and checksums.

## Release lifecycle

```text
verified work -> main -> release/VERSION -> annotated vVERSION tag on main
                                                    |
                                                    v
                        manually dispatch package-release.yml on that tag
                                                    |
                                                    v
                   Mint + Ubuntu package checks -> draft GitHub Release
                                                    |
                                                    v
                                         manual review and publication
```

## 1. Prepare the release

Use `kickoff-branch` to create an isolated `release/VERSION` worktree from an
up-to-date, clean `main`. Prepare one focused release change there.

The commit must update:

1. `configure.in` (`AM_INIT_AUTOMAKE`);
2. the matching version field in the shipped `configure` script; and
3. `CHANGELOG.md`, by moving the release contents from `[Unreleased]` into a
   dated `[VERSION]` entry and retaining a new empty `[Unreleased]` section.

The legacy Autotools stack cannot be regenerated unchanged with modern
`autoreconf`. Update only the necessary checked-in generated version fields.

Validate the metadata locally:

```sh
tools/check-release-version.sh 0.0.1
```

After verification, audit, and `commit-message`, use `release-branch` in
`solo-local` mode and land from the primary checkout:

```sh
bash scripts/land-branch.sh release/0.0.1 "chore(release): prepare 0.0.1"
```

If remote protection requires a pull request, select that path explicitly in
`release-branch`. Do not tag until the preparation is on `main` and its required
review is complete.

## 2. Create the annotated release tag

From the resulting `main` commit, create and push an annotated matching tag:

```sh
git switch main
git pull --ff-only
git tag -a v0.0.1 -m "XMMS GTK4 Experimental 0.0.1"
git push origin v0.0.1
```

The workflow accepts only an annotated `vMAJOR.MINOR.PATCH` tag whose target is
contained in `main`. It rejects a mismatched version input, a lightweight tag,
a non-tag ref, stale `configure` metadata, or a missing/duplicate changelog
entry.

## 3. Dispatch Linux packages and release

Open **Actions → Linux packages and release → Run workflow**. Select the
annotated `vVERSION` tag and enter the same bare `VERSION` (for example,
`0.0.1`). The workflow is manual-only; it does not run for pushes or pull
requests.

The workflow validates the tag and release metadata, then builds and verifies
both declared x86-64 targets:

- Linux Mint 22.3 (`zena`)
- Ubuntu 26.04 (`resolute`)

Each isolated target image installs the complete package toolchain, including
GTK2 and `libgtk-3-dev` so the enabled GTK3 migration proof remains covered. It
creates the source archive, builds `xmms` and `libxmms-dev` DEBs with the
existing `make deb` path, runs the package tests, inspects package metadata,
and installs both DEBs for smoke tests.

The jobs upload target artifacts containing DEBs, `PACKAGE-METADATA.txt`, and
SHA-256 manifests. The final job re-verifies each target manifest, assembles the
source archive and packages, writes release metadata and release notes, and
verifies the aggregate `SHA256SUMS` before release attachment.

## 4. Review the draft

After both package jobs pass, the final job creates a new draft GitHub Release
or updates an existing draft for the same tag. Default workflow permissions are
read-only; only this final draft-release job receives `contents: write`.
Published releases are immutable: the workflow fails rather than modifying one.

Before publishing the draft:

1. confirm its tag and displayed version;
2. inspect the extracted release notes;
3. download every asset and run `sha256sum -c SHA256SUMS`;
4. inspect the Linux Mint and Ubuntu package metadata; and
5. install and smoke-test the packages in appropriate environments when
   available.

Only after these checks should a maintainer publish the draft manually. Never
move, delete, recreate, or silently replace a published release tag or asset;
publish a new patch release for a correction instead.

## Rollback and hotfixes

A GitHub Release is immutable history, not a deployment that can be silently
rolled back. If a published artifact is defective, mark it clearly if users
must avoid it, prepare and test a new patch release, and publish that new
version through the same annotated-tag and draft-review flow.

## References

- [GitHub Actions workflow dispatch](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)
- [GitHub Actions permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [GitHub CLI release creation](https://cli.github.com/manual/gh_release_create)
- [Debian maintainer reference](https://www.debian.org/doc/manuals/debmake-doc/)
