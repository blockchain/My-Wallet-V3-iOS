// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <assert.h>
#include <errno.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>

#include "crypto.h"
#include "db.h"
#include "test.h"

static uint8_t kek[KEY_LEN] = { 0 };

idx *db_update(uint8_t *id, entry *entry, bool delete) {
    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    idx *idx = db_load(kek, &kdfp);
    update_db(idx, kek, &kdfp, id, entry, delete);
    close_index(idx);
    return db_load(kek, &kdfp);
}

idx *db_add_entry(char *text, uint8_t *id) {
    uint32_t line;
    entry *e = parse_entry((uint8_t *) text, strlen(text), &line);
    randombytes(id, ID_LEN);
    idx *idx = db_update(id, e, false);
    free(e);
    return idx;
}

idx *db_update_entry(char *text, uint8_t *id) {
    uint32_t line;
    entry *e = parse_entry((uint8_t *) text, strlen(text), &line);
    idx *idx = db_update(id, e, false);
    free(e);
    return idx;
}

idx *db_delete_entry(uint8_t *id) {
    entry e = { .count = 0 };
    return db_update(id, &e, true);
}

idx *db_with_entry(char *text, uint8_t *id) {
    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    db_init(kek, &kdfp);
    randombytes(id, ID_LEN);
    return db_add_entry(text, id);
}

void entry_deleted(idx *idx, uint8_t *id) {
    struct stat st;
    char path[PATH_MAX];

    entry_path(path, id, NULL);
    assert(stat(path, &st) && errno == ENOENT);

    for (uint32_t i = 0; i < idx->count; i++) {
        term *term = &idx->terms[i];
        for (uint32_t j = 0; j < term->count; j++) {
            assert(memcmp(term->ids + (ID_LEN * j), id, ID_LEN));
        }
    }
}

static void entry_valid(idx *idx, uint8_t *id) {
    struct stat st;
    char path[PATH_MAX];

    entry_path(path, id, NULL);
    assert(!stat(path, &st));
    assert(st.st_mode & S_IFREG);
    assert(st.st_size % 1024 == 0);

    entry *entry = load_entry(path, idx->key);
    assert(entry != NULL);

    for (uint32_t i = 0; i < idx->count; i++) {
        term *term = &idx->terms[i];
        bool expected = false;

        for (uint32_t j = 0; !expected && j < entry->count; j++) {
            string *val = &entry->attrs[j].val;
            if (term->len == val->len && !memcmp(term->str, val->str, term->len)) {
                expected = true;
            }
        }

        for (uint32_t j = 0; j < term->count; j++) {
            bool found = false;
            for (uint32_t k = 0; !found && k < term->count; k++) {
                found = !memcmp(term->ids + (ID_LEN * k), id, ID_LEN);
            }
            assert(found == expected);
        }
    }

    close_entry(entry);
}

void db_valid(idx *idx, uint32_t entries, uint32_t terms, ...) {
    struct stat st;
    assert(!stat("index", &st));
    assert(st.st_mode & S_IFREG);
    assert(st.st_size % 1024 == 0);

    assert(idx->count == terms);

    va_list ap;
    va_start(ap, terms);
    for (uint32_t i = 0; i < entries; i++) {
        uint8_t *id = va_arg(ap, uint8_t *);
        entry_valid(idx, id);
    }
    va_end(ap);
}

void search_valid(idx *idx, char *value, uint32_t expected, ...) {
    uint8_t *matches[32];
    uint32_t count = 32;
    search_index(idx, (uint8_t *) value, strlen(value), matches, &count);
    assert(count == expected);

    va_list ap;
    va_start(ap, expected);
    for (uint32_t i = 0; i < count; i++) {
        uint8_t *id = va_arg(ap, uint8_t *);
        assert(memcmp(id, matches[i], ID_LEN) == 0);
    }
    va_end(ap);
}

void rekey_valid(uint8_t *oldk, uint8_t *newk, uint32_t count, ...) {
    char path[PATH_MAX];
    entry *entry;

    va_list ap;
    va_start(ap, count);
    for (uint32_t i = 0; i < count; i++) {
        uint8_t *id = va_arg(ap, uint8_t *);
        entry_path(path, id, NULL);
        assert((entry = load_entry(path, oldk)) == NULL);
        assert((entry = load_entry(path, newk)) != NULL);
        close_entry(entry);
    }
    va_end(ap);
}

void test_db() {
    uint8_t id0[ID_LEN];
    uint8_t id1[ID_LEN];
    uint8_t id2[ID_LEN];
    idx *idx;

    // one entry
    idx = db_with_entry("user: foo", id0);
    db_valid(idx, 1, 1, id0);
    db_destroy(idx);

    // multiple entries
    close_index(db_with_entry("user: foo", id0));
    close_index( db_add_entry("user: bar", id1));
    idx =        db_add_entry("user: baz", id2);
    db_valid(idx, 3, 3, id0, id1, id2);
    db_destroy(idx);

    close_index(db_with_entry("user: foo", id0));
    idx =        db_add_entry("user: foo", id1);
    db_valid(idx, 2, 1, id0, id1);
    db_destroy(idx);

    close_index(db_with_entry("user: foo\nemail: bar",  id0));
    idx =        db_add_entry("user: baz\nemail: quux", id1);
    db_valid(idx, 2, 4, id0, id1);
    db_destroy(idx);

    // delete entry
    close_index(db_with_entry("user: foo", id0));
    close_index( db_add_entry("user: bar", id1));
    close_index( db_add_entry("user: baz", id2));
    idx =     db_delete_entry(id1);
    entry_deleted(idx, id1);
    db_valid(idx, 2, 2, id0, id2);
    db_destroy(idx);

    // update entry
    close_index(db_with_entry("user: foo", id0));
    close_index( db_add_entry("user: bar", id1));
    idx =     db_update_entry("user: baz", id1);
    db_valid(idx, 2, 2, id0, id1);
    db_destroy(idx);

    // search index
    close_index(db_with_entry("user: bar", id0));
    idx =        db_add_entry("user: baz", id1);
    search_valid(idx, "bar", 1, id0);
    search_valid(idx, "ba",  2, id0, id1);
    search_valid(idx, "A",   2, id0, id1);
    search_valid(idx, "foo", 0);
    db_destroy(idx);

    idx = db_with_entry("user: foo", id1);
    search_valid(idx, "foob", 0);
    db_destroy(idx);

    close_index(db_with_entry("user: bar", id0));
    close_index( db_add_entry("user: bar", id1));
    idx =        db_add_entry("user: bar", id2);
    search_valid(idx, "bar", 3, id0, id1, id2);
    db_destroy(idx);

    // rekey db
    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    uint8_t oldk[KEY_LEN], newk[KEY_LEN];

    close_index(db_with_entry("user: foo", id0));
    close_index( db_add_entry("user: foo", id1));
    idx =        db_add_entry("user: bar", id2);

    memcpy(oldk, idx->key, KEY_LEN);
    assert(rekey_db(idx, kek) == 1);
    close_index(idx);

    idx = db_load(kek, &kdfp);
    memcpy(newk, idx->key, KEY_LEN);
    db_valid(idx, 3, 2, id0, id1, id2);
    rekey_valid(oldk, newk, 3, id0, id1, id2);
    db_destroy(idx);

    // change kek
    close_index(db_with_entry("user: foo", id0));
    close_index( db_add_entry("user: bar", id1));
    idx =        db_add_entry("user: baz", id2);

    memset(kek, 'A', sizeof(kek));
    assert(update_kek(idx, kek));
    close_index(idx);

    idx = db_load(kek, &kdfp);
    db_valid(idx, 3, 3, id0, id1, id2);
    db_destroy(idx);
}
