#!/bin/bash
set -e
CN=$1
NODE_NAME="server-$CN"
KS_PASS=$2
CA_PASS=$3
rm -f $NODE_NAME*

echo Generating keystore and certificate for node $NODE_NAME

"$JAVA_HOME/bin/keytool" -genkey \
        -alias     $NODE_NAME \
        -keystore  $NODE_NAME-keystore.jks \
        -keyalg    RSA \
        -keysize   2048 \
        -validity  712 \
        -keypass $KS_PASS \
        -storepass $KS_PASS \
        -dname "CN=$CN, OU=SSL, O=Test, L=Test, C=DE" \
        -ext san=dns:$CN,ip:127.0.0.1

echo Generating certificate signing request for node $NODE_NAME

"$JAVA_HOME/bin/keytool" -certreq \
        -alias      $NODE_NAME \
        -keystore   $NODE_NAME-keystore.jks \
        -file       $NODE_NAME.csr \
        -keyalg     rsa \
        -keypass $KS_PASS \
        -storepass $KS_PASS \
        -dname "CN=$CN, OU=SSL, O=Test, L=Test, C=DE" \
        -ext san=dns:$CN,ip:127.0.0.1

echo Sign certificate request with CA
openssl ca \
    -in $NODE_NAME.csr \
    -notext \
    -out $NODE_NAME-signed.crt \
    -config etc/signing-ca.conf \
    -extensions v3_req \
    -batch \
	-passin pass:$CA_PASS \
	-extensions server_ext

echo "Import back to keystore (including CA chain)"

"$JAVA_HOME/bin/keytool" \
    -import \
    -file ca/root-ca.crt \
    -keystore $NODE_NAME-keystore.jks \
    -storepass $KS_PASS \
    -noprompt \
    -alias root-ca

"$JAVA_HOME/bin/keytool" \
    -import \
    -file ca/signing-ca.crt \
    -keystore $NODE_NAME-keystore.jks \
    -storepass $KS_PASS \
    -noprompt \
    -alias sig-ca

"$JAVA_HOME/bin/keytool" \
    -import \
    -file $NODE_NAME-signed.crt \
    -keystore $NODE_NAME-keystore.jks \
    -storepass $KS_PASS \
    -noprompt \
    -alias $NODE_NAME

#openssl x509 -in $NODE_NAME-signed.crt -out $NODE_NAME-signed.der -outform DER
#openssl x509 -inform der -outform PEM -in $NODE_NAME-signed.der -out $NODE_NAME-signed.pem

rm -f $NODE_NAME.csr
rm -f $NODE_NAME-signed.crt
echo All done for $NODE_NAME
