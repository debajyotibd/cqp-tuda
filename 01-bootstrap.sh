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
	mkdir -p "$DESTDIR"
else
	mkdir -p "$1"
	DESTDIR="$(cd -- "$1" && pwd)"
fi

mkdir -p "$DESTDIR/src"
cp -R "$SRCDIR/src" "$DESTDIR"
echo '#define ROOT_DIR "'"$DESTDIR"'"' >"$DESTDIR/src/config.h"

git clone https://github.com/alpinelinux/alpine-chroot-install/ "$DESTDIR/src/alpine-chroot-install"
unshare --map-root-user "$DESTDIR/src/alpine-chroot-install/alpine-chroot-install" -d "$DESTDIR"
unshare --map-root-user chroot "$DESTDIR" /src/bootstrap.sh

