// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <assert.h>
#include <errno.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <netdb.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/stat.h>

#include "crypto.h"
#include "interface.h"
#include "mcast.h"
#include "protocol.h"
#include "client.h"
#include "pki.h"
#include "db.h"
#include "test.h"

extern int server_sock(SSL_CTX **, X509 *, EVP_PKEY *, interface *, sockaddr6 *);

void init_certs(EC_GROUP *group, char *passwd, char *server, char *client) {
    EVP_PKEY *server_pk, *client_pk;

    X509 *server_cert = make_server_cert(group, &server_pk, SERVER_CN);
    X509 *client_cert = make_client_cert(group, &client_pk, CLIENT_CN, server_cert);

    const EVP_MD *md = EVP_get_digestbyname(X509_DIGEST_NAME);
    X509_sign(server_cert, server_pk, md);
    X509_sign(client_cert, server_pk, md);

    write_pem(server, (uint8_t *) passwd, strlen(passwd), server_pk, group, 1, server_cert);
    write_pem(client, (uint8_t *) passwd, strlen(passwd), client_pk, group, 2, server_cert, client_cert);

    X509_free(server_cert);
    X509_free(client_cert);
    EVP_PKEY_free(server_pk);
    EVP_PKEY_free(client_pk);
}

static void cleanup(SSL_CTX **ctx, SSL **ssl, X509 **sert, X509 **cert, EVP_PKEY **sk, EVP_PKEY **pk) {
    if (*ssl) {
        SSL_shutdown(*ssl);
        SSL_free(*ssl);
    }
    if (*ctx)  SSL_CTX_free(*ctx);
    if (*sert) X509_free(*sert);
    if (*cert) X509_free(*cert);
    if (*sk)   EVP_PKEY_free(*sk);
    if (*pk)   EVP_PKEY_free(*pk);
    *ctx = NULL;
    *ssl = NULL;
    *sert = *cert = NULL;
    *sk   = *pk   = NULL;
}

void test_ssl() {
    interface ifs[16];
    active_interfaces(ifs, 16);

    char *passwd = "password";
    char *dir = chdir_temp_dir();

    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    uint8_t kek[KEY_LEN]  = { 0 };
    struct server_cfg cfg = {
        .passwd = passwd,
        .cert   = "server.pem",
        .ifa    = &ifs[0],
    };
    pthread_t tid;

    EC_GROUP *group = EC_GROUP_new_by_curve_name(OBJ_txt2nid(EC_CURVE_NAME));
    EC_GROUP_set_asn1_flag(group, OPENSSL_EC_NAMED_CURVE);
    init_certs(group, passwd, "server.pem", "client.pem");
    init_certs(group, passwd, "zerver.pem", "zlient.pem");
    init_index("index", kek, &kdfp);
    EC_GROUP_free(group);

    assert(pthread_create(&tid, NULL, &run_server, &cfg) == 0);

    struct timeval timeout = { .tv_usec = 500 };
    uint32_t usecs = 10000;
    sockaddr6 addr;
    X509 *cert = NULL, *sert = NULL;
    EVP_PKEY *pk = NULL, *sk = NULL;
    SSL_CTX *ctx = NULL;
    SSL *ssl = NULL;
    uint8_t data[KDFP_LEN];

    // client/server cert & pk mismatch
    read_pem("client.pem", NULL, passwd, &pk, 2, &sert, &cert);
    read_pem("server.pem", NULL, passwd, &sk, 0);

    assert(client_ctx(sert, cert, sk) == NULL);
    assert(server_sock(&ctx, sert, pk, cfg.ifa, &addr) == -1);
    assert(ctx == NULL);
    cleanup(&ctx, &ssl, &sert, &cert, &sk, &pk);

    // incorrect signature on pong
    read_pem("zerver.pem", NULL, passwd, &sk, 1, &sert);
    assert(find_server(sk, &addr, usecs, 30) == false);
    cleanup(&ctx, &ssl, &sert, &cert, &sk, &pk);

    // incorrect server certificate
    read_pem("server.pem", NULL, passwd, &sk, 1, &sert);
    assert(find_server(sk, &addr, usecs, 30) == true);
    cleanup(&ctx, &ssl, &sert, &cert, &sk, &pk);

    read_pem("client.pem", NULL, passwd, &pk, 2, &sert, &cert);
    X509_free(sert);
    read_pem("zerver.pem", NULL, passwd, &sk, 1, &sert);
    ctx = client_ctx(sert, cert, pk);
    assert(client_socket(ctx, &addr, &timeout) == NULL);
    assert(ERR_GET_REASON(ERR_get_error()) == SSL_R_CERTIFICATE_VERIFY_FAILED);
    cleanup(&ctx, &ssl, &sert, &cert, &sk, &pk);

    // incorrect client certificate
    read_pem("zlient.pem", NULL, passwd, &pk, 1, &cert);
    read_pem("server.pem", NULL, passwd, &sk, 1, &sert);
    ctx = client_ctx(sert, cert, pk);
    assert(client_socket(ctx, &addr, &timeout) == NULL);
    cleanup(&ctx, &ssl, &sert, &cert, &sk, &pk);

    // valid certificates
    read_pem("client.pem", NULL, passwd, &pk, 2, &sert, &cert);
    read_pem("server.pem", NULL, passwd, &sk, 0);
    ctx = client_ctx(sert, cert, pk);
    assert((ssl = client_socket(ctx, &addr, &timeout)));
    assert(SSL_read(ssl, &data, KDFP_LEN) == KDFP_LEN);
    cleanup(&ctx, &ssl, &sert, &cert, &sk, &pk);

    pthread_kill(tid, SIGINT);
    pthread_join(tid, NULL);

    unlink("server.pem");
    unlink("client.pem");
    unlink("zerver.pem");
    unlink("zlient.pem");
    unlink("index");

    rmdir_temp_dir(dir);
}
