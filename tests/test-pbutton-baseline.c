#include <glib.h>
#include <gtk/gtk.h>

#include "xmms/xmms.h"

typedef struct
{
	guint calls;
	GdkDrawable *drawable;
	GdkGC *gc;
	SkinIndex skin_index;
	gint source_x;
	gint source_y;
	gint destination_x;
	gint destination_y;
	gint width;
	gint height;
} DrawCapture;

static DrawCapture draw_capture;
static guint activation_count;

void skin_draw_pixmap(GdkDrawable *drawable, GdkGC *gc, SkinIndex skin_index,
		      gint source_x, gint source_y, gint destination_x,
		      gint destination_y, gint width, gint height)
{
	draw_capture.calls++;
	draw_capture.drawable = drawable;
	draw_capture.gc = gc;
	draw_capture.skin_index = skin_index;
	draw_capture.source_x = source_x;
	draw_capture.source_y = source_y;
	draw_capture.destination_x = destination_x;
	draw_capture.destination_y = destination_y;
	draw_capture.width = width;
	draw_capture.height = height;
}

static void play_activated(void)
{
	activation_count++;
}

static PButton *create_play_button(GList **widgets)
{
	return create_pbutton(widgets, NULL, NULL,
			      39, 88, 23, 18,
			      23, 0, 23, 18,
			      play_activated, SKIN_CBUTTONS);
}

static void destroy_play_button(GList *widgets, PButton *button)
{
	pthread_mutex_destroy(&button->pb_widget.mutex);
	g_list_free(widgets);
	free_pbutton(button);
}

static void reset_capture(void)
{
	memset(&draw_capture, 0, sizeof(draw_capture));
	activation_count = 0;
}

static void assert_draw(gint source_y)
{
	g_assert_cmpuint(draw_capture.calls, ==, 1);
	g_assert_cmpint(draw_capture.skin_index, ==, SKIN_CBUTTONS);
	g_assert_cmpint(draw_capture.source_x, ==, 23);
	g_assert_cmpint(draw_capture.source_y, ==, source_y);
	g_assert_cmpint(draw_capture.destination_x, ==, 39);
	g_assert_cmpint(draw_capture.destination_y, ==, 88);
	g_assert_cmpint(draw_capture.width, ==, 23);
	g_assert_cmpint(draw_capture.height, ==, 18);
}

static void test_pbutton_draws_normal_and_pressed_sprites(void)
{
	GList *widgets = NULL;
	PButton *button;

	reset_capture();
	button = create_play_button(&widgets);

	button->pb_widget.draw((Widget *) button);
	assert_draw(0);

	memset(&draw_capture, 0, sizeof(draw_capture));
	button->pb_pressed = TRUE;
	button->pb_inside = TRUE;
	button->pb_widget.draw((Widget *) button);
	assert_draw(18);

	destroy_play_button(widgets, button);
}

static void test_pbutton_hit_boundaries(void)
{
	GList *widgets = NULL;
	PButton *button;

	button = create_play_button(&widgets);

	g_assert_true(inside_widget(39, 88, button));
	g_assert_true(inside_widget(61, 105, button));
	g_assert_false(inside_widget(38, 88, button));
	g_assert_false(inside_widget(39, 87, button));
	g_assert_false(inside_widget(62, 88, button));
	g_assert_false(inside_widget(39, 106, button));

	button->pb_widget.visible = FALSE;
	g_assert_false(inside_widget(39, 88, button));

	destroy_play_button(widgets, button);
}

static void dispatch_press(PButton *button, guint mouse_button, gdouble x,
			   gdouble y)
{
	GdkEventButton event;

	memset(&event, 0, sizeof(event));
	event.button = mouse_button;
	event.x = x;
	event.y = y;
	button->pb_widget.button_press_cb(NULL, &event, button);
}

static void dispatch_release(PButton *button, guint mouse_button, gdouble x,
			     gdouble y)
{
	GdkEventButton event;

	memset(&event, 0, sizeof(event));
	event.button = mouse_button;
	event.x = x;
	event.y = y;
	button->pb_widget.button_release_cb(NULL, &event, button);
}

static void dispatch_motion(PButton *button, gdouble x, gdouble y)
{
	GdkEventMotion event;

	memset(&event, 0, sizeof(event));
	event.x = x;
	event.y = y;
	button->pb_widget.motion_cb(NULL, &event, button);
}

static void test_pbutton_tracks_pointer_and_activates_once(void)
{
	GList *widgets = NULL;
	PButton *button;

	reset_capture();
	button = create_play_button(&widgets);

	dispatch_press(button, 1, 40, 89);
	g_assert_true(button->pb_pressed);
	g_assert_true(button->pb_inside);

	dispatch_motion(button, 62, 89);
	g_assert_false(button->pb_inside);
	dispatch_motion(button, 40, 89);
	g_assert_true(button->pb_inside);

	dispatch_release(button, 1, 40, 89);
	g_assert_false(button->pb_pressed);
	g_assert_false(button->pb_inside);
	g_assert_cmpuint(activation_count, ==, 1);

	dispatch_release(button, 1, 40, 89);
	g_assert_cmpuint(activation_count, ==, 1);

	destroy_play_button(widgets, button);
}

static void test_pbutton_rejects_invalid_activation(void)
{
	GList *widgets = NULL;
	PButton *button;

	reset_capture();
	button = create_play_button(&widgets);

	dispatch_press(button, 2, 40, 89);
	dispatch_release(button, 2, 40, 89);
	g_assert_false(button->pb_pressed);
	g_assert_cmpuint(activation_count, ==, 0);

	dispatch_press(button, 1, 38, 89);
	dispatch_release(button, 1, 38, 89);
	g_assert_false(button->pb_pressed);
	g_assert_cmpuint(activation_count, ==, 0);

	dispatch_press(button, 1, 40, 89);
	dispatch_motion(button, 62, 89);
	dispatch_release(button, 1, 62, 89);
	g_assert_false(button->pb_pressed);
	g_assert_cmpuint(activation_count, ==, 0);

	destroy_play_button(widgets, button);
}

int main(int argc, char **argv)
{
	g_test_init(&argc, &argv, NULL);
	g_test_add_func("/pbutton/draw-sprites",
			test_pbutton_draws_normal_and_pressed_sprites);
	g_test_add_func("/pbutton/hit-boundaries", test_pbutton_hit_boundaries);
	g_test_add_func("/pbutton/pointer-activation",
			test_pbutton_tracks_pointer_and_activates_once);
	g_test_add_func("/pbutton/invalid-activation",
			test_pbutton_rejects_invalid_activation);
	return g_test_run();
}
