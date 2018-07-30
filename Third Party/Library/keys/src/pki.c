// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <fcntl.h>
#include <unistd.h>
#include <openssl/rand.h>

#include "pki.h"

X509 *make_cert(EC_GROUP *group, EVP_PKEY **pk) {
    EC_KEY *key = EC_KEY_new();
    X509 *cert  = X509_new();
    *pk = EVP_PKEY_new();

    if (!key || !cert || !*pk)         goto error;
    if (!EC_KEY_set_group(key, group)) goto error;
    if (!EC_KEY_generate_key(key))     goto error;

    EVP_PKEY_assign_EC_KEY(*pk, key);

    unsigned long serial;
    RAND_bytes((unsigned char *) &serial, sizeof(serial));
    ASN1_INTEGER_set(X509_get_serialNumber(cert), serial >> 1);

    X509_set_version(cert, 2);
    X509_gmtime_adj(X509_get_notBefore(cert), 0);
    X509_gmtime_adj(X509_get_notAfter(cert),  60 * 60 * 24 * 3650L);
    X509_set_pubkey(cert, *pk);

    return cert;

error:

    if (key)  EC_KEY_free(key);
    if (cert) X509_free(cert);
    if (*pk)  EVP_PKEY_free(*pk);
    *pk = NULL;

    return NULL;
}

void X509V3_add_ext(X509V3_CTX *ctx, X509 *cert, int nid, char *value) {
    X509_EXTENSION *ex = X509V3_EXT_conf_nid(NULL, ctx, nid, value);
    X509_add_ext(cert, ex, -1);
    X509_EXTENSION_free(ex);
}

X509 *make_server_cert(EC_GROUP *group, EVP_PKEY **pk, const char *cn) {
    X509 *cert = make_cert(group, pk);
    if (cert) {
        X509_NAME *name = X509_get_subject_name(cert);
        X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, (unsigned char *) cn, -1, -1, 0);
        X509_set_issuer_name(cert, name);

        X509V3_CTX ctx;
        X509V3_set_ctx_nodb(&ctx);
        X509V3_set_ctx(&ctx, cert, cert, NULL, NULL, 0);
        X509V3_add_ext(&ctx, cert, NID_basic_constraints, "critical,CA:TRUE");
        X509V3_add_ext(&ctx, cert, NID_key_usage, "critical,keyCertSign,cRLSign,digitalSignature");
        X509V3_add_ext(&ctx, cert, NID_ext_key_usage, "serverAuth");
    }
    return cert;
}

X509 *make_client_cert(EC_GROUP *group, EVP_PKEY **pk, const char *cn, X509 *issuer) {
    X509 *cert = make_cert(group, pk);
    if (cert) {
        X509_NAME *name = X509_get_subject_name(cert);
        X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, (unsigned char *) cn, -1, -1, 0);

        X509_set_issuer_name(cert, X509_get_subject_name(issuer));

        X509V3_CTX ctx;
        X509V3_set_ctx_nodb(&ctx);
        X509V3_set_ctx(&ctx, issuer, cert, NULL, NULL, 0);
        X509V3_add_ext(&ctx, cert, NID_basic_constraints, "critical,CA:FALSE");
        X509V3_add_ext(&ctx, cert, NID_key_usage, "critical,digitalSignature");
        X509V3_add_ext(&ctx, cert, NID_ext_key_usage, "clientAuth");
    }
    return cert;
}

bool write_pem(char *path, uint8_t *passwd, size_t len, EVP_PKEY *key, EC_GROUP *group, size_t certs, ...) {
    const EVP_CIPHER *cipher = passwd ? EVP_aes_256_cbc() : NULL;
    va_list ap;
    BIO *out = NULL;

    int fd = open(path, O_WRONLY | O_CREAT | O_EXCL, 0600);
    if (fd >= 0 && (out = BIO_new_fd(fd, BIO_CLOSE))) {
        PEM_write_bio_ECPKParameters(out, group);
        PEM_write_bio_PKCS8PrivateKey(out, key, cipher, (char *) passwd, len, NULL, NULL);

        va_start(ap, certs);
        for (size_t i = 0; i < certs; i++) {
            X509 *cert = va_arg(ap, X509 *);
            PEM_write_bio_X509(out, cert);
        }
        va_end(ap);

        BIO_free(out);
    }
    return out != NULL;
}

void read_pem(char *path, pem_password_cb *cb, void *data, EVP_PKEY **pk, size_t certs, ...) {
    va_list ap;
    BIO *in;

    if ((in = BIO_new_file(path, "r"))) {
        *pk = PEM_read_bio_PrivateKey(in, NULL, cb, data);

        va_start(ap, certs);
        for (size_t i = 0; i < certs; i++) {
            X509 **cert = va_arg(ap, X509 **);
            *cert = PEM_read_bio_X509(in, NULL, NULL, NULL);
        }
        va_end(ap);

        BIO_free(in);
    }
}
