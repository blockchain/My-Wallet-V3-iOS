// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <getopt.h>
#include <unistd.h>

#include "config.h"
#include "sysendian.h"
#include "client.h"
#include "base64.h"
#include "interface.h"
#include "protocol.h"
#include "pki.h"
#include "mcast.h"
#include "mmap.h"
#include "net.h"

void request(SSL *s, uint32_t cmd, uint32_t arg, uint32_t len) {
    message r;
    be32enc(&r.cmd, cmd);
    be32enc(&r.arg, arg);
    be32enc(&r.len, len);
    SSL_write(s, &r, sizeof(r));
}

uint32_t response(SSL *s, uint32_t *arg) {
    uint32_t code = 1;
    message r;

    if (SSL_read(s, &r, sizeof(r)) == sizeof(r)) {
        code = be32dec(&r.cmd);
        *arg = be32dec(&r.arg);
    }

    return code;
}

void send_entry(SSL *s, uint32_t cmd, uint32_t arg, entry *entry) {
    size_t   size = entry_size(entry);
    uint8_t *data = mmalloc(size);

    if (data) {
        write_entry(data, entry);
        request(s, cmd, arg, size);
        SSL_write(s, data, size);
        mfree(data, size);
    }
}

uint32_t find_entries(SSL *s, char *value, uint32_t limit, entry **entries) {
    size_t len = strlen(value);
    request(s, find, limit, len);
    SSL_write(s, value, len);

    uint32_t count = 0;
    message reply;

    while (SSL_read(s, &reply, sizeof(reply)) == sizeof(reply) && reply.len) {
        uint32_t len = be32dec(&reply.len);
        uint8_t *data;
        if ((data = srecv(s, len))) {
            entries[count++] = read_entry(data, len);
        }
    }

    return count;
}

uint32_t delete_entry(SSL *s, char *value, uint32_t *count) {
    size_t len = strlen(value);
    request(s, delete, 0, len);
    SSL_write(s, value, len);
    return response(s, count);
}

uint32_t change_passwd(SSL *s, uint8_t *kek) {
    uint32_t arg;
    request(s, passwd, 0, KEY_LEN);
    SSL_write(s, kek, KEY_LEN);
    return response(s, &arg);
}

SSL_CTX *client_ctx(X509 *sert, X509 *cert, EVP_PKEY *pk) {
    SSL_CTX *ctx;
    if ((ctx = SSL_CTX_new(TLSv1_2_client_method()))) {
        SSL_CTX_set_options(ctx, SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3);
        SSL_CTX_set_cipher_list(ctx, TLS_CIPHER_SUITE);
        SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT, NULL);
        SSL_CTX_set_verify_depth(ctx, 1);
        SSL_CTX_set_mode(ctx, SSL_MODE_AUTO_RETRY);

        X509_STORE *store = SSL_CTX_get_cert_store(ctx);
        X509_STORE_add_cert(store, sert);

        bool ok = SSL_CTX_use_certificate(ctx, cert) == 1;
        if (!ok || SSL_CTX_use_PrivateKey(ctx, pk) != 1) {
            SSL_CTX_free(ctx);
            ctx = NULL;
        }
    }
    return ctx;
}

SSL *client_socket(SSL_CTX *ctx, sockaddr6 *addr, struct timeval *timeout) {
    SSL *ssl = SSL_new(ctx);
    int fd   = socket(PF_INET6, SOCK_STREAM, IPPROTO_TCP);
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

    if (fd >= 0 && ssl && !connect(fd, (sockaddr *) addr, sizeof(*addr))) {
        SSL_set_fd(ssl, fd);
        if (SSL_connect(ssl) == 1) return ssl;
    }

    if (fd >= 0) close(fd);
    if (ssl) SSL_free(ssl);

    return NULL;
}
