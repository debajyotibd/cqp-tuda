echo "############################# Starting the MySQL #############################"
echo "Note: If your process is not respnding or stuck,  just press Enter. Then the process will happen auto. " 

/usr/bin/mysqld_safe &

echo "############################# Staring the Backend. #############################"

/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf & 

echo "############################# Configuring the CWB 3.5.0 #############################"

cd /usr/src/cwb-3.5.0-src/

echo "############################# Processing Make Clean #############################"

make clean

echo "############################# Processing Make Release #############################"

make release

echo "############################# Processing Make Install #############################"

make install


echo "############################# Please Do Login and Start using CQPweb TUDa. #############################"