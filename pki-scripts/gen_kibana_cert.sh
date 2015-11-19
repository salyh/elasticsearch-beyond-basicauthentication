#!/bin/bash
set -e
CA_PASS=$1
echo "-> Generating kibana key"
openssl genrsa -out kibana.key 2048
openssl req -key kibana.key -new -out kibana.req \
            -subj "/C=DE/ST=Kibana/L=Kibana/O=TESTU/OU=Kibana/CN=localhost"
echo "-> Generating kibana cert"
openssl x509 -req -in kibana.req -CA ca/signing-ca.pem \
             -CAkey ca/signing-ca/private/signing-ca.key -CAserial ca/signing-ca/db/signing-ca.crl.srl \
             -out kibana.crt \
             -passin pass:$CA_PASS
