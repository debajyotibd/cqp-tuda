echo "############################# Starting the MySQL #############################"
echo "Note: If your process is not respnding or stuck,  just press Enter. Then the process will happen auto. " 

/usr/bin/mysqld_safe &

echo "############################# Staring the Backend. #############################"

/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf & 


echo "############################# Please Do Login and Start using CQPweb TUDa. #############################"