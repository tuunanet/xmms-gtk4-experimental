/*  XMMS - Cross-platform multimedia player
 *  Copyright (C) 1998-2000  Peter Alm, Mikael Alm, Olle Hallnas, Thomas Nilsson and 4Front Technologies
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */
#include "xmms.h"
#include "ui_control.h"

static void pbutton_get_control_state(const PButton *button,
				      XmmsUiButtonState *state)
{
	xmms_ui_button_init(state, button->pb_widget.x, button->pb_widget.y,
			    button->pb_widget.width, button->pb_widget.height);
	state->visible = button->pb_widget.visible;
	state->pressed = button->pb_pressed;
	state->inside = button->pb_inside;
}

static void pbutton_apply_control_result(PButton *button,
					 const XmmsUiButtonState *state,
					 XmmsUiControlResult result)
{
	button->pb_pressed = state->pressed;
	button->pb_inside = state->inside;

	if (result & XMMS_UI_CONTROL_REDRAW)
		draw_widget(button);
	if ((result & XMMS_UI_CONTROL_ACTIVATE) && button->pb_push_cb)
		button->pb_push_cb();
}

void pbutton_draw(Widget * w)
{
	PButton *button = (PButton *) w;
	XmmsUiButtonState state;
	XmmsUiButtonSprites sprites;
	XmmsUiDrawCommand command;

	if (!button->pb_allow_draw)
		return;

	pbutton_get_control_state(button, &state);
	sprites.normal_sprite_id = button->pb_skin_index1;
	sprites.normal_x = button->pb_nx;
	sprites.normal_y = button->pb_ny;
	sprites.pressed_sprite_id = button->pb_skin_index2;
	sprites.pressed_x = button->pb_px;
	sprites.pressed_y = button->pb_py;
	xmms_ui_button_get_draw_command(&state, &sprites, &command);

	skin_draw_pixmap(button->pb_widget.parent, button->pb_widget.gc,
			 (SkinIndex) command.sprite_id,
			 command.source_x, command.source_y,
			 command.destination_x, command.destination_y,
			 command.width, command.height);
}

void pbutton_button_press_cb(GtkWidget * widget, GdkEventButton * event, gpointer data)
{
	PButton *button = data;
	XmmsUiButtonState state;
	XmmsUiControlResult result;

	pbutton_get_control_state(button, &state);
	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_PRESS,
					       event->button, event->x, event->y);
	pbutton_apply_control_result(button, &state, result);
}

void pbutton_button_release_cb(GtkWidget * widget, GdkEventButton * event, gpointer data)
{
	PButton *button = data;
	XmmsUiButtonState state;
	XmmsUiControlResult result;

	pbutton_get_control_state(button, &state);
	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_RELEASE,
					       event->button, event->x, event->y);
	pbutton_apply_control_result(button, &state, result);
}

void pbutton_motion_cb(GtkWidget * widget, GdkEventMotion * event, gpointer data)
{
	PButton *button = data;
	XmmsUiButtonState state;
	XmmsUiControlResult result;

	pbutton_get_control_state(button, &state);
	result = xmms_ui_button_handle_pointer(&state, XMMS_UI_POINTER_MOTION,
					       0, event->x, event->y);
	pbutton_apply_control_result(button, &state, result);
}

void pbutton_set_skin_index(PButton *b, SkinIndex si)
{
	b->pb_skin_index1 = b->pb_skin_index2 = si;
}

void pbutton_set_skin_index1(PButton *b, SkinIndex si)
{
	b->pb_skin_index1 = si;
}

void pbutton_set_skin_index2(PButton *b, SkinIndex si)
{
	b->pb_skin_index2 = si;
}

void pbutton_set_button_data(PButton *b, gint nx, gint ny, gint px, gint py)
{
	if(nx>-1)
		b->pb_nx = nx;
	if(ny>-1)
		b->pb_ny = ny;
	if(px>-1)
		b->pb_px = px;
	if(py>-1)
		b->pb_py = py;
}
	

PButton *create_pbutton_ex(GList ** wlist, GdkPixmap * parent, GdkGC * gc, gint x, gint y, gint w, gint h, gint nx, gint ny, gint px, gint py, void (*cb) (void), SkinIndex si1, SkinIndex si2)
{
	PButton *b;

	b = (PButton *) g_malloc0(sizeof (PButton));
	b->pb_widget.parent = parent;
	b->pb_widget.gc = gc;
	b->pb_widget.x = x;
	b->pb_widget.y = y;
	b->pb_widget.width = w;
	b->pb_widget.height = h;
	b->pb_widget.visible = 1;
	b->pb_widget.button_press_cb = pbutton_button_press_cb;
	b->pb_widget.button_release_cb = pbutton_button_release_cb;
	b->pb_widget.motion_cb = pbutton_motion_cb;
	b->pb_widget.draw = pbutton_draw;
	b->pb_nx = nx;
	b->pb_ny = ny;
	b->pb_px = px;
	b->pb_py = py;
	b->pb_push_cb = cb;
	b->pb_skin_index1 = si1;
	b->pb_skin_index2 = si2;
	b->pb_allow_draw = TRUE;
	add_widget(wlist, b);
	return b;
}

PButton *create_pbutton(GList ** wlist, GdkPixmap * parent, GdkGC * gc, gint x, gint y, gint w, gint h, gint nx, gint ny, gint px, gint py, void (*cb) (void), SkinIndex si)
{
	return create_pbutton_ex(wlist, parent, gc, x, y, w, h, nx, ny, px, py, cb, si, si);
}

void free_pbutton(PButton * b)
{
	g_free(b);
}
