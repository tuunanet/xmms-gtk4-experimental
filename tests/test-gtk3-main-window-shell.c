#include <glib.h>
#include <gtk/gtk.h>

#include "xmms/ui_gtk3_shell.h"

static void test_gtk3_shell_reports_classic_geometry(void)
{
  XmmsUiGtk3Shell *shell;

  shell = xmms_ui_gtk3_shell_new();
  g_assert_nonnull(shell);
  g_assert_cmpuint(xmms_ui_gtk3_shell_get_width(shell), ==, 275);
  g_assert_cmpuint(xmms_ui_gtk3_shell_get_height(shell), ==, 116);
  g_object_unref(shell);
}

static guint32 surface_pixel(cairo_surface_t *surface, gint x, gint y)
{
  guchar *data;
  gint stride;

  cairo_surface_flush(surface);
  data = cairo_image_surface_get_data(surface);
  stride = cairo_image_surface_get_stride(surface);
  return ((guint32 *)(data + y * stride))[x];
}

static void test_gtk3_shell_renders_fixture_pixels(void)
{
  XmmsUiGtk3Shell *shell;
  GdkPixbuf *fixture;
  cairo_surface_t *surface;
  cairo_t *cr;
  guchar *pixels;
  gint rowstride;

  shell = xmms_ui_gtk3_shell_new();
  fixture = gdk_pixbuf_new(GDK_COLORSPACE_RGB, TRUE, 8, 275, 116);
  g_assert_nonnull(shell);
  g_assert_nonnull(fixture);
  gdk_pixbuf_fill(fixture, 0x000000ff);
  pixels = gdk_pixbuf_get_pixels(fixture);
  rowstride = gdk_pixbuf_get_rowstride(fixture);
  pixels[8 * rowstride + 12 * 4] = 0;
  pixels[8 * rowstride + 12 * 4 + 1] = 255;
  pixels[8 * rowstride + 12 * 4 + 2] = 0;
  pixels[8 * rowstride + 12 * 4 + 3] = 255;

  surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 275, 116);
  cr = cairo_create(surface);
  xmms_ui_gtk3_shell_draw(shell, cr, fixture);
  g_assert_cmphex(surface_pixel(surface, 12, 8), ==, 0xff00ff00);

  cairo_destroy(cr);
  cairo_surface_destroy(surface);
  g_object_unref(fixture);
  g_object_unref(shell);
}

int main(int argc, char **argv)
{
  gtk_init(&argc, &argv);
  g_test_init(&argc, &argv, NULL);
  g_test_add_func("/gtk3-main-window-shell/classic-geometry",
                  test_gtk3_shell_reports_classic_geometry);
  g_test_add_func("/gtk3-main-window-shell/renders-fixture",
                  test_gtk3_shell_renders_fixture_pixels);
  return g_test_run();
}
