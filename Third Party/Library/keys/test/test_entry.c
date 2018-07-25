// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <assert.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#include "config.h"
#include "sysendian.h"
#include "crypto.h"
#include "db.h"
#include "test.h"

static void entry_valid(char *text, uint32_t count, ...) {
    uint32_t line;
    entry *entry = parse(text, &line);
    assert(entry && entry->count == count);
    va_list ap;
    va_start(ap, count);
    for (uint32_t i = 0; i < count; i++) {
        attr *attr = &entry->attrs[i];
        char *key = va_arg(ap, char *);
        char *val = va_arg(ap, char *);
        assert(attr->key.len == strlen(key) && !memcmp(key, attr->key.str, attr->key.len));
        assert(attr->val.len == strlen(val) && !memcmp(val, attr->val.str, attr->val.len));
    }
    va_end(ap);
    free(entry);
}

static void write_valid(char *text) {
    uint8_t data[1024];
    uint32_t line;

    entry *entry = parse(text, &line);
    write_entry(data, entry);
    uint32_t *counts = (uint32_t *) data;

    assert(be32dec(counts++) == entry->count);
    for (uint32_t i = 0; i < entry->count; i++) {
        string *key = &entry->attrs[i].key;
        string *val = &entry->attrs[i].val;
        assert(be32dec(counts++) == key->len);
        assert(be32dec(counts++) == val->len);
        uint8_t *data = (uint8_t *) counts;
        assert(!memcmp(data, key->str, key->len));
        data += key->len;
        assert(!memcmp(data, val->str, val->len));
        counts = (uint32_t *) (data + val->len);
    }
    free(entry);
}

static void read_valid(char *text) {
    uint8_t data[1024];
    uint32_t line;

    entry *parsed = parse(text, &line);
    write_entry(data, parsed);
    entry *read   = read_entry(data, 0);

    assert(parsed->count == read->count);
    for (uint32_t i = 0; i < parsed->count; i++) {
        string *key0 = &parsed->attrs[i].key;
        string *key1 =   &read->attrs[i].key;
        string *val0 = &parsed->attrs[i].val;
        string *val1 =   &read->attrs[i].val;
        assert(key0->len == key1->len);
        assert(val0->len == val1->len);
        assert(!memcmp(key0->str, key1->str, key0->len));
        assert(!memcmp(val0->str, val1->str, val0->len));
    }
    free(parsed);
    free(read);
}

void test_entry() {
    uint32_t line;

    entry_valid("foo: bar",     1, "foo", "bar");
    entry_valid("foo: bar\n",   1, "foo", "bar");
    entry_valid("  foo: bar\n", 1, "foo", "bar");
    entry_valid("foo  : bar\n", 1, "foo", "bar");
    entry_valid("foo: bar  \n", 1, "foo", "bar");
    entry_valid("foo:  bar \n", 1, "foo", "bar");

    entry_valid("foo: bar\nbaz: quux",   2, "foo", "bar", "baz", "quux");
    entry_valid("foo: bar\nbaz: quux\n", 2, "foo", "bar", "baz", "quux");

    entry_valid("\n  \n foo: bar\n\n",    1, "foo", "bar");
    entry_valid("\n foo: bar  \n  \n",    1, "foo", "bar");
    entry_valid("\nfoo: bar\n\nbaz:quux", 2, "foo", "bar", "baz", "quux");

    assert(parse("foo",    &line) == NULL);
    assert(parse("foo\n",  &line) == NULL);
    assert(parse("foo:",   &line) == NULL);
    assert(parse("foo:\n", &line) == NULL);
    assert(parse("foo: ",  &line) == NULL);
    assert(parse(":bar",   &line) == NULL);
    assert(parse("\n:bar", &line) == NULL);
    assert(parse(" :bar",  &line) == NULL);
    assert(parse(":bar\n", &line) == NULL);

    write_valid("foo: bar");
    write_valid("foo: bar\nbaz: quux");

    read_valid("foo: bar");
    read_valid("foo: bar\nbaz: quux");
}
