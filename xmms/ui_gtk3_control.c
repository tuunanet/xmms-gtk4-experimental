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
  XmmsUiGtk3ControlAction action;
  XmmsUiGtk3ControlActivateFunc activate;
  gpointer activate_data;
};

G_DEFINE_TYPE(XmmsUiGtk3Control, xmms_ui_gtk3_control, G_TYPE_OBJECT)

static void xmms_ui_gtk3_control_class_init(XmmsUiGtk3ControlClass *klass)
{
  (void)klass;
}

static void xmms_ui_gtk3_control_init(XmmsUiGtk3Control *control)
{
  control->action = XMMS_UI_GTK3_CONTROL_PLAY;
  control->activate = NULL;
  control->activate_data = NULL;
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

void xmms_ui_gtk3_control_set_activation_handler(
    XmmsUiGtk3Control *control, XmmsUiGtk3ControlAction action,
    XmmsUiGtk3ControlActivateFunc callback, gpointer user_data)
{
  g_return_if_fail(XMMS_IS_UI_GTK3_CONTROL(control));
  g_return_if_fail(action == XMMS_UI_GTK3_CONTROL_PLAY ||
                   action == XMMS_UI_GTK3_CONTROL_STOP);

  control->action = action;
  control->activate = callback;
  control->activate_data = user_data;
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
  XmmsUiControlResult result;

  g_return_val_if_fail(XMMS_IS_UI_GTK3_CONTROL(control), XMMS_UI_CONTROL_NONE);
  g_return_val_if_fail(event != NULL, XMMS_UI_CONTROL_NONE);

  switch (event->type) {
  case GDK_BUTTON_PRESS:
    result = xmms_ui_button_handle_pointer(
        &control->state, XMMS_UI_POINTER_PRESS, event->button.button,
        event->button.x, event->button.y);
    break;
  case GDK_BUTTON_RELEASE:
    result = xmms_ui_button_handle_pointer(
        &control->state, XMMS_UI_POINTER_RELEASE, event->button.button,
        event->button.x, event->button.y);
    break;
  case GDK_MOTION_NOTIFY:
    result =
        xmms_ui_button_handle_pointer(&control->state, XMMS_UI_POINTER_MOTION,
                                      0, event->motion.x, event->motion.y);
    break;
  default:
    result = XMMS_UI_CONTROL_NONE;
    break;
  }

  if ((result & XMMS_UI_CONTROL_ACTIVATE) && control->activate != NULL)
    control->activate(control->action, control->activate_data);

  return result;
}
