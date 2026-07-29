#include <glib.h>
#include <gtk/gtk.h>

#include "xmms/ui_control.h"
#include "xmms/ui_gtk3_control.h"

static void set_sprite_color(GdkPixbuf *sprites, gint x, gint y,
			     gint width, gint height,
			     guchar red, guchar green, guchar blue)
{
	guchar *pixels = gdk_pixbuf_get_pixels(sprites);
	gint rowstride = gdk_pixbuf_get_rowstride(sprites);
	gint channels = gdk_pixbuf_get_n_channels(sprites);
	gint row;
	gint column;

	for (row = y; row < y + height; row++)
	{
		for (column = x; column < x + width; column++)
		{
			guchar *pixel = pixels + row * rowstride + column * channels;

			pixel[0] = red;
			pixel[1] = green;
			pixel[2] = blue;
			if (channels == 4)
				pixel[3] = 255;
		}
	}
}

static guint32 surface_pixel(cairo_surface_t *surface, gint x, gint y)
{
	guchar *data;
	gint stride;

	cairo_surface_flush(surface);
	data = cairo_image_surface_get_data(surface);
	stride = cairo_image_surface_get_stride(surface);
	return ((guint32 *) (data + y * stride))[x];
}

static guint activation_count;

static void apply_control_result(XmmsUiControlResult result)
{
	if (result & XMMS_UI_CONTROL_ACTIVATE)
		activation_count++;
}

static void test_gtk3_renders_shared_play_button_commands(void)
{
	XmmsUiButtonState state;
	XmmsUiButtonSprites sprite_map = { 0, 23, 0, 0, 23, 18 };
	XmmsUiDrawCommand command;
	GdkPixbuf *sprites;
	cairo_surface_t *surface;
	cairo_t *cr;

	sprites = gdk_pixbuf_new(GDK_COLORSPACE_RGB, TRUE, 8, 46, 36);
	g_assert_nonnull(sprites);
	gdk_pixbuf_fill(sprites, 0x000000ff);
	set_sprite_color(sprites, 23, 0, 23, 18, 255, 0, 0);
	set_sprite_color(sprites, 23, 18, 23, 18, 0, 0, 255);

	surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 80, 120);
	g_assert_cmpint(cairo_surface_status(surface), ==, CAIRO_STATUS_SUCCESS);
	cr = cairo_create(surface);

	xmms_ui_button_init(&state, 39, 88, 23, 18);
	xmms_ui_button_get_draw_command(&state, &sprite_map, &command);
	xmms_ui_gtk3_draw_command(cr, sprites, &command);
	g_assert_cmphex(surface_pixel(surface, 40, 89), ==, 0xffff0000);

	xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_PRESS, 1, 40, 89);
	xmms_ui_button_get_draw_command(&state, &sprite_map, &command);
	xmms_ui_gtk3_draw_command(cr, sprites, &command);
	g_assert_cmphex(surface_pixel(surface, 40, 89), ==, 0xff0000ff);

	cairo_destroy(cr);
	cairo_surface_destroy(surface);
	g_object_unref(sprites);
}

static void test_gtk3_activates_shared_play_button_once(void)
{
	XmmsUiButtonState state;
	GdkEvent *press;
	GdkEvent *release;

	xmms_ui_button_init(&state, 39, 88, 23, 18);
	activation_count = 0;

	press = gdk_event_new(GDK_BUTTON_PRESS);
	press->button.button = 1;
	press->button.x = 40;
	press->button.y = 89;
	apply_control_result(xmms_ui_gtk3_handle_event(&state, press));
	g_assert_true(state.pressed);

	release = gdk_event_new(GDK_BUTTON_RELEASE);
	release->button.button = 1;
	release->button.x = 40;
	release->button.y = 89;
	apply_control_result(xmms_ui_gtk3_handle_event(&state, release));
	g_assert_cmpuint(activation_count, ==, 1);
	g_assert_false(state.pressed);

	apply_control_result(xmms_ui_gtk3_handle_event(&state, release));
	g_assert_cmpuint(activation_count, ==, 1);

	gdk_event_free(press);
	gdk_event_free(release);
}

int main(int argc, char **argv)
{
	gtk_init(&argc, &argv);
	g_test_init(&argc, &argv, NULL);
	g_test_add_func("/gtk3-proof/render-play-button",
			test_gtk3_renders_shared_play_button_commands);
	g_test_add_func("/gtk3-proof/activate-play-button",
			test_gtk3_activates_shared_play_button_once);
	return g_test_run();
}
