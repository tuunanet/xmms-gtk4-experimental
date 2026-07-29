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

int main(int argc, char **argv)
{
	g_test_init(&argc, &argv, NULL);
	g_test_add_func("/ui-control/primary-press-inside",
			test_primary_press_inside_requests_redraw);
	g_test_add_func("/ui-control/pointer-leave-reentry",
			test_pressed_pointer_tracks_leave_and_reentry);
	return g_test_run();
}
