// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <stdbool.h>
#include <stdint.h>
#include <sys/stat.h>
#include <unistd.h>

#include "base64.h"
#include "db.h"
#include "pki.h"
#include "protocol.h"
#include "init.h"

bool init(char *path, kdfp *kdfp, uint8_t *passwd, size_t len) {
    uint8_t bytes[len * 6 >> 3];
    uint8_t   kek[KEY_LEN];
    bool ok = false;

    EC_GROUP *group = EC_GROUP_new_by_curve_name(OBJ_txt2nid(EC_CURVE_NAME));
    EC_GROUP_set_asn1_flag(group, OPENSSL_EC_NAMED_CURVE);

    EVP_PKEY *server_pk, *client_pk;

    X509 *server_cert = make_server_cert(group, &server_pk, SERVER_CN);
    X509 *client_cert = make_client_cert(group, &client_pk, CLIENT_CN, server_cert);

    const EVP_MD *md = EVP_get_digestbyname(X509_DIGEST_NAME);
    if (!server_cert || !X509_sign(server_cert, server_pk, md)) goto done;
    if (!client_cert || !X509_sign(client_cert, server_pk, md)) goto done;

    if (mkdir(path, 0700) || chdir(path)) goto done;

    len = sizeof(bytes);
    randombytes(bytes, len);
    encode64url(passwd, bytes, &len, false);

    randombytes(kdfp->salt, SALT_LEN);

    if (!derive_kek(passwd, len, kdfp, kek, KEY_LEN)) goto done;
    if (!init_index("index", kek, kdfp))              goto done;

    ok = true && write_pem("server.pem", NULL, len, server_pk, group, 1, server_cert);
    ok = ok   && write_pem("client.pem", NULL, len, client_pk, group, 2, server_cert, client_cert);

  done:

    if (server_pk)   EVP_PKEY_free(server_pk);
    if (client_pk)   EVP_PKEY_free(client_pk);
    if (server_cert) X509_free(server_cert);
    if (client_cert) X509_free(client_cert);
    if (group)       EC_GROUP_free(group);

    return ok;
}

bool issue_client_cert(X509 *issuer, EVP_PKEY *ik, X509 **cert, EVP_PKEY **pk) {
    EC_GROUP *group = EC_GROUP_new_by_curve_name(OBJ_txt2nid(EC_CURVE_NAME));
    EC_GROUP_set_asn1_flag(group, OPENSSL_EC_NAMED_CURVE);

    const EVP_MD *md = EVP_get_digestbyname(X509_DIGEST_NAME);
    *cert = make_client_cert(group, pk, CLIENT_CN, issuer);

    return *cert && X509_sign(*cert, ik, md);
}
