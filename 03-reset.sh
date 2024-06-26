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

cp "$SRCDIR/src/lighttpd.conf" "$DESTDIR/etc/lighttpd"
cp "$SRCDIR/src/php.ini" "$DESTDIR/usr/local/lib/php.ini"
cp -R "$SRCDIR/src" "$DESTDIR"
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

unshare --map-root-user chroot "$DESTDIR" /src/reset.sh

