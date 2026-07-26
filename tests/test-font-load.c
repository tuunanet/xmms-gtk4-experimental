#include <glib.h>
#include <gtk/gtk.h>

#include "../xmms/xmms.h"
#include "../xmms/util.h"

Config cfg;

static void assert_legacy_default_loads(const gchar *name)
{
	GdkFont *font;

	cfg.use_fontsets = FALSE;
	font = util_font_load((gchar *) name);
	g_assert_nonnull(font);
	gdk_font_unref(font);
}

static void test_legacy_playlist_default(void)
{
	assert_legacy_default_loads(XMMS_LEGACY_PLAYLIST_FONT);
}

static void test_legacy_main_window_default(void)
{
	assert_legacy_default_loads(XMMS_LEGACY_MAINWIN_FONT);
}

int main(int argc, char **argv)
{
	gtk_init(&argc, &argv);
	g_test_init(&argc, &argv, NULL);
	g_log_set_always_fatal(G_LOG_LEVEL_ERROR | G_LOG_LEVEL_CRITICAL |
	                       G_LOG_LEVEL_WARNING);
	g_test_add_func("/font/legacy-playlist-default",
	                test_legacy_playlist_default);
	g_test_add_func("/font/legacy-main-window-default",
	                test_legacy_main_window_default);
	return g_test_run();
}
