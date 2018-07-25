#ifndef MCAST_H
#define MCAST_H

#include <stdbool.h>
#include <netdb.h>

#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/rand.h>

#include "protocol.h"
#include "interface.h"

#define MCAST_HOST "ff02::2:1"
#define MCAST_PORT "1050"

bool find_server(EVP_PKEY *, sockaddr6 *, uint32_t, uint32_t);
int mcast_sock(interface *, sockaddr6 *, char *);
void *mcast_server(void *);
char *name(sockaddr6 *, socklen_t);

#endif /* MCAST_H */
