#include <glib.h>
#include <gtk/gtk.h>

#include "xmms/ui_gtk3_control.h"

struct activation_counts {
  guint play;
  guint stop;
};

static void on_transport_activate(XmmsUiGtk3ControlAction action,
                                  gpointer user_data)
{
  struct activation_counts *counts = user_data;

  if (action == XMMS_UI_GTK3_CONTROL_PLAY)
    counts->play++;
  else if (action == XMMS_UI_GTK3_CONTROL_STOP)
    counts->stop++;
}

static GdkEvent *button_event(GdkEventType type, guint button, gdouble x,
                              gdouble y)
{
  GdkEvent *event = gdk_event_new(type);

  event->button.button = button;
  event->button.x = x;
  event->button.y = y;
  return event;
}

static void test_transport_activates_each_action_once(void)
{
  XmmsUiButtonState play_state;
  XmmsUiButtonState stop_state;
  XmmsUiButtonSprites sprites = {0, 0, 0, 0, 0, 0};
  XmmsUiGtk3Control *play;
  XmmsUiGtk3Control *stop;
  struct activation_counts counts = {0};
  GdkEvent *press;
  GdkEvent *release;
  GdkEvent *stop_press;
  GdkEvent *stop_release;

  xmms_ui_button_init(&play_state, 10, 10, 23, 18);
  xmms_ui_button_init(&stop_state, 40, 10, 23, 18);
  play = xmms_ui_gtk3_control_new(&play_state, &sprites);
  stop = xmms_ui_gtk3_control_new(&stop_state, &sprites);
  xmms_ui_gtk3_control_set_activation_handler(play, XMMS_UI_GTK3_CONTROL_PLAY,
                                              on_transport_activate, &counts);
  xmms_ui_gtk3_control_set_activation_handler(stop, XMMS_UI_GTK3_CONTROL_STOP,
                                              on_transport_activate, &counts);

  press = button_event(GDK_BUTTON_PRESS, 1, 11, 11);
  release = button_event(GDK_BUTTON_RELEASE, 1, 11, 11);
  stop_press = button_event(GDK_BUTTON_PRESS, 1, 41, 11);
  stop_release = button_event(GDK_BUTTON_RELEASE, 1, 41, 11);
  g_assert_true(xmms_ui_gtk3_control_handle_event(play, press) &
                XMMS_UI_CONTROL_REDRAW);
  g_assert_true(xmms_ui_gtk3_control_handle_event(play, release) &
                XMMS_UI_CONTROL_ACTIVATE);
  g_assert_cmpuint(counts.play, ==, 1);
  g_assert_cmpint(xmms_ui_gtk3_control_handle_event(play, release), ==,
                  XMMS_UI_CONTROL_NONE);

  g_assert_true(xmms_ui_gtk3_control_handle_event(stop, stop_press) &
                XMMS_UI_CONTROL_REDRAW);
  g_assert_true(xmms_ui_gtk3_control_handle_event(stop, stop_release) &
                XMMS_UI_CONTROL_ACTIVATE);
  g_assert_cmpuint(counts.stop, ==, 1);

  gdk_event_free(stop_release);
  gdk_event_free(stop_press);
  gdk_event_free(release);
  gdk_event_free(press);
  g_object_unref(stop);
  g_object_unref(play);
}

static void test_transport_rejects_invalid_activation(void)
{
  XmmsUiButtonState initial_state;
  XmmsUiButtonSprites sprites = {0, 0, 0, 0, 0, 0};
  XmmsUiGtk3Control *control;
  struct activation_counts counts = {0};
  GdkEvent *invalid_press;
  GdkEvent *invalid_release;
  GdkEvent *outside_press;
  GdkEvent *outside_release;

  xmms_ui_button_init(&initial_state, 10, 10, 23, 18);
  control = xmms_ui_gtk3_control_new(&initial_state, &sprites);
  xmms_ui_gtk3_control_set_activation_handler(
      control, XMMS_UI_GTK3_CONTROL_PLAY, on_transport_activate, &counts);

  invalid_press = button_event(GDK_BUTTON_PRESS, 2, 11, 11);
  invalid_release = button_event(GDK_BUTTON_RELEASE, 2, 11, 11);
  outside_press = button_event(GDK_BUTTON_PRESS, 1, 99, 99);
  outside_release = button_event(GDK_BUTTON_RELEASE, 1, 99, 99);
  g_assert_cmpint(xmms_ui_gtk3_control_handle_event(control, invalid_press), ==,
                  XMMS_UI_CONTROL_NONE);
  g_assert_cmpint(xmms_ui_gtk3_control_handle_event(control, invalid_release),
                  ==, XMMS_UI_CONTROL_NONE);
  g_assert_cmpint(xmms_ui_gtk3_control_handle_event(control, outside_press), ==,
                  XMMS_UI_CONTROL_NONE);
  g_assert_cmpint(xmms_ui_gtk3_control_handle_event(control, outside_release),
                  ==, XMMS_UI_CONTROL_NONE);
  g_assert_cmpuint(counts.play, ==, 0);
  g_assert_cmpuint(counts.stop, ==, 0);

  gdk_event_free(outside_release);
  gdk_event_free(outside_press);
  gdk_event_free(invalid_release);
  gdk_event_free(invalid_press);
  g_object_unref(control);
}

int main(int argc, char **argv)
{
  gtk_init(&argc, &argv);
  g_test_init(&argc, &argv, NULL);
  g_test_add_func("/gtk3-main-window-transport/activates-each-action-once",
                  test_transport_activates_each_action_once);
  g_test_add_func("/gtk3-main-window-transport/rejects-invalid-activation",
                  test_transport_rejects_invalid_activation);
  return g_test_run();
}
