#!/bin/bash

export PATH="$PATH:/sbin"

SRCDIR="$(dirname -- "${BASH_SOURCE[0]}")"
SRCDIR="$(cd -- "$SRCDIR" && pwd)"

[[ -f env.sh ]] && source env.sh

if [ "$1" == "" ]; then
	if [ "$DESTDIR" == "" ]; then
		echo "Cannot determine destination directory. Please update env.sh or provide destination directory as argument to this script."
		exit 1
	fi
else
	DESTDIR="$(cd -- "$1" && pwd)"
fi

tar xf "$SRCDIR/src/php-7.3.20.tar.gz" -C "$DESTDIR/src"

mkdir -p "$DESTDIR/src/cwb"
tar xf "$SRCDIR/src/cwb-3.5.0-src.tar.gz" -C "$DESTDIR/src/cwb" --strip-components=1

unshare --map-root-user chroot "$DESTDIR" /src/install.sh

