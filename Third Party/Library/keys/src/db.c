// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <ctype.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

#include <openssl/ssl.h>

#include "config.h"
#include "sysendian.h"
#include "crypto.h"
#include "db.h"
#include "base64.h"

static size_t index_size(idx *idx) {
    size_t size = -INDEX_LEN(0);
    size += sizeof(idx->count);
    for (uint32_t i = 0; i < idx->count; i++) {
        term *term = &idx->terms[i];
        size += sizeof(term->count) + sizeof(term->len);
        size += term->len;
        size += term->count * ID_LEN;
    }
    return size;
}

void write_kdfp(uint8_t *addr, kdfp *kdfp) {
    uint64_t *N  = (uint64_t *) (addr + SALT_LEN);
    uint32_t *r  = (uint32_t *) (N + 1);
    uint32_t *p  = (uint32_t *) (r + 1);
    memcpy(addr, kdfp->salt, SALT_LEN);
    be64enc(N, kdfp->N);
    be32enc(r, kdfp->r);
    be32enc(p, kdfp->p);
}

void read_kdfp(uint8_t *addr, kdfp *kdfp) {
    uint64_t *N  = (uint64_t *) (addr + SALT_LEN);
    uint32_t *r  = (uint32_t *) (N + 1);
    uint32_t *p  = (uint32_t *) (r + 1);
    memcpy(kdfp->salt, addr, SALT_LEN);
    kdfp->N = be64dec(N);
    kdfp->r = be32dec(r);
    kdfp->p = be32dec(p);
}

bool init_index(char *path, uint8_t *kek, kdfp *kdfp) {
    size_t size = -INDEX_LEN(0);
    size += sizeof(uint32_t);
    size += 1024 - (size % 1024);

    void    *addr = mmfile(path, &size);
    box     *kbox = BOX_PTR(addr, KDFP_LEN);
    box     *data = BOX_PTR(kbox, BOX_LEN(KEY_LEN));
    uint8_t *key  = BOX_DATA(kbox);

    if (!addr) return false;

    write_kdfp(addr, kdfp);
    randombytes(key, KEY_LEN);

    uint32_t *counts = (uint32_t *) BOX_DATA(data);
    *counts++ = htonl(0);

    encrypt_box(key, data, INDEX_LEN(size));
    encrypt_box(kek, kbox, KEY_LEN);

    return mmsync(path, addr, size);
}

idx *open_index(char *path, kdfp *kdfp) {
    size_t size = 0;
    void  *addr = mmfile(path, &size);
    idx   *idx  = NULL;
    if (addr && (idx = malloc(sizeof(*idx)))) {
        idx->addr  = addr;
        idx->size  = size;
        idx->count = 0;
        read_kdfp(addr, kdfp);
    }
    return idx;
}

bool load_index(idx **idx, uint8_t *kek) {
    box     *kbox = BOX_PTR((*idx)->addr, KDFP_LEN);
    box     *data = BOX_PTR(kbox, BOX_LEN(KEY_LEN));
    uint8_t *key  = BOX_DATA(kbox);
    size_t  size  = (*idx)->size;
    void    *addr;

    if (!decrypt_box(kek, kbox, KEY_LEN))         goto error;
    if (!decrypt_box(key, data, INDEX_LEN(size))) goto error;

    uint8_t *cursor = BOX_DATA(data);
    uint32_t *counts = (uint32_t *) cursor;
    uint32_t count = ntohl(*counts++);
    size = sizeof(**idx) + sizeof(term) * count;

    if (!(addr = realloc(*idx, size))) goto error;

    *idx          = addr;
    (*idx)->key   = key;
    (*idx)->count = count;

    for (uint32_t i = 0; i < count; i++) {
        term *term = &(*idx)->terms[i];
        term->count = ntohl(*counts++);
        term->len   = ntohl(*counts++);
        cursor = (uint8_t *) counts;
        term->str = cursor;
        cursor += term->len;
        term->ids = cursor;
        counts = (uint32_t *) (cursor + term->count * ID_LEN);
    }

    return true;

  error:

    close_index(*idx);
    *idx = NULL;
    return false;
}

bool rekey_index(char *path, idx *idx, uint8_t *kek, uint8_t *newk) {
    size_t size = idx->size;

    void    *addr = mmfile(path, &size);
    box     *kbox = BOX_PTR(addr, KDFP_LEN);
    box     *data = BOX_PTR(kbox, BOX_LEN(KEY_LEN));
    uint8_t *key  = BOX_DATA(kbox);

    if (!addr) return false;

    memcpy(addr, idx->addr, idx->size);
    memcpy(key,  newk,      KEY_LEN);

    encrypt_box(key, data, INDEX_LEN(size));
    encrypt_box(kek, kbox, KEY_LEN);

    return mmsync(path, addr, size);
}

void close_index(idx *idx) {
    if (idx) {
        wipe(idx->addr, idx->size);
        free(idx);
    }
}

static bool term_contains(term *t, uint8_t *value, size_t len) {
    bool match = false;
    for (uint32_t i = 0; !match && (i + len) <= t->len; i++) {
        const char *a = (const char *) t->str + i;
        const char *b = (const char *) value;
        match = strncasecmp(a, b, len) == 0;
    }
    return match;
}

void search_index(idx *idx, uint8_t *value, size_t len, uint8_t **ids, uint32_t *count) {
    uint32_t found = 0;
    for (uint32_t i = 0; i < idx->count && found < *count; i++) {
        term *term = &idx->terms[i];
        if (term->len >= len && term_contains(term, value, len)) {
            for (uint32_t j = 0; j < term->count && found < *count; j++) {
                *ids++ = ID(term, j);
                found++;
            }
        }
    }
    *count = found;
}

static const uint8_t WRITE = 0;
static const uint8_t SKIP  = 1;

static uint8_t *scan_attrs(entry *entry, size_t *size) {
    uint8_t *flags = calloc(entry->count, sizeof(uint8_t));

    for (uint32_t i = 0; flags && i < entry->count; i++) {
        string *key = &entry->attrs[i].key;
        string *val = &entry->attrs[i].val;

        if (flags[i] == SKIP) continue;

        if (key->len > 3 && !strncasecmp((char *) key->str, "pass", 4)) {
            flags[i] = SKIP;
            continue;
        }

        for (uint32_t j = i + 1; j < entry->count; j++) {
            string *next = &entry->attrs[j].val;
            if (val->len == next->len && !memcmp(val->str, next->str, val->len)) {
                flags[j] = SKIP;
            }
        }

        *size += sizeof(term) + val->len + ID_LEN;
    }

    return flags;
}

static uint8_t *write_term(uint8_t *data, term *term, uint8_t *id, bool append) {
    uint32_t *counts = (uint32_t *) data;
    *counts     = term->count;
    *(counts+1) = htonl(term->len);

    data = (uint8_t *) (counts + 2);
    memcpy(data, term->str, term->len);
    data += term->len;

    bool exists = false;
    for (uint32_t i = 0; i < term->count; i++) {
        uint8_t *term_id = term->ids + (ID_LEN * i);
        bool match = !memcmp(term_id, id, ID_LEN);
        if (append || !match) {
            memcpy(data, term_id, ID_LEN);
            data += ID_LEN;
            if (match) exists = true;
        } else if (match) {
            (*counts)--;
        }
    }

    if (append && !exists) {
        memcpy(data, id, ID_LEN);
        data += ID_LEN;
        (*counts)++;
    }

    *counts = htonl(*counts);

    return data;
}

bool update_index(char *path, idx *idx, uint8_t *kek, kdfp *kdfp, uint8_t *id, entry *entry) {
    size_t size    = index_size(idx);
    uint8_t *flags = scan_attrs(entry, &size);

    size += 1024 - (size % 1024);

    void    *addr = mmfile(path, &size);
    box     *kbox = BOX_PTR(addr, KDFP_LEN);
    box     *data = BOX_PTR(kbox, BOX_LEN(KEY_LEN));
    uint8_t *key  = BOX_DATA(kbox);

    if (!addr || !flags) return false;

    uint32_t *count = (uint32_t *) BOX_DATA(data);
    uint8_t *cursor = BOX_DATA(data) + sizeof(uint32_t);

    *count = idx->count;
    for (uint32_t i = 0; i < idx->count; i++) {
        term *term = &idx->terms[i];
        bool append = false;

        for (uint32_t j = 0; !append && j < entry->count; j++) {
            string *val = &entry->attrs[j].val;
            if (flags[j] == SKIP) continue;
            if (val->len == term->len && !memcmp(val->str, term->str, val->len)) {
                flags[j] = SKIP;
                append   = true;
                break;
            }
        }

        if (!append && term->count == 1 && !memcmp(term->ids, id, ID_LEN)) {
            (*count)--;
            continue;
        }

        cursor = write_term(cursor, term, id, append);
    }

    for (uint32_t i = 0; i < entry->count; i++) {
        string *val = &entry->attrs[i].val;
        if (flags[i] == WRITE) {
            term term  = { .len = val->len, .str = val->str };
            cursor = write_term(cursor, &term, id, true);
            (*count)++;
        }
    }

    *count = htonl(*count);
    free(flags);

    write_kdfp(addr, kdfp);
    memcpy(key, idx->key, KEY_LEN);
    encrypt_box(key, data, INDEX_LEN(size));
    encrypt_box(kek, kbox, KEY_LEN);

    return mmsync(path, addr, size);
}

size_t entry_size(entry *entry) {
    size_t size = sizeof(entry->count);
    for (uint32_t i = 0; i < entry->count; i++) {
        string *key = &entry->attrs[i].key;
        string *val = &entry->attrs[i].val;
        size += sizeof(key->len) + key->len;
        size += sizeof(val->len) + val->len;
    }
    return size;
}

entry *read_entry(uint8_t *data, size_t size) {
    uint32_t *counts = (uint32_t *) data;
    uint32_t count = ntohl(*counts++);

    entry *entry = malloc(sizeof(*entry) + sizeof(attr) * count);

    if (entry) {
        entry->addr  = data;
        entry->size  = size;
        entry->count = count;
        for (uint32_t i = 0; i < count; i++) {
            attr *attr = &entry->attrs[i];
            attr->key.len = ntohl(*counts++);
            attr->val.len = ntohl(*counts++);
            data = (uint8_t *) counts;
            attr->key.str = data;
            data += attr->key.len;
            attr->val.str = data;
            counts = (uint32_t *) (data + attr->val.len);
        }
    }

    return entry;
}

void write_entry(uint8_t *data, entry *entry) {
    uint32_t *counts = (uint32_t *) data;
    *counts++ = htonl(entry->count);
    for (uint32_t i = 0; i < entry->count; i++) {
        string *key = &entry->attrs[i].key;
        string *val = &entry->attrs[i].val;
        *counts++ = htonl(key->len);
        *counts++ = htonl(val->len);
        data = (uint8_t *) counts;
        memcpy(data, key->str, key->len);
        data += key->len;
        memcpy(data, val->str, val->len);
        counts = (uint32_t *) (data + val->len);
    }
}

entry *load_entry(char *path, uint8_t *key) {
    size_t size = 0;

    void *addr = mmfile(path, &size);
    box  *box  = addr;

    if (!addr) return NULL;

    if (!decrypt_box(key, box, ENTRY_LEN(size))) {
        munmap(addr, size);
        return NULL;
    }

    return read_entry(BOX_DATA(box), size);
}

bool store_entry(char *path, uint8_t *key, entry *entry) {
    size_t size = -ENTRY_LEN(0);
    size += entry_size(entry);
    size += 1024 - (size % 1024);

    void *addr = mmfile(path, &size);
    box   *box = addr;

    if (!addr) return false;

    write_entry(BOX_DATA(box), entry);
    encrypt_box(key, box, ENTRY_LEN(size));

    return mmsync(path, addr, size);
}

void close_entry(entry *entry) {
    if (entry) {
        wipe(entry->addr, entry->size);
        free(entry);
    }
}

entry *parse_entry(uint8_t *text, uint32_t len, uint32_t *line) {
    size_t attrs = (len / 4 / 2) + 1;
    entry *entry = malloc(sizeof(*entry) + sizeof(attr) * attrs);
    entry->count = 0;

    uint8_t *str = text;
    uint8_t *end = text + len;
    bool     key = true;
    len          = 0;
    *line        = 0;
    string *string;

    for (uint8_t *c = text; c < end; c++) {
        if (*c == '\n') (*line)++;

        if (isspace(*c) && !len) {
            str++;
            continue;
        }

        switch (*c) {
            case ':':
            case '\n':
                if ((*c == ':'  && !key) || !len) goto error;
                if ((*c == '\n' &&  key) || !len) goto error;
                break;
            default:
                len++;
                if (c < end - 1) continue;
        }

        while (len && isspace(str[len-1])) len--;
        string = key ? &entry->attrs[entry->count].key : &entry->attrs[entry->count].val;
        string->len = len;
        string->str = str;
        if (!key) entry->count++;
        key = !key;
        len = 0;
        str = c + 1;
    }

    if (key && !len && entry->count)
        return entry;

  error:

    free(entry);
    return NULL;
}

void print_entry(int fd, entry *entry) {
    uint32_t i, max = 0;
    for (i = 0; i < entry->count; i++) {
        string *key = &entry->attrs[i].key;
        if (key->len > max) max = key->len + 1;
    }
    for (i = 0; i < entry->count; i++) {
        string *key = &entry->attrs[i].key;
        string *val = &entry->attrs[i].val;
        dprintf(fd, "%*.*s: %.*s\n", max, key->len, key->str, val->len, val->str);
    }
}

char *entry_path(char *path, uint8_t *id, char *suffix) {
    size_t len = ID_LEN;
    encode64url((uint8_t *) path, id, &len, false);
    if (suffix) {
        memcpy(&path[len], suffix, strlen(suffix));
        len += strlen(suffix);
    }
    path[len] = '\0';
    return path;
}

bool update_db(idx *idx, uint8_t *kek, kdfp *kdfp, uint8_t *id, entry *entry, bool delete) {
    char path[PATH_MAX], work[PATH_MAX];
    bool ok  = false;

    int lock = open(".lock", O_CREAT | O_EXCL, 0600);
    if (lock != -1) {
        entry_path(path, id, NULL);
        entry_path(work, id, ".work");

        if (delete) entry->count = 0;

        if (update_index("index.work", idx, kek, kdfp, id, entry)) {
            if (!delete) {
                ok = store_entry(work, idx->key, entry);
                ok = ok && !rename(work, path);
            } else {
                ok = !unlink(path);
            }
            ok = ok && !rename("index.work", "index");
        }

        close(lock);
        unlink(".lock");
    }

    return ok;
}

bool rekey_db(idx *idx, uint8_t *kek) {
    char path[PATH_MAX], work[PATH_MAX];
    uint8_t key[KEY_LEN];
    bool ok  = false;

    int lock = open(".lock", O_CREAT | O_EXCL, 0600);
    if (lock != -1) {
        randombytes(key, KEY_LEN);

        ok = rekey_index("index.work", idx, kek, key);

        for (uint32_t i = 0; ok && i < idx->count; i++) {
            term *term = &idx->terms[i];
            entry *entry;

            for (uint32_t j = 0; ok && j < term->count; j++) {
                entry_path(path, ID(term, j), NULL);
                entry_path(work, ID(term, j), ".work");
                if ((entry = load_entry(path, idx->key))) {
                    ok = store_entry(work, key, entry);
                    ok = ok && !rename(work, path);
                    close_entry(entry);
                }
            }
        }

        ok = ok && !rename("index.work", "index");

        close(lock);
        unlink(".lock");
    }

    return ok;
}

bool update_kek(idx *idx, uint8_t *kek) {
    bool ok  = false;
    int lock = open(".lock", O_CREAT | O_EXCL, 0600);
    if (lock != -1) {
        ok = rekey_index("index.work", idx, kek, idx->key);
        ok = ok && !rename("index.work", "index");
        close(lock);
        unlink(".lock");
    }
    return ok;
}

void frob_utimes(idx *idx) {
    struct timeval times[2];
    char path[PATH_MAX];
    gettimeofday(&times[0], NULL);
    gettimeofday(&times[1], NULL);

    for (uint32_t i = 0; i < idx->count; i++) {
        term *term = &idx->terms[i];
        for (uint32_t j = 0; j < term->count; j++) {
            entry_path(path, ID(term, j), NULL);
            utimes(path, times);
        }
    }
    utimes("index", times);
}

void *mmfile(char *name, size_t *size) {
    void *addr = NULL;

    int fd = open(name, O_RDWR | O_CREAT, 0600);
    if (fd < 0) goto done;

    if (*size == 0) {
        struct stat stat;
        fstat(fd, &stat);
        *size = stat.st_size;
    } else {
        ftruncate(fd, *size);
    }

    addr = mmap(NULL, *size, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
    if (!addr) goto done;
    madvise(addr, *size, MADV_SEQUENTIAL | MADV_WILLNEED);
    if (mlock(addr, *size) != 0) {
        munmap(addr, *size);
        addr = NULL;
    }

  done:

    if (fd >= 0) close(fd);
    return addr;
}

bool mmsync(char *name, void *addr, size_t size) {
    bool ok = false;

    int fd = open(name, O_WRONLY);
    if (fd >= 0) {
        ssize_t ssize = write(fd, addr, size);
        ok = ssize > 0 && (size_t) ssize == size;
        ok = ok && !fsync(fd);
        close(fd);
    }
    wipe(addr, size);

    return ok;
}

void wipe(void *addr, size_t size) {
    OPENSSL_cleanse(addr, size);
    munmap(addr, size);
}
