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

#define XMMS_TYPE_UI_GTK3_CONTROL (xmms_ui_gtk3_control_get_type ())
G_DECLARE_FINAL_TYPE(XmmsUiGtk3Control, xmms_ui_gtk3_control,
	XMMS, UI_GTK3_CONTROL, GObject)

XmmsUiGtk3Control *xmms_ui_gtk3_control_new(
	const XmmsUiButtonState *initial_state,
	const XmmsUiButtonSprites *sprites);
void xmms_ui_gtk3_control_draw(XmmsUiGtk3Control *control, cairo_t *cr,
	GdkPixbuf *sprites);
XmmsUiControlResult xmms_ui_gtk3_control_handle_event(
	XmmsUiGtk3Control *control, const GdkEvent *event);

#endif
