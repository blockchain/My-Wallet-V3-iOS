// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <assert.h>
#include <errno.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <netdb.h>
#include <pthread.h>
#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>

#include "crypto.h"
#include "db.h"
#include "interface.h"
#include "mcast.h"
#include "client.h"
#include "init.h"
#include "pki.h"
#include "test.h"

static EVP_PKEY *pk, *sk;
static X509 *cert, *sert;
static SSL_CTX *ctx;
static sockaddr6 addr;

void start_client(uint8_t *passwd) {
    read_pem("client.pem", NULL, passwd, &pk, 2, &sert, &cert);
    read_pem("server.pem", NULL, passwd, &sk, 0);
    assert(ctx = client_ctx(sert, cert, pk));
    assert(find_server(sk, &addr, 3000, 30));
}

void stop_client() {
    SSL_CTX_free(ctx);
    X509_free(sert);
    X509_free(cert);
    EVP_PKEY_free(pk);
    EVP_PKEY_free(sk);
}

SSL *client(uint8_t *kek) {
    struct timeval timeout = { .tv_usec = 5000 };
    uint8_t data[KDFP_LEN];

    SSL *s = client_socket(ctx, &addr, &timeout);
    assert(s != NULL);

    SSL_read(s, &data, KDFP_LEN);
    SSL_write(s, kek, KEY_LEN);

    return s;
}

void disconnect(SSL *s) {
    SSL_shutdown(s);
    SSL_free(s);
}

SSL *add_entries(uint8_t *kek, uint32_t count, ...) {
    va_list ap;
    va_start(ap, count);
    for (uint32_t i = 0; i < count; i++) {
        uint32_t count, line;
        entry *entry;
        assert(entry = parse(va_arg(ap, char *), &line));
        SSL *s = client(kek);
        send_entry(s, add, 0, entry);
        assert(response(s, &count) == OK);
        disconnect(s);
        free(entry);
    }
    va_end(ap);
    return client(kek);
}

void init_server(kdfp *kdfp, uint8_t *passwd, size_t len, uint8_t kek[KEY_LEN]) {
    char *dir = temp_dir();
    init(dir, kdfp, passwd, len);
    derive_kek(passwd, len, kdfp, kek, KEY_LEN);
    passwd[len] = '\0';
}

pthread_t start_server(struct server_cfg *cfg, uint8_t *passwd) {
    static interface ifs[16];
    active_interfaces(ifs, 16);

    cfg->passwd = (char *) passwd;
    cfg->cert   = "server.pem";
    cfg->ifa    = &ifs[0];

    pthread_t tid;
    assert(pthread_create(&tid, NULL, &run_server, cfg) == 0);
    return tid;
}

void destroy_server(pthread_t tid, kdfp *kdfp, uint8_t kek[KEY_LEN]) {
    pthread_kill(tid, SIGINT);
    pthread_join(tid, NULL);

    unlink("server.pem");
    unlink("client.pem");
    idx *idx = db_load(kek, kdfp);
    db_destroy(idx);
}

void test_server() {
    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    uint8_t kek[KEY_LEN];
    uint8_t passwd[9];
    struct server_cfg cfg;

    init_server(&kdfp, passwd, sizeof(passwd) - 1, kek);
    pthread_t tid = start_server(&cfg, passwd);
    start_client(passwd);

    uint32_t count, line;
    entry *matches[64];
    entry *entry;
    SSL *s;

    // add
    s = client(kek);
    entry = parse("foo: bar\nbaz: quux", &line);
    send_entry(s, add, 0, entry);
    assert(response(s, &count) == OK);
    disconnect(s);

    s = client(kek);
    assert(find_entries(s, "bar",  2, matches) == 1);
    entry_equals(entry, matches[0]);
    assert(find_entries(s, "quux", 2, matches) == 1);
    entry_equals(entry, matches[0]);
    assert(find_entries(s, "foo",  2, matches) == 0);
    disconnect(s);

    // delete
    s = client(kek);
    assert(delete_entry(s, "bar", &count) == OK);
    disconnect(s);

    s = client(kek);
    assert(find_entries(s, "bar", 2, matches) == 0);
    disconnect(s);

    s = client(kek);
    assert(delete_entry(s, "bar", &count) == 1);
    disconnect(s);

    // edit
    free(entry);
    entry = parse("foo: baz", &line);

    s = add_entries(kek, 1, "foo: bar");
    send_entry(s, edit, 3, entry);
    SSL_write(s, "bar", 3);
    assert(response(s, &count) == OK);
    disconnect(s);

    s = client(kek);
    assert(find_entries(s, "bar", 2, matches) == 0);
    assert(find_entries(s, "baz", 2, matches) == 1);
    entry_equals(entry, matches[0]);
    disconnect(s);

    // delete aborts when > 1 match
    s = add_entries(kek, 2, "foo: bar\nbaz: quux", "foo: bar\nquux: baz");
    assert(delete_entry(s, "bar", &count) == 1 && count == 2);
    disconnect(s);

    // edit first match when > 1 match
    free(entry);
    entry = parse("foo: oof\nbaz: quux", &line);

    s = client(kek);
    send_entry(s, edit, 3, entry);
    SSL_write(s, "bar", 3);
    assert(response(s, &count) == OK && count == 2);
    disconnect(s);

    s = client(kek);
    assert(find_entries(s, "oof",  2, matches) == 1);
    entry_equals(entry, matches[0]);
    assert(find_entries(s, "bar",  2, matches) == 1);
    assert(find_entries(s, "quux", 2, matches) == 1);
    assert(find_entries(s, "baz",  2, matches) == 2);
    disconnect(s);

    free(entry);

    // rekey db
    s = client(kek);
    request(s, rekey, 0, 0);
    assert(response(s, &count) == OK);
    disconnect(s);

    // change password
    char *newpass = "newpass";
    uint8_t kek2[KEY_LEN];
    uint8_t data[16];

    derive_kek((uint8_t *) newpass, strlen(newpass), &kdfp, kek2, KEY_LEN);

    s = client(kek);
    assert(change_passwd(s, kek2) == OK);
    disconnect(s);

    s = client(kek);
    assert(SSL_read(s, data, 1) == 0);
    disconnect(s);

    s = client(kek2);
    assert(find_entries(s, "oof", 2, matches) == 1);
    assert(find_entries(s, "bar", 2, matches) == 1);
    close_entry(matches[0]);
    close_entry(matches[1]);
    disconnect(s);

    s = client(kek2);
    assert(change_passwd(s, kek) == OK);
    disconnect(s);

    // invalid command
    s = client(kek);
    request(s, 666, 0, 0);
    assert(response(s, &count) == 1);
    disconnect(s);

    // invalid entry
    s = client(kek);
    request(s, add, 0, 1);
    SSL_write(s, "A", 1);
    assert(response(s, &count) == 1);
    disconnect(s);

    destroy_server(tid, &kdfp, kek);
    stop_client();
}
