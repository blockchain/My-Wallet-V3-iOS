// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <assert.h>
#include <string.h>

#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <crypto_secretbox.h>

#include "config.h"
#include "crypto.h"
#include "crypto_scrypt.h"

bool derive_kek(uint8_t *passwd, size_t len, kdfp *kdfp, uint8_t *kek, size_t klen) {
    uint8_t *salt = kdfp->salt;
    uint64_t N    = kdfp->N;
    uint64_t r    = kdfp->r;
    uint64_t p    = kdfp->p;
    return crypto_scrypt(passwd, len, salt, SALT_LEN, N, r, p, kek, klen) == 0;
}

bool prompt_kek(char *prompt, kdfp *kdfp, uint8_t *kek, size_t len, bool verify) {
  char passwd[PASSWD_MAX];
  bool ok = false;

  if (!EVP_read_pw_string(passwd, PASSWD_MAX - 1, prompt, verify)) {
      ok = derive_kek((uint8_t *) passwd, strlen(passwd), kdfp, kek, len);
  }
  OPENSSL_cleanse(passwd, PASSWD_MAX);

  return ok;
}

bool decrypt_gcm(uint8_t *key, uint8_t *iv, void *addr, size_t len, uint8_t *tag) {
    EVP_CIPHER_CTX ctx;
    int rc, tmp;

    EVP_CIPHER_CTX_init(&ctx);
    assert(EVP_DecryptInit_ex(&ctx, EVP_aes_256_gcm(), NULL, NULL, NULL));
    EVP_CIPHER_CTX_ctrl(&ctx, EVP_CTRL_GCM_SET_IVLEN, IV_LEN, NULL);
    EVP_CIPHER_CTX_ctrl(&ctx, EVP_CTRL_GCM_SET_TAG,  TAG_LEN, tag);
    assert(EVP_DecryptInit_ex(&ctx, NULL, NULL, key, iv));
    assert(EVP_DecryptUpdate(&ctx, addr, &tmp, addr, len));
    rc = EVP_CipherFinal_ex(&ctx, NULL, &tmp);
    EVP_CIPHER_CTX_cleanup(&ctx);

    return rc == 1;
}

void encrypt_gcm(uint8_t *key, uint8_t *iv, void *addr, size_t len, uint8_t *tag) {
    EVP_CIPHER_CTX ctx;
    int tmp;

    EVP_CIPHER_CTX_init(&ctx);
    assert(EVP_EncryptInit_ex(&ctx, EVP_aes_256_gcm(), NULL, NULL, NULL));
    EVP_CIPHER_CTX_ctrl(&ctx, EVP_CTRL_GCM_SET_IVLEN, IV_LEN, NULL);
    assert(EVP_EncryptInit_ex(&ctx, NULL, NULL, key, iv));
    assert(EVP_EncryptUpdate(&ctx, addr, &tmp, addr, len));
    assert(EVP_EncryptFinal_ex(&ctx, NULL, &tmp));
    EVP_CIPHER_CTX_ctrl(&ctx, EVP_CTRL_GCM_GET_TAG, TAG_LEN, tag);
    EVP_CIPHER_CTX_cleanup(&ctx);
}

bool decrypt_box(uint8_t *keys, box *outer, size_t len) {
    box *inner = (box *) outer->data;

    uint8_t *outer_key = keys;
    uint8_t *inner_key = keys + BOX_KEY_LEN;
    bool ok = false;

    if (decrypt_gcm(outer_key, outer->iv, outer->data, sizeof(box) + len, outer->tag)) {
        uint8_t *data = inner->tag;
        size_t inner_len = len + crypto_secretbox_ZEROBYTES;
        memset(data, 0, crypto_secretbox_BOXZEROBYTES);
        ok = crypto_secretbox_open(data, data, inner_len, inner->iv, inner_key) == 0;
    }

    return ok;
}

void encrypt_box(uint8_t *keys, box *outer, size_t len) {
    box *inner = (box *) outer->data;

    uint8_t *outer_key = keys;
    uint8_t *inner_key = keys + BOX_KEY_LEN;

    randombytes(outer->iv, BOX_IV_LEN);
    randombytes(inner->iv, BOX_IV_LEN);

    uint8_t *data = inner->tag;
    size_t inner_len = len + crypto_secretbox_ZEROBYTES;
    memset(data, 0, crypto_secretbox_ZEROBYTES);
    assert(crypto_secretbox(data, data, inner_len, inner->iv, inner_key) == 0);

    encrypt_gcm(outer_key, outer->iv, outer->data, sizeof(box) + len, outer->tag);
}
