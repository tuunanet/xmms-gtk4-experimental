#!/bin/sh
set -eu

repo_root=${1:?repository root is required}
mode=${2:?mode is required}
policy="$repo_root/docs/architecture/gnome-c-foundations.md"
header="$repo_root/xmms/ui_gtk3_control.h"
source="$repo_root/xmms/ui_gtk3_control.c"
control_header="$repo_root/xmms/ui_control.h"
control_source="$repo_root/xmms/ui_control.c"
meson="$repo_root/tests/meson.build"
format_config="$repo_root/tools/clang-format-gnome.yml"

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

check_no_forbidden_includes()
{
	file=$1

	for forbidden in plugin.h controlsocket.h configfile.h skin.h main.h; do
		if grep -F "#include \"$forbidden\"" "$file" >/dev/null; then
			fail "rejects $forbidden in managed dependency modules"
		fi
	done
}

check_format_scope()
{
	[ -f "$format_config" ] || fail "provides GNOME C format configuration"
	require_text 'IndentWidth: 2' "$format_config" \
		"uses two-space GNOME C indentation"
	require_text 'BreakBeforeBraces: Linux' "$format_config" \
		"uses GNOME-compatible brace placement"
	require_text 'ColumnLimit: 80' "$format_config" \
		"uses an approximately 80-column limit"
	require_text 'xmms/ui_gtk3_control.c' "$format_config" \
		"documents the managed GTK3 C source path"
	require_text 'xmms/ui_gtk3_control.h' "$format_config" \
		"documents the managed GTK3 header path"
}

check_dependency_contract()
{
	check_policy
	require_text '## Directional dependencies' "$policy" \
		"documents directional dependencies"
	require_text 'UI/rendering adapter' "$policy" \
		"defines the UI rendering adapter layer"
	require_text 'Toolkit-neutral UI control' "$policy" \
		"defines the toolkit-neutral control layer"
	require_text 'plugin.h' "$policy" \
		"prohibits plugin dependencies in managed modules"
	require_text 'controlsocket.h' "$policy" \
		"prohibits control socket dependencies in managed modules"
	require_text 'Historical compatibility allowlist' "$policy" \
		"documents historical compatibility exemptions"
	require_text 'xmms/pbutton.c' "$policy" \
		"allowlists the GTK2 Play-button bridge"
	require_text '#include "ui_control.h"' "$header" \
		"allows the GTK3 adapter to use the control contract"
	check_no_forbidden_includes "$header"
	check_no_forbidden_includes "$source"
	check_no_forbidden_includes "$control_header"
	check_no_forbidden_includes "$control_source"
}

case "$mode" in
--policy)
	check_policy
	echo "ok - documents GNOME C foundation boundaries"
	;;
--format-scope)
	check_format_scope
	echo "ok - scopes GNOME C formatting to the GTK3 adapter"
	;;
--dependency-contract)
	check_dependency_contract
	echo "ok - enforces directional GTK migration dependencies"
	;;
--gobject-boundaries)
	check_policy
	require_text 'G_DECLARE_FINAL_TYPE(XmmsUiGtk3Control' "$header" \
		"declares the GTK3 proof adapter final"
	require_text 'UI_GTK3_CONTROL, GObject)' "$header" \
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
	fail "supports --policy, --format-scope, --dependency-contract, and --gobject-boundaries modes"
	;;
esac
