#ifndef MMAP_H
#define MMAP_H

#include <sys/mman.h>

void *mmalloc(size_t);
void mfree(void *, size_t);

#endif /* MMAP_H */
