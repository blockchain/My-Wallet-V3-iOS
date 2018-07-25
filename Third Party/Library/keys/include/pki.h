#ifndef PKI_H
#define PKI_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>

#include <openssl/ec.h>
#include <openssl/evp.h>
#include <openssl/ssl.h>
#include <openssl/x509v3.h>

X509 *make_cert(EC_GROUP *, EVP_PKEY **);
void X509V3_add_ext(X509V3_CTX *, X509 *, int, char *);
X509 *make_server_cert(EC_GROUP *, EVP_PKEY **, const char *);
X509 *make_client_cert(EC_GROUP *, EVP_PKEY **, const char *, X509 *);

bool write_pem(char *, uint8_t *, size_t, EVP_PKEY *, EC_GROUP *, size_t, ...);
void read_pem(char *, pem_password_cb *, void *, EVP_PKEY **, size_t, ...);

#endif /* PKI_H */
