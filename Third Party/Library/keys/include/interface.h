#ifndef INTERFACE_H
#define INTERFACE_H

#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/in.h>

#define IF_NAME_MAX 32

typedef struct {
    uint32_t index;
    char name[IF_NAME_MAX];
    struct in6_addr addr;
} interface;

ssize_t active_interfaces(interface *, size_t);

#endif /* INTERFACE_H */
