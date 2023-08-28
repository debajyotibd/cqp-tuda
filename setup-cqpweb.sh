#!/bin/bash

SRCDIR="$(dirname -- "${BASH_SOURCE[0]}")"
SRCDIR="$(cd -- "$SRCDIR" && pwd)"

if [ "$1" == "" ]; then
	DESTDIR="$HOME/.local/opt/cqpweb"
else
	DESTDIR="$(cd -- "$1" && pwd)"
fi

cp "$SRCDIR/src/cqpweb-install.sh" "$DESTDIR/src"
cp "$SRCDIR/src/lighttpd.conf" "$DESTDIR/etc/lighttpd"
cp "$SRCDIR/src/php.ini" "$DESTDIR/usr/local/lib/php.ini"
cp "$SRCDIR/src/init.c" "$DESTDIR/src"

rm -f "$DESTDIR/sbin/init"
#echo '#define ROOT_DIR "'"$DESTDIR"'"' >"$DESTDIR/src/config.h"
#gcc -o "$DESTDIR/sbin/init" "$SRCDIR/src/init.c" -I"$DESTDIR/src"

rm -Rf "$DESTDIR/var/lib/mysql"

rm -Rf "$DESTDIR/var/www/cqpweb"
mkdir -p "$DESTDIR/var/www/cqpweb"
tar xf "$SRCDIR/src/CQPweb-3.2.43.tar.gz" -C "$DESTDIR/var/www/cqpweb" --strip-components=1
cp "$SRCDIR/src/config.inc.php" "$DESTDIR/var/www/cqpweb/lib"

rm -Rf "$DESTDIR/data/corpora/cqpweb"
mkdir -p "$DESTDIR/data/corpora/cqpweb"
cd "$DESTDIR/data/corpora/cqpweb"
mkdir -p upload
mkdir -p tmp
mkdir -p corpora
mkdir -p registry

unshare --map-root-user chroot "$DESTDIR" /src/cqpweb-install.sh


