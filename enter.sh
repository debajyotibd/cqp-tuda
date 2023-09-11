#!/bin/bash

export PATH="$PATH:/sbin"

[[ -f env.sh ]] && source env.sh

if [ "$1" == "" ]; then
	if [ "$DESTDIR" == "" ]; then
		echo "Cannot determine destination directory. Please update env.sh or provide destination directory as argument to this script."
		exit 1
	fi
else
	DESTDIR="$(cd -- "$1" && pwd)"
fi

unshare --map-root-user chroot "$DESTDIR" /bin/bash

