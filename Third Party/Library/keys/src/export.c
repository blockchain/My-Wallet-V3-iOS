// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

#include "config.h"
#include "sysendian.h"
#include "crypto.h"
#include "db.h"
#include "mmap.h"
#include "net.h"
#include "export.h"

static uint8_t *srecv32(SSL *s, uint32_t *size) {
    *size = 0;
    SSL_read(s, size, sizeof(*size));
    *size = be32dec(size);
    return *size ? srecv(s, *size) : NULL;
}

static bool send_entry(SSL *s, entry *entry) {
    uint32_t size = entry_size(entry);
    uint8_t *addr = mmalloc(size);
    int rc = 0;

    if (addr) {
        be32enc(addr, size);
        rc  = SSL_write(s, addr, sizeof(uint32_t));
        write_entry(addr, entry);
        rc += SSL_write(s, addr, size);
        mfree(addr, size);
    }

    return rc > 0 && (size_t) rc == (size + sizeof(uint32_t));
}

uint8_t **unique_ids(idx *idx, uint32_t *count) {
    size_t size = 0;

    for (uint32_t i = 0; i < idx->count; i++) {
        term *term = &idx->terms[i];
        size += term->count * sizeof(uint8_t *);
    }

    uint8_t **ids  = malloc(size);
    uint32_t index = 0;

    for (uint32_t i = 0; ids && i < idx->count; i++) {
        term *term = &idx->terms[i];
        for (uint32_t j = 0; j < term->count; j++) {
            uint8_t *id = ID(term, j);
            for (uint32_t k = 0; id && k < index; k++) {
                if (!memcmp(ids[k], id, ID_LEN)) {
                    id = NULL;
                }
            }
            if (id) ids[index++] = id;
        }
    }

    *count = index;
    return ids;
}

bool export_db(SSL *s, idx *idx) {
    char path[PATH_MAX];
    uint32_t count;
    entry *entry;

    uint8_t **ids = unique_ids(idx, &count);
    bool ok = count > 0;

    int lock = open(".lock", O_CREAT | O_EXCL, 0600);
    if (lock != -1) {
        for (uint32_t i = 0; ok && i < count; i++) {
            uint8_t *id = *(ids + (sizeof(uint8_t) * i));
            ok = false;

            entry_path(path, id, NULL);
            if ((entry = load_entry(path, idx->key))) {
                ok = send_entry(s, entry);
                close_entry(entry);
            }
        }

        count = 0;
        SSL_write(s, &count, sizeof(count));

        close(lock);
        unlink(".lock");
    }

    free(ids);
    return ok;
}

bool import_db(SSL *s, uint8_t *kek, uint32_t *count) {
    uint32_t size;
    uint8_t *data;
    entry *entry;
    bool ok = true;

    *count = 0;

    while (ok && (data = srecv32(s, &size))) {
        uint8_t id[ID_LEN];
        randombytes(id, ID_LEN);

        if ((entry = read_entry(data, size))) {
            kdfp kdfp;
            idx *idx = open_index("index", &kdfp);
            load_index(&idx, kek);

            ok = update_db(idx, kek, &kdfp, id, entry, false);
            (*count)++;

            close_entry(entry);
            close_index(idx);
        }
    }

    return ok;
}

int create_export(const char *path, kdfp *kdfp) {
    int fd = open(path, O_RDWR | O_CREAT | O_TRUNC, 0600);
    if (fd >= 0) {
        uint8_t tmp[KDFP_LEN];
        write_kdfp(tmp, kdfp);
        if (write(fd, tmp, KDFP_LEN) != KDFP_LEN) {
            fd = -1;
            close(fd);
        }
    }
    return fd;
}

uint32_t recv_export(SSL *s, char *path, kdfp *kdfp, uint8_t *key) {
    uint32_t count = 0;
    uint32_t size, n;
    uint8_t *data;
    bool ok = true;

    int fd = create_export(path, kdfp);
    if (fd >= 0) {
        while (ok && (data = srecv32(s, &size))) {
            size_t len = BOX_LEN(size);
            box   *box = mmalloc(len);

            be32enc(&n, len);
            ok = box && write(fd, &n, sizeof(n)) > 0;

            if (ok) {
                memcpy(BOX_DATA(box), data, size);
                encrypt_box(key, box, size);
                ok = write(fd, box, len) > 0;
                mfree(box, len);
                count++;
            }

            mfree(data, size);
        }
        close(fd);
     }

    return count;
}

uint32_t send_export(SSL *s, char *path, bool (*derive)(kdfp *kdfp, uint8_t *key)) {
    uint32_t count = 0;
    uint32_t size, n;
    uint8_t *data;
    uint8_t key[KEY_LEN];
    kdfp kdfp;

    int fd = load_export(path, &kdfp);
    if (fd >= 0 && derive(&kdfp, key)) {
        while ((data = next_entry(fd, key, &size))) {
            be32enc(&n, size);
            SSL_write(s, &n, sizeof(n));
            SSL_write(s, data, size);
            mfree(data, size);
            count++;
        }
        n = 0;
        SSL_write(s, &n, sizeof(n));
    }

    if (fd >= 0) close(fd);
    OPENSSL_cleanse(key, KEY_LEN);

    return count;
}

int load_export(const char *path, kdfp *kdfp) {
    uint8_t data[KDFP_LEN];
    int fd;

    if ((fd = open(path, O_RDONLY)) == -1) goto error;
    if (read(fd, data, KDFP_LEN) != KDFP_LEN) goto error;

    read_kdfp(data, kdfp);

    return fd;

  error:

    if (fd >= 0) close(fd);
    return -1;
}

uint8_t *next_entry(int fd, uint8_t *key, uint32_t *size) {
    uint8_t *data = NULL;
    uint32_t len;

    if (read(fd, &len, sizeof(uint32_t)) == 4) {
        len = be32dec(&len);
        box *box = mmalloc(len);
        *size = len - BOX_LEN(0);

        if (box && (data = mmalloc(*size))) {
            read(fd, box, len);
            if (decrypt_box(key, box, *size)) {
                memcpy(data, BOX_DATA(box), *size);
            } else {
                mfree(data, *size);
                data = NULL;
            }
        }
        mfree(box, len);
    }

    return data;
}

bool prompt_export_key(kdfp *kdfp, uint8_t *key) {
    return prompt_kek("export passwd: ", kdfp, key, KEY_LEN, true);
}

bool prompt_import_key(kdfp *kdfp, uint8_t *key) {
    return prompt_kek("export passwd: ", kdfp, key, KEY_LEN, false);
}
