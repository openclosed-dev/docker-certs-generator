#!/bin/bash

#
# Server certificate
#

mkdir -p ${SERVER_DIR}

SERVER_CONFIG=server.conf
SERVER_EXTENSION=server.ext

if [[ -e ${SERVER_DIR}/${SERVER_KEY} ]]; then
    echo "Using existing server key: ${SERVER_KEY}"
else
    echo "Generating new server key: ${SERVER_KEY}"
    openssl genrsa ${SERVER_KEY_BITS} > ${SERVER_DIR}/${SERVER_KEY}
fi

cat <<EOF > ${SERVER_DIR}/${SERVER_CONFIG}
[req]
prompt = no
distinguished_name = dn

[dn]
CN = ${SERVER_SUBJECT}
EOF

if [[ -e ${SERVER_DIR}/${SERVER_CSR} ]]; then
    echo "Using existing server certificate signing request: ${SERVER_CSR}"
else
    echo "Generating new server certificate signing request: ${SERVER_CSR}"
    openssl req -new -config ${SERVER_DIR}/${SERVER_CONFIG} \
        -key ${SERVER_DIR}/${SERVER_KEY} -out ${SERVER_DIR}/${SERVER_CSR} 
fi

cat <<EOF > ${SERVER_DIR}/${SERVER_EXTENSION}
basicConstraints = CA:FALSE
keyUsage = digitalSignature
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${SERVER_SUBJECT}
EOF

if [[ -e ${SERVER_DIR}/${SERVER_CERT} ]]; then
    echo "Using existing server certificate: ${SERVER_CERT}"
else
    echo "Generating new server certificate: ${SERVER_CERT}"
	openssl x509 -req \
        -in ${SERVER_DIR}/${SERVER_CSR} \
        -CA ${CA_DIR}/${CA_CERT} -CAkey ${CA_DIR}/${CA_KEY} \
        -extfile ${SERVER_DIR}/${SERVER_EXTENSION} \
        -days ${SERVER_EXPIRE} -out ${SERVER_DIR}/${SERVER_CERT}
    openssl x509 -text -noout -in ${SERVER_DIR}/${SERVER_CERT}
fi
