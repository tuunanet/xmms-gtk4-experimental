/*  XMMS GTK4 Experimental GTK3 main-window migration tracer
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 or later.
 */
#include "ui_gtk3_shell.h"

static const guint xmms_ui_gtk3_shell_classic_width = 275;
static const guint xmms_ui_gtk3_shell_classic_height = 116;

struct _XmmsUiGtk3Shell {
  GObject parent_instance;
  guint width;
  guint height;
};

G_DEFINE_TYPE(XmmsUiGtk3Shell, xmms_ui_gtk3_shell, G_TYPE_OBJECT)

static void xmms_ui_gtk3_shell_class_init(XmmsUiGtk3ShellClass *klass)
{
  (void)klass;
}

static void xmms_ui_gtk3_shell_init(XmmsUiGtk3Shell *shell)
{
  shell->width = xmms_ui_gtk3_shell_classic_width;
  shell->height = xmms_ui_gtk3_shell_classic_height;
}

XmmsUiGtk3Shell *xmms_ui_gtk3_shell_new(void)
{
  return g_object_new(XMMS_TYPE_UI_GTK3_SHELL, NULL);
}

void xmms_ui_gtk3_shell_draw(XmmsUiGtk3Shell *shell, cairo_t *cr,
                             GdkPixbuf *fixture)
{
  g_return_if_fail(XMMS_IS_UI_GTK3_SHELL(shell));
  g_return_if_fail(cr != NULL);
  g_return_if_fail(fixture != NULL);
  g_return_if_fail(gdk_pixbuf_get_width(fixture) >= (gint)shell->width);
  g_return_if_fail(gdk_pixbuf_get_height(fixture) >= (gint)shell->height);

  cairo_save(cr);
  cairo_rectangle(cr, 0, 0, shell->width, shell->height);
  cairo_clip(cr);
  gdk_cairo_set_source_pixbuf(cr, fixture, 0, 0);
  cairo_paint(cr);
  cairo_restore(cr);
}

guint xmms_ui_gtk3_shell_get_width(XmmsUiGtk3Shell *shell)
{
  g_return_val_if_fail(XMMS_IS_UI_GTK3_SHELL(shell), 0);
  return shell->width;
}

guint xmms_ui_gtk3_shell_get_height(XmmsUiGtk3Shell *shell)
{
  g_return_val_if_fail(XMMS_IS_UI_GTK3_SHELL(shell), 0);
  return shell->height;
}
