#!/bin/sh

certDir="/tmp/gen_cert"
mkdir -p ${certDir}
ns="certs"
cert_name="tls-secret"

# macos
cp /etc/ssl/openssl.cnf /tmp/openssl-with-ca.cnf
echo '
[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always' >> /tmp/openssl-with-ca.cnf

# TLS certificates
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout ${certDir}/tls.key -out \
${certDir}/tls.crt -subj "/CN=n8n.mydev.test/CN=svc1.mydev.test/CN=mydev.test/CN=mydev2.test/O=test" \
-extensions v3_ca -config /tmp/openssl-with-ca.cnf

echo "Creating Certs and loading into $ns namespace"
kubectl create ns ${ns}
kubectl -n $ns delete secret ${cert_name}
kubectl -n $ns create secret tls ${cert_name} --key ${certDir}/tls.key --cert ${certDir}/tls.crt


# # Generate the CA Key and Certificate:
# openssl req -x509 -sha256 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 356 -nodes -subj '/CN=My Cert Authority'

# # Generate the Server Key, and Certificate and Sign with the CA Certificate:
# openssl req -new -newkey rsa:4096 -keyout server.key -out server.csr -nodes -subj '/CN=local.dev'
# openssl x509 -req -sha256 -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

# # Generate the Client Key, and Certificate and Sign with the CA Certificate:
# openssl req -new -newkey rsa:4096 -keyout client.key -out client.csr -nodes -subj '/CN=My Client'
# openssl x509 -req -sha256 -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out client.crt

