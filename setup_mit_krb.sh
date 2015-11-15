#!/bin/bash
sudo apt-get -y install krb5-admin-server krb5-kdc krb5-config krb5-user
sudo kdb5_util create -s
sudo /etc/init.d/krb5-kdc restart > /dev/null 2>&1
sudo /etc/init.d/krb5-admin-server restart > /dev/null 2>&1
echo
echo "----------------------------------"
echo "addprinc -randkey HTTP/localhost"
echo "addprinc luke [with pwd: lukepwd]"
echo "ktadd HTTP/localhost"
echo "exit"
echo "----------------------------------"
echo
sudo kadmin.local
sudo chmod 755 /etc/krb5.keytab
