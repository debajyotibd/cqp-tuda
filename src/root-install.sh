#!/bin/ash

MAKEOPTS=-j4

apk update
apk upgrade
apk add bash
apk add build-base
apk add libxml2-dev
apk add mysql
apk add mysql-client
apk add lighttpd
apk add glib-dev
apk add pcre-dev
apk add readline-dev

cd /src

#wget https://prototype.php.net/distributions/php-7.3.20.tar.xz
#wget https://master.dl.sourceforge.net/project/cwb/cwb/cwb-3.5/source/cwb-3.5.0-src.tar.gz
#wget https://master.dl.sourceforge.net/project/cwb/CQPweb/CQPweb-3.2/CQPweb-3.2.43.tar.gz

#tar xf CQPweb-3.2.43.tar.gz
#tar xf cwb-3.5.0-src.tar.gz

cd php-7.3.20
./configure --enable-embedded-mysqli --with-mysqli --enable-mbstring
make $MAKEOPTS
make install
cd ..

cd cwb
make release
make install


mkdir -p /run/mysqld

