#define HAVE_MMAP 1

#ifdef BSD
#define HAVE_DECL_BE64ENC 1
#else
#define HAVE_DECL_BE64ENC 0
#endif

#ifndef __ANDROID__
#define HAVE_POSIX_MEMALIGN 1
#endif

#ifdef __ANDROID__
#include <sys/limits.h>
#include <sys/mman.h>
#define dprintf fdprintf
#define mlock(...) (0)
#endif
