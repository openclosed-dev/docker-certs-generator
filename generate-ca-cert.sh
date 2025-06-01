#!/bin/bash

#
# CA certificate
#

mkdir -p ${CA_DIR}

CA_CONFIG=ca.conf
CA_EXTENSION=ca.ext

if [[ -e ${CA_DIR}/${CA_KEY} ]]; then
    echo "Using existing CA key: ${CA_KEY}"
else
    echo "Generating new CA key: ${CA_KEY}"
    openssl genrsa ${CA_KEY_BITS} > ${CA_DIR}/${CA_KEY}
fi

cat <<EOF > ${CA_DIR}/${CA_CONFIG}
[req]
prompt = no
distinguished_name = dn

[dn]
CN = ${CA_SUBJECT}
EOF

if [[ -e ${CA_DIR}/${CA_CSR} ]]; then
    echo "Using existing CA certificate signing request: ${CA_CSR}"
else
    echo "Generating new CA certificate signing request: ${CA_CSR}"
    openssl req -new --config ${CA_DIR}/${CA_CONFIG} -key ${CA_DIR}/${CA_KEY} -out ${CA_DIR}/${CA_CSR} 
fi

cat <<EOF > ${CA_DIR}/${CA_EXTENSION}
basicConstraints = critical, CA:TRUE
keyUsage = keyCertSign
EOF

if [[ -e ${CA_DIR}/${CA_CERT} ]]; then
    echo "Using existing CA certificate: ${CA_CERT}"
else
    echo "Generating new CA certificate: ${CA_CERT}"
    openssl x509 -req \
        -in ${CA_DIR}/${CA_CSR} -signkey ${CA_DIR}/${CA_KEY} \
        -extfile ${CA_DIR}/${CA_EXTENSION} \
        -days ${CA_EXPIRE} -out ${CA_DIR}/${CA_CERT}
    openssl x509 -text -noout -in ${CA_DIR}/${CA_CERT}
fi
