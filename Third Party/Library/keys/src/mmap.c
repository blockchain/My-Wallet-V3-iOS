// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <sys/mman.h>
#include <openssl/ssl.h>
#include "mmap.h"

void *mmalloc(size_t size) {
    void *addr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, 0, 0);
    if (addr) {
        madvise(addr, size, MADV_SEQUENTIAL | MADV_WILLNEED);
        if (mlock(addr, size) != 0) {
            munmap(addr, size);
            addr = NULL;
        }
    }
    return addr;
}

void mfree(void *addr, size_t size) {
    if (addr) {
        OPENSSL_cleanse(addr, size);
        munmap(addr, size);
    }
}
