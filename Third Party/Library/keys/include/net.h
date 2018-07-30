#ifndef NET_H
#define NET_H

#include <openssl/ssl.h>

uint8_t *srecv(SSL *, uint32_t);

#endif /* NET_H */
