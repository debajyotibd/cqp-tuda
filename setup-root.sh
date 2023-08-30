#!/bin/bash

SRCDIR="$(dirname -- "${BASH_SOURCE[0]}")"
SRCDIR="$(cd -- "$SRCDIR" && pwd)"

if [ "$1" == "" ]; then
	if [ "$CQPWEB_PATH" == "" ]; then
		DESTDIR="$HOME/.local/opt/cqpweb"
	else
		DESTDIR="$CQPWEB_PATH"
	fi
else
	DESTDIR="$(cd -- "$1" && pwd)"
fi

mkdir -p "$DESTDIR"


#git clone https://github.com/alpinelinux/alpine-chroot-install/
unshare --map-root-user "$SRCDIR/src/alpine-chroot-install" -d "$DESTDIR"

mkdir -p "$DESTDIR/src"
tar xf "$SRCDIR/src/php-7.3.20.tar.gz" -C "$DESTDIR/src"
cp "$SRCDIR/src/root-install.sh" "$DESTDIR/src"

mkdir -p "$DESTDIR/src/cwb"
tar xf "$SRCDIR/src/cwb-3.5.0-src.tar.gz" -C "$DESTDIR/src/cwb" --strip-components=1

unshare --map-root-user chroot "$DESTDIR" /src/root-install.sh

