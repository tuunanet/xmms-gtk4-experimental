#include <glib.h>

#include "../xmms/outputplugin.h"

static void test_finds_alsa_from_actual_meson_build_tree(void)
{
	gchar *expected;
	gchar *actual;

	expected = g_build_filename(BUILD_PLUGIN_DIR, "Output", "alsa",
				  "libALSA.so", NULL);
	actual = output_plugin_find_alsa("Output");

	g_assert_cmpstr(actual, ==, expected);
	g_free(actual);
	g_free(expected);
}

int main(int argc, char **argv)
{
	g_test_init(&argc, &argv, NULL);
	g_test_add_func("/outputplugin/finds-alsa-from-actual-meson-build-tree",
			test_finds_alsa_from_actual_meson_build_tree);

	return g_test_run();
}
