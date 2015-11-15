#!/bin/bash
set -e
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
echo "Install PKI"
cd /vagrant/pki-scripts
./gen_root_ca.sh capass tspass > /dev/null 2>&1
./gen_node_cert.sh localhost kspass capass > /dev/null 2>&1
./gen_user_cert.sh capass > /dev/null 2>&1
cd /vagrant
mkdir -p _elasticsearch > /dev/null 2>&1
cd _elasticsearch

if [ ! -f /vagrant/_elasticsearch/curl/src/curl ]
then
  echo "Build curl"
  git clone https://github.com/bagder/curl.git > /dev/null 2>&1
  cd curl
  git checkout 808a17ee67529a6a25f98c878e7c844bcf64597d > /dev/null 2>&1
  ./buildconf > /dev/null 2>&1
  ./configure --with-gssapi --with-ssl > /dev/null 2>&1
  make > /dev/null 2>&1
  sudo make install > /dev/null 2>&1
  cd ..
fi

if [ ! -f /vagrant/_elasticsearch/kibana-4.2.0-linux-x64.tar.gz ]
then
  echo "Download Elasticsearch/Kibana"
  wget -nv -q https://github.com/codecentric/elasticsearch-shield-kerberos-realm/releases/download/2.0.0/elasticsearch-shield-kerberos-realm-2.0.0.zip
  wget -nv -q https://download.elastic.co/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz
  tar -xzf kibana-4.2.0-linux-x64.tar.gz
  wget -nv -q https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.0.0/elasticsearch-2.0.0.tar.gz
  tar -xzf elasticsearch-2.0.0.tar.gz
  cd kibana-4.2.0-linux-x64
  #bin/kibana plugin --install elasticsearch/marvel/latest
  cd ../elasticsearch-2.0.0
  echo "Install Elasticsearch plugins"
  bin/plugin install license
  #bin/plugin install marvel-agent
  bin/plugin install shield
  ##bin/plugin remove elasticsearch-shield-kerberos-realm
  bin/plugin install file:///vagrant/_elasticsearch/elasticsearch-shield-kerberos-realm-2.0.0.zip
fi

cd /vagrant/_elasticsearch/elasticsearch-2.0.0

echo "Configuring Elasticsearch"
echo "shield.authc.realms.kerb.type: cc-kerberos" > config/elasticsearch.yml
echo "shield.authc.realms.kerb.order: 1"  >> config/elasticsearch.yml
echo "shield.authc.realms.kerb.acceptor_keytab_path: /etc/krb5.keytab"  >> config/elasticsearch.yml
echo "shield.authc.realms.kerb.acceptor_principal: HTTP/localhost@EXAMPLE.COM"  >> config/elasticsearch.yml
echo "shield.authc.realms.kerb.roles: admin"  >> config/elasticsearch.yml
echo "de.codecentric.realm.cc-kerberos.krb5.file_path: /etc/krb5.conf" >> config/elasticsearch.yml
echo "de.codecentric.realm.cc-kerberos.krb_debug: true" >> config/elasticsearch.yml

echo "shield.ssl.keystore.path: /vagrant/pki-scripts/server-localhost-keystore.jks" >> config/elasticsearch.yml
echo "shield.ssl.keystore.password: kspass" >> config/elasticsearch.yml
echo "shield.ssl.truststore.path: /vagrant/pki-scripts/truststore.jks" >> config/elasticsearch.yml
echo "shield.ssl.truststore.password: tspass" >> config/elasticsearch.yml
echo "shield.ssl.hostname_verification: false" >> config/elasticsearch.yml
echo "shield.http.ssl: true" >> config/elasticsearch.yml
echo "shield.http.ssl.client.auth: optional" >> config/elasticsearch.yml

echo "shield.authc.realms.tpki.type: pki" >> config/elasticsearch.yml
echo "shield.authc.realms.tpki.order: 0" >> config/elasticsearch.yml
echo "shield.authc.pki.files.role_mapping: /vagrant/_elasticsearch/elasticsearch-2.0.0/config/shield/pki_role_mapping.yml" >> config/elasticsearch.yml
echo "security.manager.enabled: false" >> config/elasticsearch.yml
echo "http.cors.enabled: true" >> config/elasticsearch.yml
echo "http.cors.allow-origin: "'"*"' >> config/elasticsearch.yml
echo "network.bind_host: 0.0.0.0" >> config/elasticsearch.yml

echo "admin:" > config/shield/pki_role_mapping.yml
echo "  - "'"C=DE,ST=TESTU,L=TESTU,O=TESTU,OU=TESTU,CN=Mister Spock"' >> config/shield/pki_role_mapping.yml
echo "  - "'"C=DE, ST=TESTU, L=TESTU, O=TESTU, OU=TESTU, CN=Mister Spock"' >> config/shield/pki_role_mapping.yml
echo "  - "'"CN=Mister Spock,OU=TESTU,O=TESTU,L=TESTU,ST=TESTU,C=DE"' >> config/shield/pki_role_mapping.yml
echo "  - "'"CN=Mister Spock, OU=TESTU, O=TESTU, L=TESTU, ST=TESTU, C=DE"' >> config/shield/pki_role_mapping.yml



cat config/shield/role_mapping.yml
echo
cat config/elasticsearch.yml
cd /vagrant
echo "To start kibana type /vagrant/start_kibana.sh"
echo "To start elasticsearch type /vagrant/start_elasticsearch.sh"
