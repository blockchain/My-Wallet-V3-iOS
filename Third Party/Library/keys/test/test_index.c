// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <assert.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#include "crypto.h"
#include "db.h"
#include "test.h"

static uint8_t kek[KEY_LEN] = { 0 };

uint8_t *encode_id(uint64_t id) {
    static char str[ID_LEN + 1];
    sprintf(str, "%0*llu", (int) ID_LEN, id);
    return (uint8_t *) str;
}

idx *idx_load() {
    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    return db_load(kek, &kdfp);
}

idx *idx_update(uint64_t id, entry *entry) {
    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    idx *idx = idx_load();
    update_index("index", idx, kek, &kdfp, encode_id(id), entry);
    close_index(idx);
    return idx_load();
}

idx *idx_add_entry(uint64_t id, char *text) {
    uint32_t line;
    entry *e = parse_entry((uint8_t *) text, strlen(text), &line);
    idx *idx = idx_update(id, e);
    free(e);
    return idx;
}

idx *idx_delete_entry(uint64_t id) {
    entry e = { .count = 0 };
    return idx_update(id, &e);
}

idx *idx_with_entry(uint64_t id, char *text) {
    kdfp kdfp = { .N = 2, .r = 1, .p = 1};
    db_init(kek, &kdfp);
    return idx_add_entry(id, text);
}

void term_valid(term *term, uint32_t count, char *value, ...) {
    assert(term->len == strlen(value));
    assert(memcmp(term->str, value, strlen(value)) == 0);
    assert(term->count == count);

    va_list ap;
    va_start(ap, value);
    for (uint32_t i = 0; i < count; i++) {
        unsigned int n = va_arg(ap, unsigned int);
        uint8_t *id = encode_id(n);
        assert(memcmp(term->ids + (ID_LEN * i), id, ID_LEN) == 0);
    }
    va_end(ap);
}

void test_index() {
    idx *idx;

    // one index entry
    idx = idx_with_entry(1, "user: foo\n");
    assert(idx->count == 1);
    term_valid(&idx->terms[0], 1, "foo", 1);
    db_destroy(idx);

    // one index entry with 3 attrs
    idx = idx_with_entry(1, "user: foo\nemail: bar\nextra: baz\n");
    assert(idx->count == 3);
    term_valid(&idx->terms[0], 1, "foo", 1);
    term_valid(&idx->terms[1], 1, "bar", 1);
    term_valid(&idx->terms[2], 1, "baz", 1);
    db_destroy(idx);

    // add multiple index entries
    close_index(idx_with_entry(1, "user: foo\n"));
    close_index( idx_add_entry(2, "user: foo\n"));
    close_index( idx_add_entry(3, "user: foo\n"));
    idx =        idx_add_entry(4, "user: bar\n");
    assert(idx->count == 2);
    term_valid(&idx->terms[0], 3, "foo", 1, 2, 3);
    term_valid(&idx->terms[1], 1, "bar", 4);
    db_destroy(idx);

    // modify index entries
    close_index(idx_with_entry(1, "user: foo\n"));
    close_index( idx_add_entry(2, "user: foo\n"));
    close_index( idx_add_entry(3, "user: foo\n"));
    idx =        idx_add_entry(1, "user: bar\n");
    assert(idx->count == 2);
    term_valid(&idx->terms[0], 2, "foo", 2, 3);
    term_valid(&idx->terms[1], 1, "bar", 1);
    close_index(idx);
    idx =        idx_add_entry(2, "user: bar\n");
    assert(idx->count == 2);
    term_valid(&idx->terms[0], 1, "foo", 3);
    term_valid(&idx->terms[1], 2, "bar", 1, 2);
    close_index(idx);
    idx =        idx_add_entry(3, "user: bar\n");
    assert(idx->count == 1);
    term_valid(&idx->terms[0], 3, "bar", 1, 2, 3);
    db_destroy(idx);

    close_index(idx_with_entry(1, "user: foo\nemail: bar\n"));
    idx =        idx_add_entry(1, "user: baz\nemail: quux\n");
    assert(idx->count == 2);
    term_valid(&idx->terms[0], 1, "baz",  1);
    term_valid(&idx->terms[1], 1, "quux", 1);
    db_destroy(idx);

    // remove index entry from beginning, end, and middle
    close_index(idx_with_entry(1, "user: foo\n"));
    close_index( idx_add_entry(2, "user: foo\n"));
    close_index( idx_add_entry(3, "user: foo\n"));
    close_index( idx_add_entry(4, "user: foo\n"));
    idx =        idx_add_entry(5, "user: foo\n");
    assert(idx->count == 1);
    term_valid(&idx->terms[0], 5, "foo", 1, 2, 3, 4, 5);
    close_index(idx);
    idx =        idx_add_entry(1, "user: bar\n");
    assert(idx->count == 2);
    term_valid(&idx->terms[0], 4, "foo", 2, 3, 4, 5);
    term_valid(&idx->terms[1], 1, "bar", 1);
    close_index(idx);
    idx =        idx_add_entry(5, "user: bar\n");
    assert(idx->count == 2);
    term_valid(&idx->terms[0], 3, "foo", 2, 3, 4);
    term_valid(&idx->terms[1], 2, "bar", 1, 5);
    close_index(idx);
    idx =        idx_add_entry(3, "user: bar\n");
    assert(idx->count == 2);
    term_valid(&idx->terms[0], 2, "foo", 2, 4);
    term_valid(&idx->terms[1], 3, "bar", 1, 5, 3);
    db_destroy(idx);

    // delete index entries
    close_index(idx_with_entry(1, "user: foo\nemail: bar\nextra: baz\n"));
    idx =        idx_add_entry(2, "user: foo\n");
    assert(idx->count == 3);
    term_valid(&idx->terms[0], 2, "foo", 1, 2);
    term_valid(&idx->terms[1], 1, "bar", 1);
    term_valid(&idx->terms[2], 1, "baz", 1);
    close_index(idx);
    idx = idx_delete_entry(1);
    assert(idx->count == 1);
    term_valid(&idx->terms[0], 1, "foo", 2);
    close_index(idx);
    idx = idx_delete_entry(2);
    assert(idx->count == 0);
    db_destroy(idx);

    // skip index entries for keys named pass*
    idx = idx_with_entry(1, "user: foo\npass: bar\n");
    assert(idx->count == 1);
    term_valid(&idx->terms[0], 1, "foo", 1);
    db_destroy(idx);

    // duplicate values are coalesced
    idx = idx_with_entry(1, "user: foo\nname: abc\nemail: foo\nextra: foo\n");
    assert(idx->count == 2);
    term_valid(&idx->terms[0], 1, "foo", 1);
    term_valid(&idx->terms[1], 1, "abc", 1);
    db_destroy(idx);
}
