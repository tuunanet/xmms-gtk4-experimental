/*  XMMS GTK4 Experimental toolkit-neutral UI control state
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 */
#ifndef UI_CONTROL_H
#define UI_CONTROL_H

#include <glib.h>

typedef enum
{
	XMMS_UI_POINTER_PRESS,
	XMMS_UI_POINTER_MOTION,
	XMMS_UI_POINTER_RELEASE
} XmmsUiPointerEvent;

typedef enum
{
	XMMS_UI_CONTROL_NONE = 0,
	XMMS_UI_CONTROL_REDRAW = 1 << 0,
	XMMS_UI_CONTROL_ACTIVATE = 1 << 1
} XmmsUiControlResult;

typedef struct
{
	gint x;
	gint y;
	gint width;
	gint height;
	gboolean visible;
	gboolean pressed;
	gboolean inside;
} XmmsUiButtonState;

typedef struct
{
	gint sprite_id;
	gint source_x;
	gint source_y;
	gint destination_x;
	gint destination_y;
	gint width;
	gint height;
} XmmsUiDrawCommand;

void xmms_ui_button_init(XmmsUiButtonState *state, gint x, gint y,
			 gint width, gint height);
XmmsUiControlResult xmms_ui_button_handle_pointer(XmmsUiButtonState *state,
						 XmmsUiPointerEvent event,
						 guint button, gint x, gint y);

#endif
