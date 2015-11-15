#!/bin/bash
echo "-- SSL authentication"
wget -qO- \
     --ca-cert=/vagrant/pki-scripts/chain-ca.pem  \
     --certificate=/vagrant/pki-scripts/client.crt \
     --private-key=/vagrant/pki-scripts/client.key \
     https://localhost:9200/_logininfo?pretty




echo "-- Kerberos authentication"
export KRB5_CONFIG=/etc/krb5.conf
echo "Password is: lukepwd"
kinit luke@EXAMPLE.COM || { echo 'kinit failed' ; exit -1; }
#/vagrant/_elasticsearch/curl/src/curl -vvv -k --negotiate  -u : "https://localhost:9200/?pretty"
#/vagrant/_elasticsearch/curl/src/curl -vvv -k --negotiate  -u : "https://localhost:9200/_cluster/health?pretty"
/vagrant/_elasticsearch/curl/src/curl -k --negotiate  -u : "https://localhost:9200/_logininfo?pretty"

echo "-- Kerberos AND SSL authentication"
/vagrant/_elasticsearch/curl/src/curl -E /vagrant/pki-scripts/client.crt --key /vagrant/pki-scripts/client.key  --cacert /vagrant/pki-scripts/chain-ca.pem --negotiate  -u : "https://localhost:9200/_logininfo?pretty"
