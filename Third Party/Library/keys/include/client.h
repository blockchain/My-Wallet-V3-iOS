#ifndef CLIENT_H
#define CLIENT_H

#include <stdbool.h>
#include <stdint.h>

#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/ssl.h>

#include "protocol.h"
#include "db.h"

SSL_CTX *client_ctx(X509 *, X509 *, EVP_PKEY *);
SSL *client_socket(SSL_CTX *ctx, sockaddr6 *, struct timeval *);

void request(SSL *, uint32_t, uint32_t, uint32_t);
uint32_t response(SSL *, uint32_t *);
void send_entry(SSL *, uint32_t, uint32_t, entry *);

uint32_t find_entries(SSL *, char *, uint32_t, entry **);
uint32_t delete_entry(SSL *, char *, uint32_t *);
uint32_t change_passwd(SSL *, uint8_t *);

#endif /* CLIENT_H */
