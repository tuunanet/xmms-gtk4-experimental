/* Compatibility shim for XMMS's pre-GLib-2.32 thread initialization call.
 * Modern GLib initializes threads unconditionally and no longer exports this
 * legacy symbol. Keep the historical caller unchanged during build migration.
 */
#include <glib.h>

void g_thread_init(gpointer vtable)
{
	(void) vtable;
}
