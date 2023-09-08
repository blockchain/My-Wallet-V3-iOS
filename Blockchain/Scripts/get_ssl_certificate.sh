#!/bin/sh
#
#  NetworkKit/Scripts/get_ssl_certificate.sh
#
#  What It Does
#  ------------
#  Downloads certificate from URL specified in WALLET_SERVER into ${SRCROOT}/Modules/Network/NetworkKit/Cert/blockchain.der.
#  Once the certificate is downloaded for a specific environment, it is saved as a cache in an environment-specific file.

set -ue

CERTIFICATE_PATH="${SRCROOT}/Blockchain/Cert"

if [ ! -d ${CERTIFICATE_PATH} ]; then
    echo "Creating ${CERTIFICATE_PATH} directory"
    mkdir ${CERTIFICATE_PATH}
fi
cd ${CERTIFICATE_PATH}

if [ ! -f ${CERTIFICATE_PATH}/blockchain_${WALLET_SERVER}.der ]; then
    echo "Downloading certificate from ${WALLET_SERVER}:443"
    openssl s_client -connect ${WALLET_SERVER}:443 -showcerts -CApath /etc/ssl/certs/ | openssl x509 -outform DER > blockchain_${WALLET_SERVER}.der
else
    echo "Cache found for certificate from ${WALLET_SERVER}:443"
fi

if [ ! -f blockchain.der ] || ! cmp -s blockchain_${WALLET_SERVER}.der blockchain.der; then
    echo "Setting environment specific certificate from cache"
    cp blockchain_${WALLET_SERVER}.der blockchain.der
else
    echo "Environment specific certificate already in place"
fi

