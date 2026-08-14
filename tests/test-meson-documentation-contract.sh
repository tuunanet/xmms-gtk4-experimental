#!/bin/sh
set -eu

repo_root=${1:?usage: $0 REPO_ROOT}

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

for document in \
	CLAUDE.md \
	CONTRIBUTING.md \
	README.md \
	docs/architecture/build-and-test.md \
	docs/releases.md \
	specs/WORKFLOW-solo-git.md \
	specs/tech-architecture/tech-stack.md
do
	grep -F 'tools/preflight.sh' "$repo_root/$document" >/dev/null \
		|| fail "$document documents the canonical Meson preflight"
done

preflight_prerequisites='build-essential git pkg-config gettext libasound2-dev libgl-dev libgtk2.0-dev libgtk-3-dev libmikmod-dev libsm-dev libvorbis-dev libxxf86vm-dev zlib1g-dev meson ninja-build python3 cppcheck xvfb xauth dpkg-dev debhelper lintian binutils tar'
for document in README.md CONTRIBUTING.md docs/architecture/build-and-test.md specs/tech-architecture/tech-stack.md; do
	for prerequisite in $preflight_prerequisites; do
		grep -F "$prerequisite" "$repo_root/$document" >/dev/null \
			|| fail "$document documents the $prerequisite preflight prerequisite"
	done
done

for document in CLAUDE.md CONTRIBUTING.md specs/tech-architecture/tech-stack.md; do
	if grep -F '.github/workflows/ci.yml' "$repo_root/$document" >/dev/null; then
		fail "$document does not reference an untracked CI workflow"
	fi
	grep -F '.github/workflows/package-release.yml' "$repo_root/$document" >/dev/null \
		|| fail "$document names the tracked manual release workflow"
done
if grep -F 'gh run list' "$repo_root/CLAUDE.md" >/dev/null; then
	fail "CLAUDE.md does not promise an untracked push CI workflow"
fi
if grep -F '.github/workflows/ci.yml' "$repo_root/specs/TRACEABILITY_LATEST.md" >/dev/null; then
	fail "traceability evidence does not reference an untracked CI workflow"
fi
grep -F 'no push CI workflow tracked' "$repo_root/specs/TRACEABILITY_LATEST.md" >/dev/null \
	|| fail "traceability evidence documents the manual-only workflow model"
if grep -F 'preflight and CI' "$repo_root/CONTRIBUTING.md" >/dev/null; then
	fail "CONTRIBUTING.md does not claim an untracked lint CI gate"
fi
if grep -F 'tests/test-project-agent-wiring.sh' \
	"$repo_root/docs/architecture/build-and-test.md" >/dev/null; then
	fail "architecture guide does not document an absent test path"
fi

if grep -F '`make check` currently orchestrates' \
	"$repo_root/specs/tech-architecture/tech-stack.md" >/dev/null || \
	grep -F '`make distcheck` validates' \
	"$repo_root/specs/tech-architecture/tech-stack.md" >/dev/null; then
	fail "tech-stack names Meson preflight rather than retired active Autotools gates"
fi

for document in \
	CLAUDE.md CONTRIBUTING.md CONVENTIONS.md docs/architecture/README.md \
	docs/architecture/build-and-test.md docs/architecture/external-control.md \
	docs/architecture/plugin-system.md docs/releases.md \
	specs/tech-architecture/tech-stack.md \
	specs/tech-architecture/e03-TEST_PLAN_LATEST.md \
	specs/tech-architecture/e04-TEST_PLAN_LATEST.md
do
	if grep -Eq 'Autotools|libtool|`make (lint|install|check|dist|distcheck)`|`\./configure|`configure\.in`|`Makefile\.(am|in)`|`autoreconf|`intl/' \
		"$repo_root/$document"; then
		fail "$document does not retain a live Autotools build contract"
	fi
done

grep -F 'Historical Solaris plugin documentation' \
	"$repo_root/Output/solaris/README.solaris" >/dev/null \
	|| fail "Solaris plugin guide identifies its retained historical commands"
if grep -Eq 'Makefile\.(am|in)|tests/Makefile' \
	"$repo_root/specs/TRACEABILITY_LATEST.md"; then
	fail "traceability does not name removed build artifacts"
fi
if grep -F 'current configure contract' \
	"$repo_root/specs/tech-architecture/e05-TEST_PLAN_LATEST.md" >/dev/null; then
	fail "test plan identifies the captured Meson feature baseline"
fi

echo "ok - contributor, agent, architecture, release, workflow, and tech-stack guides name Meson preflight"
