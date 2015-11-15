#!/bin/bash
set -e
CA_PASS=$1
rm -rf client.key client.req client.crt client.p12 client.pem
echo "-> Generating client key"
openssl genrsa -out client.key 2048
openssl req -key client.key -new -out client.req \
            -subj "/C=DE/ST=TESTU/L=TESTU/O=TESTU/OU=TESTU/CN=Mister Spock"
echo "-> Generating client cert"
openssl x509 -req -in client.req -CA ca/signing-ca.pem \
             -CAkey ca/signing-ca/private/signing-ca.key -CAserial ca/signing-ca/db/signing-ca.crl.srl \
             -out client.crt \
             -passin pass:$CA_PASS

echo "-> Generating .p12"
openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12 \
              -password pass:p12pass
