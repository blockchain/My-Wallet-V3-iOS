// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <assert.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <fcntl.h>
#include <libgen.h>
#include <unistd.h>
#include <sys/stat.h>

#include <crypto_secretbox.h>

#include "crypto.h"
#include "base64.h"
#include "db.h"
#include "test.h"

char *temp_dir() {
    static char dir[32];
    uint8_t rand[4];
    size_t len = 4;

    randombytes(rand, len);
    strcpy(dir, "test-");
    encode64url((uint8_t *) &dir[5], rand, &len, false);
    dir[len+5] = 0;

    return dir;
}

char *chdir_temp_dir() {
    char *dir = temp_dir();
    assert(!mkdir(dir, 0700));
    assert(!chdir(dir));
    return dir;
}

void rmdir_temp_dir(char *dir) {
    char path[1024];
    getcwd(path, sizeof(path));
    assert(!memcmp(dir, basename(path), strlen(dir)));
    assert(!chdir(".."));
    assert(!rmdir(path));
}

void db_init(uint8_t *kek, kdfp *kdfp) {
    chdir_temp_dir();
    assert(init_index("index", kek, kdfp) == true);
}

idx *db_load(uint8_t *kek, kdfp *kdfp) {
    idx *idx = open_index("index", kdfp);
    assert(idx != NULL);
    assert(load_index(&idx, kek) == true);
    return idx;
}

void entry_equals(entry *entry0, entry *entry1) {
    assert(entry0->count == entry1->count);
    for (uint32_t i = 0; i < entry0->count; i++) {
        string *key0 = &entry0->attrs[i].key;
        string *key1 = &entry1->attrs[i].key;
        string *val0 = &entry0->attrs[i].val;
        string *val1 = &entry1->attrs[i].val;
        assert(key0->len == key1->len && !memcmp(key0->str, key1->str, key0->len));
        assert(val0->len == val1->len && !memcmp(val0->str, val1->str, val0->len));
    }
    close_entry(entry1);
}

void db_destroy(idx *idx) {
    char path[1024];

    for (uint32_t i = 0; i < idx->count; i++) {
        term *term = &idx->terms[i];
        for (uint32_t j = 0; j < term->count; j++) {
            uint8_t *id = ID(term, j);
            entry_path(path, id, NULL);
            unlink(path);
        }
    }
    close_index(idx);
    unlink("index");

    getcwd(path, sizeof(path));
    assert(!chdir(".."));
    assert(!rmdir(path));
}

entry *parse(char *text, uint32_t *line) {
    return parse_entry((uint8_t *) text, strlen(text), line);
}

void corrupt(char *path, off_t offset) {
    uint8_t byte;
    int fd;

    assert((fd = open(path, O_RDWR)) > 0);
    assert(lseek(fd, offset, SEEK_SET) == offset);
    read(fd, &byte, 1);
    byte = ~byte;
    lseek(fd, -1, SEEK_CUR);
    assert(write(fd, &byte, 1) == 1);
    close(fd);
}

void *run_server(void *arg) {
    struct server_cfg *cfg = arg;
    EVP_PKEY *pk;
    X509 *cert;

    read_pem(cfg->cert, NULL, cfg->passwd, &pk, 1, &cert);
    stop = false;
    server(cfg->ifa, cert, pk);

    return NULL;
}

extern void test_db();
extern void test_entry();
extern void test_export();
extern void test_index();
extern void test_sanity();
extern void test_server();
extern void test_ssl();

int main(int argc, char **argv) {
    SSL_load_error_strings();
    SSL_library_init();

    assert(KEY_LEN          == 64);
    assert(crypto_secretbox == crypto_secretbox_xsalsa20poly1305);

    struct test {
        char *name;
        void(*test)();
    } tests[] = {
        { "db",     test_db     },
        { "entry",  test_entry  },
        { "export", test_export },
        { "index",  test_index  },
        { "sanity", test_sanity },
        { "server", test_server },
        { "ssl",    test_ssl    },
    };
    size_t count = sizeof(tests) / sizeof(struct test);

    if (argc > 1) {
        for (size_t i = 0; i < count; i++) {
            if (!strcmp(argv[1], tests[i].name)) {
                tests[i].test();
                goto done;
            }
        }
    }

    for (size_t i = 0; i < count; i ++) {
        printf("running tests: %s\n", tests[i].name);
        tests[i].test();
    }

  done:

    ERR_remove_state(0);
    CONF_modules_unload(1);
    ENGINE_cleanup();
    ERR_free_strings();
    EVP_cleanup();
    CRYPTO_cleanup_all_ex_data();
    sk_SSL_COMP_free(SSL_COMP_get_compression_methods());
}
