#!/bin/sh
set -eu

repo_root=${1:?repository root is required}
mode=${2:?mode is required}
policy="$repo_root/docs/architecture/gnome-c-foundations.md"
header="$repo_root/xmms/ui_gtk3_control.h"
source="$repo_root/xmms/ui_gtk3_control.c"
meson="$repo_root/tests/meson.build"

fail()
{
	echo "not ok - $1" >&2
	exit 1
}

require_text()
{
	grep -F "$1" "$2" >/dev/null \
		|| fail "$3"
}

check_policy()
{
	[ -f "$policy" ] || fail "documents GNOME C foundation boundaries"
	require_text 'final by default' "$policy" \
		"requires final GObject types by default"
	require_text 'Instance data remains private' "$policy" \
		"requires private instance data"
	require_text 'caller-observable state or behavior' "$policy" \
		"limits properties and signals to observable behavior"
	require_text 'genuine extension boundary' "$policy" \
		"limits interfaces to genuine extension boundaries"
	require_text 'process-global mutable state' "$policy" \
		"prohibits new mutable process-global state"
	require_text 'plugin vtable ABI' "$policy" \
		"exempts the historic plugin ABI"
	require_text 'control-socket protocol' "$policy" \
		"exempts the historic control socket"
}

case "$mode" in
--policy)
	check_policy
	echo "ok - documents GNOME C foundation boundaries"
	;;
--gobject-boundaries)
	check_policy
	require_text 'G_DECLARE_FINAL_TYPE(XmmsUiGtk3Control' "$header" \
		"declares the GTK3 proof adapter final"
	require_text 'XMMS, UI_GTK3_CONTROL, GObject)' "$header" \
		"uses GObject as the final adapter parent"
	if grep -F 'struct _XmmsUiGtk3Control' "$header" >/dev/null; then
		fail "keeps GTK3 proof instance data private"
	fi
	require_text 'struct _XmmsUiGtk3Control' "$source" \
		"defines GTK3 proof instance data privately"
	require_text 'G_DEFINE_TYPE(XmmsUiGtk3Control' "$source" \
		"defines the final GTK3 proof type"
	if grep -E 'g_object_class_install_property|g_signal_new|G_DEFINE_INTERFACE' \
		"$source" >/dev/null; then
		fail "avoids unnecessary properties signals and interfaces"
	fi
	if grep -E '^static [^ (][^;]*;' "$source" >/dev/null; then
		fail "avoids mutable GTK3 proof module globals"
	fi
	if grep -E 'xmms_ui_gtk3_draw_command|xmms_ui_gtk3_handle_event' \
		"$header" >/dev/null; then
		fail "exposes only the object-oriented GTK3 proof API"
	fi
	require_text "suite: 'gobject-boundaries'" "$meson" \
		"registers the focused GObject boundary suite"
	echo "ok - enforces final GTK3 proof boundaries"
	;;
*)
	fail "supports --policy and --gobject-boundaries modes"
	;;
esac
