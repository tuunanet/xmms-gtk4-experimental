/*  XMMS GTK4 Experimental toolkit-neutral UI control state
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 */
#include "ui_control.h"

static gboolean xmms_ui_button_contains(const XmmsUiButtonState *state,
					gint x, gint y)
{
	return state->visible &&
		x >= state->x && x < state->x + state->width &&
		y >= state->y && y < state->y + state->height;
}

void xmms_ui_button_init(XmmsUiButtonState *state, gint x, gint y,
			 gint width, gint height)
{
	state->x = x;
	state->y = y;
	state->width = width;
	state->height = height;
	state->visible = TRUE;
	state->pressed = FALSE;
	state->inside = FALSE;
}

XmmsUiControlResult xmms_ui_button_handle_pointer(XmmsUiButtonState *state,
						 XmmsUiPointerEvent event,
						 guint button, gint x, gint y)
{
	if (event == XMMS_UI_POINTER_MOTION)
	{
		gboolean inside;

		if (!state->pressed)
			return XMMS_UI_CONTROL_NONE;

		inside = xmms_ui_button_contains(state, x, y);
		if (inside == state->inside)
			return XMMS_UI_CONTROL_NONE;

		state->inside = inside;
		return XMMS_UI_CONTROL_REDRAW;
	}

	if (event == XMMS_UI_POINTER_RELEASE)
	{
		XmmsUiControlResult result = XMMS_UI_CONTROL_NONE;

		if (button != 1)
			return result;

		if (state->inside && state->pressed)
		{
			state->inside = FALSE;
			result = XMMS_UI_CONTROL_REDRAW |
				 XMMS_UI_CONTROL_ACTIVATE;
		}
		state->pressed = FALSE;
		return result;
	}

	if (event != XMMS_UI_POINTER_PRESS || button != 1)
		return XMMS_UI_CONTROL_NONE;

	if (!xmms_ui_button_contains(state, x, y))
		return XMMS_UI_CONTROL_NONE;

	state->pressed = TRUE;
	state->inside = TRUE;
	return XMMS_UI_CONTROL_REDRAW;
}
