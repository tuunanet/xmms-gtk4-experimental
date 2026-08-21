/*  XMMS GTK4 Experimental GTK3 migration proof adapter
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 */
#include "ui_gtk3_control.h"

struct _XmmsUiGtk3Control {
  GObject parent_instance;
  XmmsUiButtonState state;
  XmmsUiButtonSprites sprite_map;
};

G_DEFINE_TYPE(XmmsUiGtk3Control, xmms_ui_gtk3_control, G_TYPE_OBJECT)

static void xmms_ui_gtk3_control_class_init(XmmsUiGtk3ControlClass *klass)
{
  (void)klass;
}

static void xmms_ui_gtk3_control_init(XmmsUiGtk3Control *control)
{
  (void)control;
}

XmmsUiGtk3Control *
xmms_ui_gtk3_control_new(const XmmsUiButtonState *initial_state,
                         const XmmsUiButtonSprites *sprites)
{
  XmmsUiGtk3Control *control;

  g_return_val_if_fail(initial_state != NULL, NULL);
  g_return_val_if_fail(sprites != NULL, NULL);

  control = g_object_new(XMMS_TYPE_UI_GTK3_CONTROL, NULL);
  control->state = *initial_state;
  control->sprite_map = *sprites;
  return control;
}

void xmms_ui_gtk3_control_draw(XmmsUiGtk3Control *control, cairo_t *cr,
                               GdkPixbuf *sprites)
{
  XmmsUiDrawCommand command;

  g_return_if_fail(XMMS_IS_UI_GTK3_CONTROL(control));
  g_return_if_fail(cr != NULL);
  g_return_if_fail(sprites != NULL);

  xmms_ui_button_get_draw_command(&control->state, &control->sprite_map,
                                  &command);
  cairo_save(cr);
  cairo_rectangle(cr, command.destination_x, command.destination_y,
                  command.width, command.height);
  cairo_clip(cr);
  gdk_cairo_set_source_pixbuf(cr, sprites,
                              command.destination_x - command.source_x,
                              command.destination_y - command.source_y);
  cairo_paint(cr);
  cairo_restore(cr);
}

XmmsUiControlResult
xmms_ui_gtk3_control_handle_event(XmmsUiGtk3Control *control,
                                  const GdkEvent *event)
{
  g_return_val_if_fail(XMMS_IS_UI_GTK3_CONTROL(control), XMMS_UI_CONTROL_NONE);
  g_return_val_if_fail(event != NULL, XMMS_UI_CONTROL_NONE);

  switch (event->type) {
  case GDK_BUTTON_PRESS:
    return xmms_ui_button_handle_pointer(&control->state, XMMS_UI_POINTER_PRESS,
                                         event->button.button, event->button.x,
                                         event->button.y);
  case GDK_BUTTON_RELEASE:
    return xmms_ui_button_handle_pointer(
        &control->state, XMMS_UI_POINTER_RELEASE, event->button.button,
        event->button.x, event->button.y);
  case GDK_MOTION_NOTIFY:
    return xmms_ui_button_handle_pointer(&control->state,
                                         XMMS_UI_POINTER_MOTION, 0,
                                         event->motion.x, event->motion.y);
  default:
    return XMMS_UI_CONTROL_NONE;
  }
}
