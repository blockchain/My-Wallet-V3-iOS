#ifndef PROTOCOL_H
#define PROTOCOL_H

#include <netinet/in.h>
#include <sys/socket.h>

#define TLS_CIPHER_SUITE  "ECDHE-ECDSA-AES256-GCM-SHA384"
#define    EC_CURVE_NAME  "secp384r1"
#define X509_DIGEST_NAME  "SHA384"

#define        SERVER_CN  "Keys CA/Server"
#define        CLIENT_CN  "Keys Client"

#define        OK  0

#define   SIG_MAX  256
#define  PING_LEN  16
#define  PONG_LEN  (sizeof(struct pong) - SIG_MAX)

enum cmd {
    add    = 1,
    delete = 2,
    edit   = 3,
    find   = 4,
    passwd = 5,
    rekey  = 6,
    export = 7,
    import = 8,
};

struct pong {
    uint8_t addr[16];
    uint16_t port;
    uint8_t sig[SIG_MAX];
};

typedef struct {
    uint32_t cmd;
    uint32_t arg;
    uint32_t len;
} message;

typedef struct sockaddr_in6 sockaddr6;
typedef struct sockaddr_in  sockaddr4;
typedef struct sockaddr     sockaddr;

#endif /* PROTOCOL_H */
