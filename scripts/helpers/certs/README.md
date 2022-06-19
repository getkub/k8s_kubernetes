```
# macos
cp /etc/ssl/openssl.cnf /tmp/openssl-with-ca.cnf
echo '
[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always' >> /tmp/openssl-with-ca.cnf

## The seed file is in helpers
openssl req -x509 -new -nodes -key tls.key -sha256 -days 1024 -out tls.crt -extensions v3_ca -config /tmp/openssl-with-ca.cnf

```