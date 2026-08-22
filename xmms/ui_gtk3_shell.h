/*  XMMS GTK4 Experimental GTK3 main-window migration tracer
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 or later.
 */
#ifndef UI_GTK3_SHELL_H
#define UI_GTK3_SHELL_H

#include <gtk/gtk.h>

#define XMMS_TYPE_UI_GTK3_SHELL (xmms_ui_gtk3_shell_get_type())
G_DECLARE_FINAL_TYPE(XmmsUiGtk3Shell, xmms_ui_gtk3_shell, XMMS, UI_GTK3_SHELL,
                     GObject)

XmmsUiGtk3Shell *xmms_ui_gtk3_shell_new(void);
void xmms_ui_gtk3_shell_draw(XmmsUiGtk3Shell *shell, cairo_t *cr,
                             GdkPixbuf *fixture);
guint xmms_ui_gtk3_shell_get_width(XmmsUiGtk3Shell *shell);
guint xmms_ui_gtk3_shell_get_height(XmmsUiGtk3Shell *shell);

#endif
