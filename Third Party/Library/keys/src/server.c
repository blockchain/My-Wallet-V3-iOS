// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <poll.h>
#include <pthread.h>
#include <unistd.h>

#include <openssl/err.h>
#include <openssl/ssl.h>

#include "config.h"
#include "sysendian.h"
#include "db.h"
#include "export.h"
#include "protocol.h"
#include "mcast.h"
#include "mmap.h"
#include "net.h"
#include "server.h"

volatile sig_atomic_t stop = false;

static void handler(int sig) {
    if (!stop && sig == SIGINT) {
        stop = true;
        raise(sig);
    }
}

void server(interface *ifa, X509 *cert, EVP_PKEY *pk) {
    sockaddr6 saddr;
    sockaddr6 maddr = {
        .sin6_family   = AF_INET6,
        .sin6_port     = htons(atoi(MCAST_PORT)),
        .sin6_scope_id = ifa->index,
        .sin6_addr     = in6addr_any
    };
    EC_KEY *ecdh = EC_KEY_new_by_curve_name(OBJ_txt2nid(EC_CURVE_NAME));
    SSL_CTX *ctx;

    int ss = server_sock(&ctx, cert, pk, ifa, &saddr);
    int ms = mcast_sock(ifa, &maddr, MCAST_HOST);
    if (ss == -1 || ms == -1) goto done;

    SSL_CTX_set_tmp_ecdh(ctx, ecdh);

    struct timeval timeout = { .tv_sec = 5 };
    setsockopt(ss, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    setsockopt(ms, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    timeout.tv_sec = 0;

    struct sigaction sa  = {
        .sa_handler = handler,
        .sa_flags   = 0,
    };
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT,  &sa, NULL);
    sigaction(SIGPIPE, &sa, NULL);

    struct pollfd fds[] = {
        { .fd = ss, .events = POLLIN },
        { .fd = ms, .events = POLLIN },
    };

    while (!stop && poll(fds, 2, -1) >= 0) {
        if (fds[0].revents & POLLIN) {
            int cs = accept(ss, NULL, NULL);
            SSL *s = SSL_new(ctx);

            SSL_set_fd(s, cs);

            if (SSL_accept(s) == 1) {
                setsockopt(cs, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
                start(s);
                SSL_shutdown(s);
            }

            SSL_free(s);
            close(cs);
        }

        if (fds[1].revents & POLLIN) {
            pong(ms, pk, ifa, saddr.sin6_port);
        }
    }

  done:

    EVP_PKEY_free(pk);
    X509_free(cert);
    EC_KEY_free(ecdh);
    if (ctx) SSL_CTX_free(ctx);
    if (ss >= 0) close(ss);
    if (ms >= 0) close(ms);
    ERR_remove_state(0);
}

void start(SSL *s) {
    uint8_t kek[KEY_LEN];
    uint8_t data[KDFP_LEN];
    kdfp    kdfp;

    idx *idx = open_index("index", &kdfp);

    write_kdfp(data, &kdfp);
    SSL_write(s, data, KDFP_LEN);

    if (SSL_read(s, &kek, KEY_LEN) == KEY_LEN) {
        if (load_index(&idx, kek)) {
            loop(s, idx, &kdfp, kek);
            frob_utimes(idx);
        }
    }

    OPENSSL_cleanse(kek, KEY_LEN);
    close_index(idx);
}

void loop(SSL *s, idx *idx, kdfp *kdfp, uint8_t *kek) {
    message msg;

    while (SSL_read(s, &msg, sizeof(msg)) == sizeof(msg)) {
        uint32_t cmd = be32dec(&msg.cmd) & 0xFFFF;
        uint32_t arg = be32dec(&msg.arg);
        uint32_t len = be32dec(&msg.len);
        entry *entry = NULL;
        uint8_t *value = NULL;
        bool ok = false;

        if (!len || (value = srecv(s, len))) {
            uint32_t count = 0;
            uint8_t *matches[(cmd == find ? arg : 2)];

            if (cmd == add || cmd == edit) {
                if (len < 4 || !(entry = read_entry(value, len))) {
                    mfree(value, len);
                    reply(s, 1, 0, 0);
                    continue;
                }
                len   = arg;
                value = (cmd == edit) ? srecv(s, len) : NULL;
            }

            switch (cmd) {
                case add:
                    ok = add_entry(idx, kek, kdfp, entry);
                    break;
                case delete:
                    count = 2;
                    search_index(idx, value, len, matches, &count);
                    if (count != 1) break;
                    ok = delete_entry(idx, kek, kdfp, matches[0]);
                    break;
                case edit:
                    count = 2;
                    search_index(idx, value, len, matches, &count);
                    if (count < 1) break;
                    ok = update_db(idx, kek, kdfp, matches[0], entry, false);
                    break;
                case find:
                    count = arg;
                    search_index(idx, value, len, matches, &count);
                    ok = find_entry(s, idx, matches, count);
                    break;
                case passwd:
                    ok = len == KEY_LEN && update_kek(idx, value);
                    break;
                case rekey:
                    ok = rekey_db(idx, kek);
                    break;
                case export:
                    ok = export_db(s, idx);
                    break;
                case import:
                    ok = import_db(s, kek, &count);
                    break;
                default:
                    break;
            }

            reply(s, !ok, count, 0);

            close_entry(entry);
            mfree(value, len);

            if (cmd != find) break;
        }
    }
}

void reply(SSL *s, uint32_t status, uint32_t arg, uint32_t len) {
    message r;
    be32enc(&r.cmd, status);
    be32enc(&r.arg, arg);
    be32enc(&r.len, len);
    SSL_write(s, &r, sizeof(r));
}

static bool find_entry(SSL *s, idx *idx, uint8_t **matches, uint32_t count) {
    char path[PATH_MAX];
    uint8_t *data = NULL;

    for (uint32_t i = 0; i < count; i++) {
        entry_path(path, matches[i], NULL);
        entry *entry = load_entry(path, idx->key);
        if (entry) {
            uint32_t size = entry_size(entry);
            if ((data = mmalloc(size))) {
                write_entry(data, entry);
                reply(s, 0, count, size);
                SSL_write(s, data, size);
                mfree(data, size);
            }
            close_entry(entry);
        }
    }

    return true;
}

static bool add_entry(idx *idx, uint8_t *kek, kdfp *kdfp, entry *entry) {
    uint8_t id[ID_LEN];
    randombytes(id, ID_LEN);
    return update_db(idx, kek, kdfp, id, entry, false);
}

static bool delete_entry(idx *idx, uint8_t *kek, kdfp *kdfp, uint8_t *id) {
    char path[PATH_MAX];
    bool ok = false;

    entry_path(path, id, NULL);
    entry *entry = load_entry(path, idx->key);
    if (entry) {
        ok = update_db(idx, kek, kdfp, id, entry, true);
        close_entry(entry);
    }

    return ok;
}

void pong(int fd, EVP_PKEY *pk, interface *ifa, uint16_t port) {
    sockaddr6 from6;
    socklen_t from_len = sizeof(from6);
    sockaddr *from = (sockaddr *) &from6;

    uint8_t ping[PING_LEN];
    struct pong pong = { .port = port };
    memcpy(&pong.addr, &ifa->addr.s6_addr, 16);

    if (recvfrom(fd, ping, PING_LEN, 0, from, &from_len) == PING_LEN) {
        size_t slen = SIG_MAX;

        EVP_MD_CTX ctx;
        EVP_MD_CTX_init(&ctx);
        EVP_DigestSignInit(&ctx, NULL, EVP_sha256(), NULL, pk);
        EVP_DigestSignUpdate(&ctx, &ping, PING_LEN);
        EVP_DigestSignUpdate(&ctx, &pong, PONG_LEN);
        if (EVP_DigestSignFinal(&ctx, pong.sig, &slen) == 1) {
            sendto(fd, &pong, PONG_LEN + slen, 0, from, from_len);
        }

        EVP_MD_CTX_cleanup(&ctx);
    }
}

int server_sock(SSL_CTX **ctx, X509 *cert, EVP_PKEY *pk, interface *ifa, sockaddr6 *addr) {
    memset(addr, 0, sizeof(*addr));
    addr->sin6_family   = AF_INET6;
    addr->sin6_port     = 0;
    addr->sin6_scope_id = ifa->index;
    memcpy(&addr->sin6_addr, &ifa->addr, sizeof(struct in6_addr));

    int fd = socket(PF_INET6, SOCK_STREAM, IPPROTO_TCP);
    if (fd == -1 || bind(fd, (sockaddr *) addr, sizeof(*addr)) == -1) goto error;
    if (listen(fd, 128) == -1) goto error;

    socklen_t len = sizeof(*addr);
    getsockname(fd, (sockaddr *) addr, &len);

    if ((*ctx = SSL_CTX_new(TLSv1_2_server_method()))) {
        SSL_CTX_set_options(*ctx, SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3);
        SSL_CTX_set_options(*ctx, SSL_OP_SINGLE_ECDH_USE);
        SSL_CTX_set_cipher_list(*ctx, TLS_CIPHER_SUITE);
        SSL_CTX_set_verify(*ctx, SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT, NULL);
        SSL_CTX_set_verify_depth(*ctx, 1);

        bool ok = SSL_CTX_use_certificate(*ctx, cert) == 1;
        if (!ok || SSL_CTX_use_PrivateKey(*ctx, pk) != 1) {
            SSL_CTX_free(*ctx);
            goto error;
        }

        X509_STORE *store = SSL_CTX_get_cert_store(*ctx);
        X509_STORE_add_cert(store, cert);

        SSL_CTX_add_client_CA(*ctx, cert);
        SSL_CTX_set_mode(*ctx, SSL_MODE_AUTO_RETRY);

        return fd;
    }

  error:

    if (fd >= 0) close(fd);
    *ctx = NULL;
    return -1;
}
