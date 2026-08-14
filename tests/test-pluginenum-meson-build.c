#include <glib.h>

#include "../libxmms/util.h"
#include "../xmms/xmms.h"

Config cfg;
GList *disabled_iplugins;
struct InputPluginData *ip_data;
struct OutputPluginData *op_data;
struct EffectPluginData *ep_data;
struct GeneralPluginData *gp_data;
struct VisPluginData *vp_data;

void general_enable_from_stringified_list(gchar *list)
{
}

void vis_enable_from_stringified_list(gchar *list)
{
}

void effect_enable_from_stringified_list(gchar *list)
{
}

gint ctrlsocket_get_session_id(void)
{
	return 0;
}

InputVisType input_get_vis_type(void)
{
	return INPUT_VIS_OFF;
}

void input_add_vis_pcm(int time, AFormat fmt, int nch, int length, void *ptr)
{
}

void playlist_set_info(gchar *title, gint length, gint rate, gint freq, gint nch)
{
}

void input_set_info_text(gchar *text)
{
}

void vis_disable_plugin(VisPlugin *plugin)
{
}

gboolean get_input_playing(void)
{
	return FALSE;
}

void input_stop(void)
{
}

GList *get_general_enabled_list(void)
{
	return NULL;
}

void enable_general_plugin(int index, gboolean enabled)
{
}

GList *get_vis_enabled_list(void)
{
	return NULL;
}

void enable_vis_plugin(int index, gboolean enabled)
{
}

EffectPlugin *get_current_effect_plugin(void)
{
	return NULL;
}

int effects_enabled(void)
{
	return FALSE;
}

gchar *xmms_get_gentitle_format(void)
{
	return "%p";
}

static gint input_filename_compare(gconstpointer element, gconstpointer filename)
{
	return g_strcmp0(((const InputPlugin *)element)->filename, filename);
}

static gint output_filename_compare(gconstpointer element, gconstpointer filename)
{
	return g_strcmp0(((const OutputPlugin *)element)->filename, filename);
}

static void test_loads_actual_meson_build_tree_plugins(void)
{
	gchar *input_path;
	gchar *output_path;
	GList *input_node;
	GList *output_node;

	input_path = g_build_filename(BUILD_PLUGIN_DIR, "Input", "mpg123",
				      "libmpg123.so", NULL);
	output_path = g_build_filename(BUILD_PLUGIN_DIR, "Output", "alsa",
				       "libALSA.so", NULL);
	cfg.outputplugin = g_strdup("libALSA.so");
	xmms_usleep(0);

	init_plugins();

	input_node = g_list_find_custom(ip_data->input_list, input_path,
					input_filename_compare);
	output_node = g_list_find_custom(op_data->output_list, output_path,
					 output_filename_compare);
	g_assert_nonnull(input_node);
	g_assert_nonnull(output_node);
	g_assert_nonnull(op_data->current_output_plugin);
	g_assert_cmpstr(op_data->current_output_plugin->filename, ==, output_path);

	g_free(input_path);
	g_free(output_path);
}

int main(int argc, char **argv)
{
	g_test_init(&argc, &argv, NULL);
	g_test_add_func("/pluginenum/loads-actual-meson-build-tree-plugins",
			test_loads_actual_meson_build_tree_plugins);

	return g_test_run();
}
