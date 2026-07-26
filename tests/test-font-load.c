#include <glib.h>
#include <gtk/gtk.h>

#include "../xmms/xmms.h"
#include "../xmms/util.h"

Config cfg;

static void assert_default_loads_byte_compatible(const gchar *name)
{
	GdkFont *font;

	cfg.use_fontsets = FALSE;
	font = util_font_load((gchar *) name);
	g_assert_nonnull(font);
	g_assert_cmpint(gdk_text_width(font, "ABC", 3), ==,
	                gdk_char_width(font, 'A') +
	                gdk_char_width(font, 'B') +
	                gdk_char_width(font, 'C'));
	gdk_font_unref(font);
}

static void test_legacy_playlist_default(void)
{
	assert_default_loads_byte_compatible(XMMS_LEGACY_PLAYLIST_FONT);
}

static void test_legacy_main_window_default(void)
{
	assert_default_loads_byte_compatible(XMMS_LEGACY_MAINWIN_FONT);
}

static void test_interim_playlist_default(void)
{
	assert_default_loads_byte_compatible(XMMS_INTERIM_PLAYLIST_FONT);
}

static void test_interim_main_window_default(void)
{
	assert_default_loads_byte_compatible(XMMS_INTERIM_MAINWIN_FONT);
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
	g_test_add_func("/font/interim-playlist-default",
	                test_interim_playlist_default);
	g_test_add_func("/font/interim-main-window-default",
	                test_interim_main_window_default);
	return g_test_run();
}
