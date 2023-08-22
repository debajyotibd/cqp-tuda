#!/bin/ash

MAKEOPTS=-j4

#set -e


apk update
apk upgrade
apk add bash
apk add build-base
apk add libxml2-dev
#apk add cmake
apk add mysql
apk add mysql-client
apk add lighttpd
apk add glib-dev
apk add pcre-dev
apk add readline-dev

mkdir -p /src
cd /src

wget https://prototype.php.net/distributions/php-7.3.20.tar.xz
wget https://master.dl.sourceforge.net/project/cwb/cwb/cwb-3.5/source/cwb-3.5.0-src.tar.gz
wget https://master.dl.sourceforge.net/project/cwb/CQPweb/CQPweb-3.2/CQPweb-3.2.43.tar.gz

tar xf php-7.3.20.tar.xz
tar xf CQPweb-3.2.43.tar.gz
tar xf cwb-3.5.0-src.tar.gz

cd php-7.3.20
./configure --enable-embedded-mysqli --with-mysqli
make $MAKEOPTS
make install
cd ..

#tar xf mysql-boost-5.7.42.tar.gz
#cd mysql-5.7.42
#mkdir Release
#cd Release
#cmake .. -DWITH_BOOST=../boost


cd cwb-3.5.0-src
make release
make install
cd ..

mkdir -p /var/www
ln -s /src/CQPweb-3.2.43 /var/www/cqp

mkdir -p /run/mysqld
mysql_install_db --datadir=/var/lib/mysql

#copy php.ini /usr/local/lib/php.ini

mkdir -p /data/corpora
rm -Rf /data/corpora

mkdir -p /data/corpora/cqpweb
cd /data/corpora/cqpweb
mkdir -p upload
mkdir -p tmp
mkdir -p corpora
mkdir -p registry




mysql -u root -e 'create database cqpweb_db default charset utf8;'
mysql -u root -e 'create user cqpweb identified by "cqpweb";'
mysql -u root -e 'grant all on cqpweb_db.* to cqpweb;'
mysql -u root -e 'grant file on *.* to cqpweb;'
mysql -u root -e 'delete from mysql.user where user="";'
mysql -u root -e 'flush privileges;'

#execute autoconfig.php in cqp
# --> generates config.inc.php, which must be in lib folder of www
#execute autosetup.php

