/*  XMMS GTK4 Experimental GTK3 migration proof adapter
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 */
#ifndef UI_GTK3_CONTROL_H
#define UI_GTK3_CONTROL_H

#include <gtk/gtk.h>

#include "ui_control.h"

void xmms_ui_gtk3_draw_command(cairo_t *cr, GdkPixbuf *sprites,
			       const XmmsUiDrawCommand *command);
XmmsUiControlResult xmms_ui_gtk3_handle_event(XmmsUiButtonState *state,
					     const GdkEvent *event);

#endif
