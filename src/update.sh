#!/bin/ash

#alias apk='apk --no-chown'

apk update
apk upgrade

cd /src

gcc -o /sbin/init -static init.c
strip /sbin/init

