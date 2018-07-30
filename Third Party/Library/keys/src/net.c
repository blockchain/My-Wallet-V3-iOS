// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <stdint.h>

#include "mmap.h"
#include "net.h"

uint8_t *srecv(SSL *s, uint32_t size) {
    uint8_t *addr, *data;
    uint32_t need = size;

    if ((data = addr = mmalloc(size))) {
        while (need > 0) {
            int len = SSL_read(s, addr, need);
            if (len <= 0) goto error;
            need -= len;
            addr += len;
        }
        return data;
    }

  error:

    mfree(data, size);
    return NULL;
}
