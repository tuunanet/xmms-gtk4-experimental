#!/bin/sh
set -eu

if ! command -v cppcheck >/dev/null 2>&1; then
	echo "Cppcheck is required; install the cppcheck package." >&2
	exit 2
fi

exec cppcheck "$@"
