#include <gtk/gtk.h>

#include "../xmms/util.h"

static void test_popup_uses_requested_coordinates(void)
{
	GtkItemFactory *factory;
	GtkItemFactoryEntry entry =
		{ "/Test item", NULL, NULL, 0, "<Item>" };
	GtkWidget *menu;
	gint x = -1;
	gint y = -1;

	factory = gtk_item_factory_new(GTK_TYPE_MENU, "<test-popup>", NULL);
	gtk_item_factory_create_items(factory, 1, &entry, NULL);
	menu = factory->widget;

	util_item_factory_popup(factory, 300, 250, 0, GDK_CURRENT_TIME);
	while (gtk_events_pending())
		gtk_main_iteration();

	g_assert_true(GTK_WIDGET_MAPPED(menu));
	gdk_window_get_origin(menu->window, &x, &y);
	g_test_message("popup origin: %d,%d", x, y);
	g_assert_cmpint(x, ==, 298);
	g_assert_cmpint(y, ==, 248);

	gtk_menu_popdown(GTK_MENU(menu));
	g_object_unref(factory);
}

int main(int argc, char **argv)
{
	gtk_init(&argc, &argv);
	g_test_init(&argc, &argv, NULL);
	g_test_add_func("/popup-position/uses-requested-coordinates",
			test_popup_uses_requested_coordinates);

	return g_test_run();
}
