#!/bin/bash

if [ "$1" == "" ]; then
	DESTDIR="$HOME/.local/opt/cqpweb"
else
	DESTDIR="$(cd -- "$1" && pwd)"
fi

"$DESTDIR/sbin/init"

