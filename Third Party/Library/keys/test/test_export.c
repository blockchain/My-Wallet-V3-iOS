// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <assert.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <fcntl.h>
#include <pthread.h>
#include <unistd.h>

#include "crypto.h"
#include "db.h"
#include "export.h"
#include "init.h"
#include "client.h"
#include "test.h"

static uint8_t kek[KEY_LEN];

bool fake_derive(kdfp *kdfp, uint8_t *key) {
    (void) kdfp;
    memcpy(key, kek, KEY_LEN);
    return true;
}

void test_export() {
    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    uint8_t passwd[9];
    uint8_t *data;
    struct server_cfg cfg;
    SSL *s;
    int fd;

    init_server(&kdfp, passwd, sizeof(passwd) - 1, kek);
    pthread_t tid = start_server(&cfg, passwd);
    start_client(passwd);

    uint32_t size, line, count;
    entry *entries[] = {
        parse("foo: bar\none: two", &line),
        parse("foo: baz\ndos:  ni", &line),
        parse("bar: fooz", &line),
        parse("baz: quux", &line),
    };
    uint32_t num = sizeof(entries) / sizeof(entry *);

    for (uint32_t i = 0; i < num; i++) {
        s = client(kek);
        send_entry(s, add, 0, entries[i]);
        assert(response(s, &count) == OK);
        disconnect(s);
    }

    s = client(kek);
    request(s, export, 0, 0);
    assert(recv_export(s, "export.dat", &kdfp, kek) == num);
    assert(response(s, &count) == OK);
    disconnect(s);

    // verify export contents

    assert((fd = load_export("export.dat", &kdfp)) > 0);
    for (uint32_t i = 0; i < num; i++) {
        entry *entry;
        assert(data = next_entry(fd, kek, &size));
        assert(entry = read_entry(data, size));
        entry_equals(entries[i], entry);
    }
    assert(!next_entry(fd, kek, &size));
    close(fd);

    // clear db

    assert((fd = load_export("export.dat", &kdfp)) > 0);
    while ((data = next_entry(fd, kek, &size))) {
        char val[32] = { 0 };
        entry *entry = read_entry(data, size);
        uint32_t len = entry->attrs[0].val.len;
        strncpy(val, (char *) entry->attrs[0].val.str, len);

        s = client(kek);
        assert(delete_entry(s, val, &count) == OK && count == 1);
        disconnect(s);

        close_entry(entry);
    }
    close(fd);

    // test import

    s = client(kek);
    request(s, import, 0, 0);
    assert(send_export(s, "export.dat", fake_derive) == num);
    assert(response(s, &count) == OK && count == num);
    disconnect(s);

    for (uint32_t i = 0; i < num; i++) {
        char val[32] = { 0 };
        entry *matches[2];

        uint32_t len = entries[i]->attrs[0].val.len;
        strncpy(val, (char *) entries[i]->attrs[0].val.str, len);

        s = client(kek);
        assert(find_entries(s, val, 2, matches) == 1);
        entry_equals(entries[i], matches[0]);
        disconnect(s);
    }

    // sanity test decryption failure

    corrupt("export.dat", KDFP_LEN + BOX_LEN(0));
    assert((fd = load_export("export.dat", &kdfp)) > 0);
    assert(!next_entry(fd, kek, &size));
    close(fd);

    unlink("export.dat");
    destroy_server(tid, &kdfp, kek);
    stop_client();
}
