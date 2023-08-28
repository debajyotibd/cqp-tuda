#!/bin/ash

mysql_install_db --datadir=/var/lib/mysql

mysqld --user=root --datadir=/var/lib/mysql --port=3306 --bind-address=127.0.0.1 --skip-networking=false &
MYSQL_PID=$!

echo Waiting for mysql database to start up...
sleep 5
mysql -u root -e 'create database cqpweb_db default charset utf8;'
mysql -u root -e 'create user cqpweb identified by "cqpweb";'
mysql -u root -e 'grant all on cqpweb_db.* to cqpweb;'
mysql -u root -e 'grant file on *.* to cqpweb;'
mysql -u root -e 'delete from mysql.user where user="";'
mysql -u root -e 'flush privileges;'

cd /var/www/cqpweb/bin
php autosetup.php

kill $MYSQL_PID

gcc -o /sbin/init -static /src/init.c
strip /sbin/init

