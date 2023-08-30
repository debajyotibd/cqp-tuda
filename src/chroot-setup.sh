#!/bin/ash

MAKEOPTS=-j4

#set -e

apk update
apk upgrade
apk add bash
apk add build-base
apk add lighttpd

mkdir -p /src
cd /src

wget https://prototype.php.net/distributions/php-7.3.20.tar.xz
wget https://master.dl.sourceforge.net/project/cwb/cwb/cwb-3.5/source/cwb-3.5.0-src.tar.gz
wget https://master.dl.sourceforge.net/project/cwb/CQPweb/CQPweb-3.2/CQPweb-3.2.43.tar.gz

tar xf php-7.3.20.tar.xz
tar xf CQPweb-3.2.43.tar.gz
tar xf cwb-3.5.0-src.tar.gz

apk add libxml2-dev
apk add glib-dev
apk add pcre-dev
apk add readline-dev
cd php-7.3.20
./configure --enable-embedded-mysqli --with-mysqli
make $MAKEOPTS
make install
cd ..

cd cwb-3.5.0-src
make release
make install
cd ..

mkdir -p /var/www
ln -s /src/CQPweb-3.2.43 /var/www/cqp

apk add mysql
apk add mysql-client
mkdir -p /run/mysqld
mysql_install_db --datadir=/var/lib/mysql

mkdir -p /data/corpora
rm -Rf /data/corpora

mkdir -p /data/corpora/cqpweb
cd /data/corpora/cqpweb
mkdir -p upload
mkdir -p tmp
mkdir -p corpora
mkdir -p registry

