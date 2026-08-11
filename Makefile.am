AUTOMAKE_OPTIONS = foreign

SUBDIRS = intl libxmms xmms Output Input Effect General Visualization wmxmms po

bin_SCRIPTS = xmms-config

MESON_DIST = \
	meson.build \
	meson_options.txt \
	xmms-config.meson.in \
	libxmms/meson.build \
	xmms/meson.build \
	xmms/i18n.meson.h.in \
	wmxmms/meson.build \
	Effect/echo_plugin/meson.build \
	Effect/stereo_plugin/meson.build \
	Effect/voice/meson.build \
	General/ir/meson.build \
	General/joystick/meson.build \
	General/song_change/meson.build \
	Input/cdaudio/meson.build \
	Input/mikmod/meson.build \
	Input/mpg123/meson.build \
	Input/tonegen/meson.build \
	Input/vorbis/meson.build \
	Input/wav/meson.build \
	Output/OSS/meson.build \
	Output/alsa/meson.build \
	Output/disk_writer/meson.build \
	Output/esd/meson.build \
	Visualization/blur_scope/meson.build \
	Visualization/opengl_spectrum/meson.build \
	Visualization/sanalyzer/meson.build \
	tests/meson.build \
	tests/test-build-parity-contract.sh \
	tests/test-meson-configure-contract.sh \
	tests/test-meson-dist-contract.sh \
	tests/test-meson-test-suite-contract.sh \
	tests/test-meson-documentation-contract.sh \
	tests/test-preflight.sh \
	tests/verify-preflight-clean-environment.sh \
	tests/test-mikmod-build-contract.sh \
	tests/verify-meson-install-layout.sh \
	tests/verify-meson-output-contract.sh \
	tests/test-outputplugin-plugins/Output/alsa/.libs/meson.build \
	tests/test-plugins/Input/fixture/.libs/meson.build \
	tests/test-plugins/Output/fixture/.libs/meson.build \
	tools/verify-meson-dist.sh \
	tools/verify-build-parity.sh

EXTRA_DIST = $(MESON_DIST) \
	.github/workflows/package-release.yml \
	.editorconfig \
	.gitattributes \
	.gitignore \
	CHANGELOG.md \
	CLAUDE.md \
	CODE_OF_CONDUCT.md \
	CONTRIBUTING.md \
	CONVENTIONS.md \
	CONTRIBUTORS.md \
	README.md \
	SECURITY.md \
	docs/architecture/build-and-test.md \
	docs/architecture/plugin-system.md \
	docs/architecture/ui-interaction.md \
	docs/history/README.md \
	docs/history/prior-fork-changelog.md \
	docs/history/upstream-changelog.txt \
	docs/history/upstream-faq.txt \
	docs/history/upstream-release-notes.txt \
	docs/history/upstream-todo.txt \
	docs/images/README.md \
	docs/images/xmms.png \
	docs/manual.md \
	docs/releases.md \
	mkinstalldirs \
	packaging/debian/control \
	packaging/debian/copyright \
	packaging/debian/libxmms-dev.install \
	packaging/debian/rules \
	packaging/debian/source/format \
	packaging/debian/xmms.docs \
	packaging/debian/xmms.install \
	packaging/xmms.desktop \
	scripts/land-branch.sh \
	scripts/lib/land-branch-push.sh \
	specs/WORKFLOW-solo-git.md \
	specs/workflows/solo-git.yaml \
	specs/adr/ADR-0001-staged-gtk-migration.md \
	specs/adr/ADR-0002-meson-tooling-migration.md \
	specs/execution-status.yaml \
	specs/release-plan.yaml \
	specs/state.yaml \
	specs/TRACEABILITY_LATEST.md \
	specs/tech-architecture/e05-legacy-build-baseline.json \
	specs/tech-architecture/e05-meson-toolchain-policy.json \
	specs/tech-architecture/tech-stack.md \
	tests/Makefile \
	tests/test-autotools-meson-dist.sh \
	tests/test-autotools-package-deb.sh \
	tests/fixture-input-plugin.c \
	tests/fixture-output-plugin.c \
	tests/test-alsa-pcm-state.c \
	tests/test-alsa-volume.c \
	tests/test-filebrowser.c \
	tests/test-font-load.c \
	tests/test-gtk3-play-button-proof.c \
	tests/test-c-lint.sh \
	tests/test-intl-generated-sources.sh \
	tests/test-mpg123-file-duration.c \
	tests/test-mpg123-stream-position.c \
	tests/test-meson-migration-contracts.sh \
	tests/test-outputplugin.c \
	tests/test-package-artifact-contracts.sh \
	tests/test-package-recipes.sh \
	tests/verify-debian-package-contract.sh \
	tests/test-pbutton-baseline.c \
	tests/test-ui-control.c \
	tests/test-plugin-linkage.sh \
	tests/test-pluginenum.c \
	tests/test-popup-position.c \
	tests/test-release-tools.sh \
	tests/test-solo-git-workflow.sh \
	tests/test-xentry.c \
	tools/build-deb.sh \
	tools/package-deb.sh \
	tools/preflight.sh \
	tools/verify-release-artifacts.sh \
	tools/check-release-version.sh \
	tools/cppcheck-suppressions.txt \
	tools/run-c-lint.sh \
	tools/validate-lifecycle-state.py \
	tools/verify-build-baseline.sh \
	tools/verify-meson-toolchain-policy.sh \
	tools/extract-release-notes.sh \
	xmms/ui_gtk3_control.c \
	xmms/ui_gtk3_control.h \
	xmms.m4

m4datadir = $(datadir)/aclocal
m4data_DATA = xmms.m4

man_MANS = xmms.1 wmxmms.1

.PHONY: deb lint

lint:
	$(SHELL) '$(top_srcdir)/tools/run-c-lint.sh'

deb:
	@DEB_OUTPUT_DIR='$(DEB_OUTPUT_DIR)' '$(SHELL)' \
		'$(top_srcdir)/tools/package-deb.sh'

DEB_OUTPUT_DIR = $(top_builddir)/deb-artifacts

check-local:
	$(mkdir_p) tests
	@top_srcdir=`cd $(top_srcdir) && pwd`; top_builddir=`pwd`; \
	$(MAKE) -C tests -f "$$top_srcdir/tests/Makefile" \
		srcdir="$$top_srcdir/tests" top_srcdir="$$top_srcdir" \
		top_builddir="$$top_builddir" \
		GTK3_PROOF_ENABLED='@GTK3_PROOF_ENABLED@' \
		GTK3_CFLAGS='@GTK3_CFLAGS@' GTK3_LIBS='@GTK3_LIBS@' check

clean-local:
	@if test -d tests; then \
		top_srcdir=`cd $(top_srcdir) && pwd`; \
		$(MAKE) -C tests -f "$$top_srcdir/tests/Makefile" \
			srcdir="$$top_srcdir/tests" top_srcdir="$$top_srcdir" clean; \
	fi
