// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <netdb.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <linux/if.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>

#include "interface.h"

struct req {
    struct nlmsghdr hdr;
    struct rtgenmsg gen;
};

ssize_t active_interfaces(interface *ifs, size_t max) {
    struct sockaddr_nl src = { .nl_family = AF_NETLINK };
    struct sockaddr_nl dst = { .nl_family = AF_NETLINK };

    int fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);

    if (fd == -1 || bind(fd, (struct sockaddr *) &src, sizeof(src)) == -1) {
        return -1;
    }

    socklen_t sock_len;
    getsockname(fd, (struct sockaddr *) &src, &sock_len);

    struct req req = {
        .hdr = {
            .nlmsg_len   = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
            .nlmsg_type  = RTM_GETLINK,
            .nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP,
            .nlmsg_seq   = 1,
            .nlmsg_pid   = src.nl_pid,
        },
        .gen = { .rtgen_family = AF_INET6 }
    };

    uint8_t reply[4096];
    struct rtattr *attr;
    size_t count = 0;
    size_t len;

    sendto(fd, &req, sizeof(req), 0, (struct sockaddr *) &dst, sizeof(dst));

    while ((len = recv(fd, reply, sizeof(reply), 0)) > 0 && count < max) {
        struct nlmsghdr *hdr = (struct nlmsghdr *) reply;

        if (hdr->nlmsg_type == NLMSG_DONE) break;

        for (; NLMSG_OK(hdr, len); hdr = NLMSG_NEXT(hdr, len)) {
            struct ifinfomsg *nif = NLMSG_DATA(hdr);
            size_t len = NLMSG_PAYLOAD(hdr, hdr->nlmsg_len);

            if (nif->ifi_flags & IFF_RUNNING && !(nif->ifi_flags & IFF_LOOPBACK)) {
                ifs[count].index = nif->ifi_index;
                for (attr = IFLA_RTA(nif); RTA_OK(attr, len); attr = RTA_NEXT(attr, len)) {
                    if (attr->rta_type == IFLA_IFNAME) {
                        strncpy(ifs[count].name, RTA_DATA(attr), IF_NAME_MAX);
                        break;
                    }
                }
                count++;
            }
        }
    }

    req.hdr.nlmsg_type = RTM_GETADDR;
    req.hdr.nlmsg_seq++;

    sendto(fd, &req, sizeof(req), 0, (struct sockaddr *) &dst, sizeof(dst));

    while ((len = recv(fd, reply, sizeof(reply), 0)) > 0) {
        struct nlmsghdr *hdr = (struct nlmsghdr *) reply;

        if (hdr->nlmsg_type == NLMSG_DONE) break;

        for (; NLMSG_OK(hdr, len); hdr = NLMSG_NEXT(hdr, len)) {
            struct ifaddrmsg *addr = NLMSG_DATA(hdr);
            size_t len = NLMSG_PAYLOAD(hdr, hdr->nlmsg_len);

            if (addr->ifa_scope != RT_SCOPE_LINK) continue;

            for (attr = IFA_RTA(addr); RTA_OK(attr, len); attr = RTA_NEXT(attr, len)) {
                if (attr->rta_type == IFA_ADDRESS) break;
            }

            for (size_t i = 0; i < count; i++) {
                if (ifs[i].index == (uint32_t) addr->ifa_index) {
                    memcpy(&ifs[i].addr, RTA_DATA(attr), sizeof(struct in6_addr));
                }
            }
        }
    }

    close(fd);

    return count;
}
