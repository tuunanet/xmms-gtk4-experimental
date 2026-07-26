AUTOMAKE_OPTIONS = foreign

SUBDIRS = intl libxmms xmms Output Input Effect General Visualization wmxmms po

bin_SCRIPTS = xmms-config

EXTRA_DIST = \
	.editorconfig \
	.gitattributes \
	.github/dependabot.yml \
	.github/ISSUE_TEMPLATE/bug_report.yml \
	.github/ISSUE_TEMPLATE/config.yml \
	.github/ISSUE_TEMPLATE/feature_request.yml \
	.github/pull_request_template.md \
	.github/workflows/ci.yml \
	CHANGELOG.md \
	CODE_OF_CONDUCT.md \
	CONTRIBUTING.md \
	CONTRIBUTORS.md \
	README.md \
	SECURITY.md \
	docs/history/README.md \
	docs/history/upstream-changelog.txt \
	docs/history/upstream-faq.txt \
	docs/history/upstream-release-notes.txt \
	docs/history/upstream-todo.txt \
	docs/manual.md \
	mkinstalldirs \
	tests/Makefile \
	tests/fixture-input-plugin.c \
	tests/fixture-output-plugin.c \
	tests/test-alsa-pcm-state.c \
	tests/test-filebrowser.c \
	tests/test-outputplugin.c \
	tests/test-pluginenum.c \
	tests/test-xentry.c \
	xmms.m4 \
	xmms.spec \
	xmms.spec.in

m4datadir = $(datadir)/aclocal
m4data_DATA = xmms.m4

man_MANS = xmms.1 wmxmms.1

check-local:
	$(mkdir_p) tests
	@top_srcdir=`cd $(top_srcdir) && pwd`; top_builddir=`pwd`; \
	$(MAKE) -C tests -f "$$top_srcdir/tests/Makefile" \
		srcdir="$$top_srcdir/tests" top_srcdir="$$top_srcdir" \
		top_builddir="$$top_builddir" check

clean-local:
	@if test -d tests; then \
		top_srcdir=`cd $(top_srcdir) && pwd`; \
		$(MAKE) -C tests -f "$$top_srcdir/tests/Makefile" \
			srcdir="$$top_srcdir/tests" top_srcdir="$$top_srcdir" clean; \
	fi
