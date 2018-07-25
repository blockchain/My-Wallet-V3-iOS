#ifndef CRYPTO_H
#define CRYPTO_H

#include <stdbool.h>
#include <stdint.h>
#include <sys/types.h>
#include <randombytes.h>

#define       IV_LEN  16
#define      TAG_LEN  16
#define     SALT_LEN  16
#define   BOX_IV_LEN  32
#define  BOX_TAG_LEN  32
#define  BOX_KEY_LEN  32

#define   PASSWD_MAX  256

#define  BOX_LEN(size)         ((sizeof(struct box) * 2) + size)
#define  BOX_PTR(base, offset) ((box *) (((uint8_t *) base) + offset))
#define BOX_DATA(box)          (box->data + sizeof(*box))

typedef struct kdfp {
    uint8_t salt[SALT_LEN];
    uint64_t N;
    uint32_t r;
    uint32_t p;
} kdfp;

typedef struct box {
    uint8_t  iv[BOX_TAG_LEN];
    uint8_t tag[BOX_TAG_LEN];
    uint8_t data[];
} box;

bool derive_kek(uint8_t *, size_t, kdfp *, uint8_t *, size_t);
bool prompt_kek(char *, kdfp *, uint8_t *, size_t, bool);

bool decrypt_box(uint8_t *, box *, size_t);
void encrypt_box(uint8_t *, box *, size_t);

#endif
