#!/bin/bash

if [ "$1" == "" ]; then
	if [ "$CQPWEB_PATH" == "" ]; then
		DESTDIR="$HOME/.local/opt/cqpweb"
	else
		DESTDIR="$CQPWEB_PATH"
	fi
else
	DESTDIR="$(cd -- "$1" && pwd)"
fi

"$DESTDIR/sbin/init"

