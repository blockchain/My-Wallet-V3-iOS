/**
 * Copyright (C) 2012 - Will Glozer. All rights reserved.
 *
 * Fast base64 codec that supports both standard and URL-safe
 * schemes with optional padding and without line splitting.
 */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include "base64.h"

static const int8_t encode_tables[128] = {
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
};

static const int8_t decode_tables[384] = {
    // standard base64
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1,  0, -1, -1,
    -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
    -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
    // url-safe base64
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62,  0, -1,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
    -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, 63,
    -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
    // + 128 zeros
};

static uint8_t *decode(uint8_t *dst, uint8_t *src, size_t *len, const int8_t *table, char pad) {
    size_t padding = (*len > 2 ? (src[*len-1] == pad) + (src[*len-2] == pad) : 0);
    size_t bytes   = (*len * 6 >> 3) - padding;
    size_t blocks  = (bytes / 3) * 3;
    size_t si = 0, di = 0;
    uint32_t n;

    if (*len < 2 || (!dst && !(dst = malloc(bytes)))) {
        *len = 0;
        return NULL;
    }

    while (di < blocks) {
        n  = table[src[si++]] << 18;
        n |= table[src[si++]] << 12;
        n |= table[src[si++]] <<  6;
        n |= table[src[si++]];
        dst[di++] = n >> 16;
        dst[di++] = n >>  8;
        dst[di++] = n;
    }

    if (di < bytes) {
        n = 0;
        switch (*len - si) {
            case 4: n |= table[src[si+3]];
            case 3: n |= table[src[si+2]] <<  6;
            case 2: n |= table[src[si+1]] << 12;
            case 1: n |= table[src[si+0]] << 18;
        }
        for (size_t r = 16; di < bytes; r -= 8) {
            dst[di++] = n >> r;
        }
    }

    *len = bytes;
    return dst;
}

static uint8_t *encode(uint8_t *dst, uint8_t *src, size_t *len, const int8_t *table, char pad) {
    size_t blocks = (*len / 3) * 3;
    size_t chars  = ((*len - 1) / 3 + 1) << 2;
    size_t tail   = *len - blocks;
    if (!pad && tail > 0) chars -= 3 - tail;
    size_t si = 0, di = 0;
    uint32_t n;

    if (*len == 0 || (!dst && !(dst = malloc(chars)))) {
        *len = 0;
        return NULL;
    }

    while (si < blocks) {
        n  = src[si++] << 16;
        n |= src[si++] <<  8;
        n |= src[si++];
        dst[di++] = table[(n >> 18) & 0x3f];
        dst[di++] = table[(n >> 12) & 0x3f];
        dst[di++] = table[(n >>  6) & 0x3f];
        dst[di++] = table[n         & 0x3f];
    }

    if (tail > 0) {
        n = src[si] << 10;
        if (tail == 2) n |= src[++si] << 2;

        dst[di++] = table[(n >> 12) & 0x3f];
        dst[di++] = table[(n >>  6) & 0x3f];
        if (tail == 2) dst[di++] = table[n & 0x3f];

        if (pad) {
            if (tail == 1) dst[di++] = pad;
            dst[di] = pad;
        }
    }

    *len = chars;
    return dst;
}

uint8_t *decode64(uint8_t *dst, uint8_t *src, size_t *len, bool pad) {
    return decode(dst, src, len, &decode_tables[0], pad ? '=' : 0);
}

uint8_t *encode64(uint8_t *dst, uint8_t *src, size_t *len, bool pad) {
    return encode(dst, src, len, &encode_tables[0], pad ? '=' : 0);
}

uint8_t *decode64url(uint8_t *dst, uint8_t *src, size_t *len, bool pad) {
    return decode(dst, src, len, &decode_tables[128], pad ? '.' : 0);
}

uint8_t *encode64url(uint8_t *dst, uint8_t *src, size_t *len, bool pad) {
    return encode(dst, src, len, &encode_tables[64], pad ? '.' : 0);
}

#ifdef TEST

#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <fcntl.h>
#include <unistd.h>

#define DECODE(DECODED, ENCODED, PAD) {               \
    size_t len = strlen(ENCODED);                     \
    uint8_t out[len * 2];                             \
    decode64(out, (uint8_t *) ENCODED, &len, PAD);    \
    assert(strlen(DECODED) == len);                   \
    assert(memcmp(DECODED, out, len) == 0);           \
}

#define DECODE_URL(DECODED, ENCODED, PAD) {           \
    size_t len = strlen(ENCODED);                     \
    uint8_t out[len * 2];                             \
    decode64url(out, (uint8_t *) ENCODED, &len, PAD); \
    assert(strlen(DECODED) == len);                   \
    assert(memcmp(DECODED, out, len) == 0);           \
}

#define ENCODE(ENCODED, DECODED, PAD) {               \
    size_t len = strlen((const char *)DECODED);       \
    uint8_t out[len * 2];                             \
    encode64(out, (uint8_t *) DECODED, &len, PAD);    \
    assert(strlen(ENCODED) == len);                   \
    assert(memcmp(ENCODED, out, len) == 0);           \
}

#define ENCODE_URL(ENCODED, DECODED, PAD) {           \
    size_t len = strlen((const char *)DECODED);       \
    uint8_t out[len * 2];                             \
    encode64url(out, (uint8_t *) DECODED, &len, PAD); \
    assert(strlen(ENCODED) == len);                   \
    assert(memcmp(ENCODED, out, len) == 0);           \
}

int main(int argc, char **argv) {
    DECODE("",       "",         true);
    DECODE("f",      "Zg==",     true);
    DECODE("fo",     "Zm8=",     true);
    DECODE("foo",    "Zm9v",     true);
    DECODE("foob",   "Zm9vYg==", true);
    DECODE("fooba",  "Zm9vYmE=", true);
    DECODE("foobar", "Zm9vYmFy", true);

    ENCODE("",         "",        true);
    ENCODE("Zg==",     "f",       true);
    ENCODE("Zm8=",     "fo",      true);
    ENCODE("Zm9v",     "foo",     true);
    ENCODE("Zm9vYg==", "foob",    true);
    ENCODE("Zm9vYmE=", "fooba",   true);
    ENCODE("Zm9vYmFy", "foobar",  true);

    DECODE("",       "",         false);
    DECODE("f",      "Zg",       false);
    DECODE("fo",     "Zm8",      false);
    DECODE("foo",    "Zm9v",     false);
    DECODE("foob",   "Zm9vYg",   false);
    DECODE("fooba",  "Zm9vYmE",  false);
    DECODE("foobar", "Zm9vYmFy", false);

    ENCODE("",         "",        false);
    ENCODE("Zg",       "f",       false);
    ENCODE("Zm8",      "fo",      false);
    ENCODE("Zm9v",     "foo",     false);
    ENCODE("Zm9vYg",   "foob",    false);
    ENCODE("Zm9vYmE",  "fooba",   false);
    ENCODE("Zm9vYmFy", "foobar",  false);

    uint8_t bytes[] = { 0x2a, 0xfe, 0xff, 0xfa, 0 };
    ENCODE    ("Kv7/+g==", bytes, true);
    ENCODE_URL("Kv7_-g..", bytes, true);
    ENCODE_URL("Kv7_-g",   bytes, false);


    uint64_t start, elapsed, nanos;
    mach_timebase_info_data_t tb;
    mach_timebase_info(&tb);
    size_t bytes2 = 1024 * 1024 * 10;
    size_t loops = 10;

    uint8_t *decoded = malloc(bytes2);
    int fd = open("/dev/urandom", O_RDONLY);
    assert(fd > 0);
    ssize_t rc  = read(fd, decoded, bytes2);
    assert(rc == (ssize_t) bytes2);
    close(fd);

    for (int x = 0; x < 10; x++) {
        uint8_t *encoded = malloc(bytes2 * 1.5);
        start = mach_absolute_time();
        uint64_t n = 0;

        for (size_t i = 0; i < loops; i++) {
            size_t len = bytes2;
            encode64(encoded, decoded, &len, true);
            n |= encoded[i];
        }

        elapsed = mach_absolute_time() - start;
        nanos = elapsed * tb.numer / tb.denom;

        size_t mb = (bytes2 * loops) / 1024 / 1024;
        printf("encode %fMB/s (%fms)\n", mb / (nanos / 1000000000.0), nanos / 1000000.0);

        free(encoded);
    }

    size_t orig_len = bytes2;
    uint8_t *encoded = encode64(NULL, decoded, &orig_len, true);

    for (int x = 0; x < 10; x++) {
        uint8_t *decoded = malloc(bytes2);
        start = mach_absolute_time();
        uint64_t n = 0;

        for (size_t i = 0; i < loops; i++) {
            size_t len = orig_len;
            decode64(decoded, encoded, &len, true);
            n |= decoded[i];
        }

        elapsed = mach_absolute_time() - start;
        nanos = elapsed * tb.numer / tb.denom;

        size_t mb = (bytes2 * loops) / 1024 / 1024;
        printf("decode %fMB/s (%fms)\n", mb / (nanos / 1000000000.0), nanos / 1000000.0);

        free(decoded);
    }

    return 0;
}

#endif
