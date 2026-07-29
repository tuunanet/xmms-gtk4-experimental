/*  XMMS GTK4 Experimental GTK3 migration proof adapter
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 */
#include "ui_gtk3_control.h"

void xmms_ui_gtk3_draw_command(cairo_t *cr, GdkPixbuf *sprites,
			       const XmmsUiDrawCommand *command)
{
	cairo_save(cr);
	cairo_rectangle(cr, command->destination_x, command->destination_y,
			command->width, command->height);
	cairo_clip(cr);
	gdk_cairo_set_source_pixbuf(cr, sprites,
		command->destination_x - command->source_x,
		command->destination_y - command->source_y);
	cairo_paint(cr);
	cairo_restore(cr);
}
