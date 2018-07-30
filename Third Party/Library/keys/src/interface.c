// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <string.h>
#include <sys/types.h>
#include <ifaddrs.h>

#include "interface.h"

ssize_t active_interfaces(interface *ifs, size_t max) {
    struct ifaddrs *ifaddrs, *ifaddr;
    size_t count = 0;

    if (getifaddrs(&ifaddrs)) return -1;

    for (ifaddr = ifaddrs; ifaddr != NULL && count < max; ifaddr = ifaddr->ifa_next) {
        u_int loopback = ifaddr->ifa_flags & IFF_LOOPBACK;
        u_int active   = ifaddr->ifa_flags & IFF_RUNNING;
        if (ifaddr->ifa_addr->sa_family == AF_INET6 && active && !loopback) {
            struct sockaddr_in6 *in6 = (struct sockaddr_in6 *) ifaddr->ifa_addr;
            if (IN6_IS_ADDR_LINKLOCAL(&in6->sin6_addr)) {
                strncpy(ifs[count].name, ifaddr->ifa_name, IF_NAME_MAX);
                memcpy(&ifs[count].addr, &in6->sin6_addr, sizeof(struct in6_addr));
                ifs[count].index = in6->sin6_scope_id;
                count++;
            }
        }
    }
    freeifaddrs(ifaddrs);

    return count;
}
