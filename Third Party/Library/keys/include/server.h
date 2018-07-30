#ifndef SERVER_H
#define SERVER_H

#include <signal.h>

extern volatile sig_atomic_t stop;

void server(interface *, X509 *, EVP_PKEY *);

static bool    add_entry(idx *, uint8_t *, kdfp *, entry *);
static bool delete_entry(idx *, uint8_t *, kdfp *, uint8_t *);
static bool   find_entry(SSL *, idx *, uint8_t **, uint32_t);

void start(SSL *);
void  loop(SSL *, idx *, kdfp *, uint8_t *);
void reply(SSL *, uint32_t, uint32_t, uint32_t);

void pong(int, EVP_PKEY *, interface *, uint16_t);

int server_sock(SSL_CTX **, X509 *, EVP_PKEY *, interface *, sockaddr6 *);

#endif /* SERVER_H */
