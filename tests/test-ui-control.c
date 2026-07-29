#include <glib.h>

#include "xmms/ui_control.h"

static void test_primary_press_inside_requests_redraw(void)
{
	XmmsUiButtonState state;
	XmmsUiControlResult result;

	xmms_ui_button_init(&state, 39, 88, 23, 18);
	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_PRESS,
					       1, 39, 88);

	g_assert_true(state.pressed);
	g_assert_true(state.inside);
	g_assert_cmpint(result, ==, XMMS_UI_CONTROL_REDRAW);
}

static void test_pressed_pointer_tracks_leave_and_reentry(void)
{
	XmmsUiButtonState state;
	XmmsUiControlResult result;

	xmms_ui_button_init(&state, 39, 88, 23, 18);
	xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_PRESS, 1, 40, 89);

	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_MOTION,
					       0, 62, 89);
	g_assert_true(state.pressed);
	g_assert_false(state.inside);
	g_assert_cmpint(result, ==, XMMS_UI_CONTROL_REDRAW);

	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_MOTION,
					       0, 40, 89);
	g_assert_true(state.inside);
	g_assert_cmpint(result, ==, XMMS_UI_CONTROL_REDRAW);

	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_MOTION,
					       0, 41, 90);
	g_assert_cmpint(result, ==, XMMS_UI_CONTROL_NONE);
}

static void test_primary_release_inside_activates_once(void)
{
	XmmsUiButtonState state;
	XmmsUiControlResult result;

	xmms_ui_button_init(&state, 39, 88, 23, 18);
	xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_PRESS, 1, 40, 89);

	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_RELEASE,
					       1, 40, 89);
	g_assert_false(state.pressed);
	g_assert_false(state.inside);
	g_assert_true((result & XMMS_UI_CONTROL_REDRAW) != 0);
	g_assert_true((result & XMMS_UI_CONTROL_ACTIVATE) != 0);

	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_RELEASE,
					       1, 40, 89);
	g_assert_cmpint(result, ==, XMMS_UI_CONTROL_NONE);
}

static void test_draw_command_selects_normal_and_pressed_sprites(void)
{
	XmmsUiButtonState state;
	XmmsUiButtonSprites sprites = { 2, 23, 0, 2, 23, 18 };
	XmmsUiDrawCommand command;

	xmms_ui_button_init(&state, 39, 88, 23, 18);
	xmms_ui_button_get_draw_command(&state, &sprites, &command);
	g_assert_cmpint(command.sprite_id, ==, 2);
	g_assert_cmpint(command.source_x, ==, 23);
	g_assert_cmpint(command.source_y, ==, 0);
	g_assert_cmpint(command.destination_x, ==, 39);
	g_assert_cmpint(command.destination_y, ==, 88);
	g_assert_cmpint(command.width, ==, 23);
	g_assert_cmpint(command.height, ==, 18);

	xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_PRESS, 1, 40, 89);
	xmms_ui_button_get_draw_command(&state, &sprites, &command);
	g_assert_cmpint(command.sprite_id, ==, 2);
	g_assert_cmpint(command.source_x, ==, 23);
	g_assert_cmpint(command.source_y, ==, 18);
}

int main(int argc, char **argv)
{
	g_test_init(&argc, &argv, NULL);
	g_test_add_func("/ui-control/primary-press-inside",
			test_primary_press_inside_requests_redraw);
	g_test_add_func("/ui-control/pointer-leave-reentry",
			test_pressed_pointer_tracks_leave_and_reentry);
	g_test_add_func("/ui-control/primary-release-activation",
			test_primary_release_inside_activates_once);
	g_test_add_func("/ui-control/draw-command",
			test_draw_command_selects_normal_and_pressed_sprites);
	return g_test_run();
}
