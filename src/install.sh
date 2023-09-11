apk add libxml2-dev
apk add mysql
apk add mysql-client
apk add lighttpd
apk add glib-dev
apk add pcre-dev
apk add readline-dev

cd /src/php-7.3.20
./configure --enable-embedded-mysqli --with-mysqli --enable-mbstring
make $MAKEOPTS
make install

cd /src/cwb
make release
make install


mkdir -p /run/mysqld

