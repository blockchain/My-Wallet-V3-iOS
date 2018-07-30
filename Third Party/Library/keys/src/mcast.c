// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <unistd.h>

#include "mcast.h"

bool find_server(EVP_PKEY *pk, sockaddr6 *addr, uint32_t usecs, uint32_t retries) {
    bool ok = false;

    interface ifs[16];
    ssize_t count = active_interfaces(ifs, 16);
    if (count <= 0) return false;

    addr->sin6_family   = AF_INET6;
    addr->sin6_port     = htons(atoi(MCAST_PORT));
    addr->sin6_scope_id = ifs[0].index;
    inet_pton(AF_INET6, MCAST_HOST, &addr->sin6_addr);

    int fd = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
    if (fd == -1) return false;

    struct ipv6_mreq req = { .ipv6mr_interface = ifs[0].index };
    memcpy(&req.ipv6mr_multiaddr, &addr->sin6_addr, sizeof(struct in6_addr));
    if (setsockopt(fd, IPPROTO_IPV6, IPV6_JOIN_GROUP, &req, sizeof(req))) {
        return false;
    }

    struct timeval timeout = { .tv_usec = usecs / retries };
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

    sockaddr6 from6;
    socklen_t from_len = sizeof(from6);
    sockaddr *from = (sockaddr *) &from6;

    uint8_t ping[PING_LEN];
    struct pong pong;
    ssize_t len;

    RAND_bytes(ping, PING_LEN);

    for (uint32_t i = 0; !ok && i < retries; i++) {
        EVP_MD_CTX ctx;

        sendto(fd, ping, PING_LEN, 0, (sockaddr *) addr, sizeof(*addr));

        if ((len = recvfrom(fd, &pong, sizeof(pong), 0, from, &from_len)) > 0) {
            EVP_MD_CTX_init(&ctx);
            EVP_DigestVerifyInit(&ctx, NULL, EVP_sha256(), NULL, pk);
            EVP_DigestVerifyUpdate(&ctx, &ping, PING_LEN);
            EVP_DigestVerifyUpdate(&ctx, &pong, PONG_LEN);

            if (EVP_DigestVerifyFinal(&ctx, pong.sig, len) == 1) {
                memcpy(addr->sin6_addr.s6_addr, &pong.addr, 16);
                addr->sin6_port = pong.port;
                ok = true;
            }

            EVP_MD_CTX_cleanup(&ctx);
        }
    }
    close(fd);

    return ok;
}

int mcast_sock(interface *ifa, sockaddr6 *addr, char *host) {
    struct ipv6_mreq req = { .ipv6mr_interface = ifa->index };
    inet_pton(AF_INET6, host, &req.ipv6mr_multiaddr);

    int fd = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
    if (fd == -1 || bind(fd, (sockaddr *) addr, sizeof(*addr))) goto error;
    if (setsockopt(fd, IPPROTO_IPV6, IPV6_JOIN_GROUP, &req, sizeof(req))) goto error;

    return fd;

  error:

    if (fd >= 0) close(fd);
    return -1;
}

char *name(sockaddr6 *addr, socklen_t len) {
    static char host[NI_MAXHOST];
    int flags = NI_NUMERICHOST;
    getnameinfo((struct sockaddr *) addr, len, host, NI_MAXHOST, NULL, 0, flags);
    return host;
}
