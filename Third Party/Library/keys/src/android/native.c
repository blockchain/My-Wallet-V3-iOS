// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <errno.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <netdb.h>
#include <unistd.h>

#include <linux/in.h>
#include <android/log.h>

#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/ssl.h>
#include <openssl/rand.h>

#include "crypto.h"
#include "db.h"
#include "init.h"
#include "interface.h"
#include "mcast.h"
#include "pki.h"
#include "native.h"

#define     IF_MAX  16
#define PASSWD_LEN  8

extern volatile sig_atomic_t stop;
extern void server(interface *, X509 *, EVP_PKEY *);

static pthread_t thread;

void *run_server(void *arg) {
    interface *ifa = (interface *) arg;

    EVP_PKEY *pk;
    X509 *cert;
    read_pem("server.pem", NULL, NULL, &pk, 1, &cert);

    stop = false;
    server(ifa, cert, pk);
    free(ifa);

    return NULL;
}

void JNICALL start_server(JNIEnv *env, jobject o, jstring path, jint index) {
    interface ifs[IF_MAX];
    active_interfaces(ifs, IF_MAX);

    const char *chars = (*env)->GetStringUTFChars(env, path, 0);

    if (chdir(chars) == 0) {
        interface *ifa = malloc(sizeof(interface));
        memcpy(ifa, &ifs[index], sizeof(interface));
        pthread_create(&thread, NULL, &run_server, ifa);
    }

    (*env)->ReleaseStringUTFChars(env, path, chars);
}

void JNICALL stop_server(JNIEnv *env, jobject o) {
    pthread_kill(thread, SIGINT);
}

jstring JNICALL initialize(JNIEnv *env, jclass cls, jstring path, jlong N, jlong r, jlong p) {
    uint8_t passwd[PASSWD_LEN + 1] = { 0 };
    kdfp kdfp = {
        .N = N,
        .r = r,
        .p = p
    };
    jstring str = NULL;
    const char *chars = (*env)->GetStringUTFChars(env, path, 0);

    if (init(chars, &kdfp, passwd, PASSWD_LEN)) {
        str = (*env)->NewStringUTF(env, passwd);
    } else {
        jclass e = (*env)->FindClass(env, "java/lang/IllegalStateException");
        (*env)->ThrowNew(env, e, "Initialization failed");
    }

    (*env)->ReleaseStringUTFChars(env, path, chars);

    return str;
}

jobjectArray JNICALL interfaces(JNIEnv *env, jclass cls) {
    interface ifs[IF_MAX];
    ssize_t count = active_interfaces(ifs, IF_MAX);
    cls = (*env)->FindClass(env, "com/lambdaworks/keys/NetworkInterface");
    jobjectArray array = (*env)->NewObjectArray(env, count, cls, NULL);
    for (ssize_t i = 0; i < count; i++) {
        jstring name = (*env)->NewStringUTF(env, ifs[i].name);
        jbyteArray addr = (*env)->NewByteArray(env, 16);
        jmethodID mid = (*env)->GetMethodID(env, cls, "<init>", "(Ljava/lang/String;I[B)V");
        (*env)->SetByteArrayRegion(env, addr, 0, 16, (jbyte *) ifs[i].addr.s6_addr);
        jobject nif = (*env)->NewObject(env, cls, mid, name, ifs[i].index, addr);
        (*env)->SetObjectArrayElement(env, array, i, nif);
    }
    return array;
}

jstring JNICALL issue_cert(JNIEnv *env, jclass cls, jstring path) {
    EVP_PKEY *ik, *pk;
    X509 *issuer, *cert;
    char pem[PATH_MAX];
    jstring str;

    const char *chars = (*env)->GetStringUTFChars(env, path, 0);
    snprintf(pem, PATH_MAX, "%s/server.pem", chars);
    (*env)->ReleaseStringUTFChars(env, path, chars);

    read_pem(pem, NULL, NULL, &ik, 1, &issuer);

    if (issue_client_cert(issuer, ik, &cert, &pk)) {
        BIO *out = BIO_new(BIO_s_mem());
        PEM_write_bio_PKCS8PrivateKey(out, pk, NULL, NULL, 0, NULL, NULL);
        PEM_write_bio_X509(out, issuer);
        PEM_write_bio_X509(out, cert);
        BIO_write(out, "\0", 1);

        BIO_get_mem_data(out, &chars);
        str = (*env)->NewStringUTF(env, chars);
        BIO_free(out);
    } else {
        jclass e = (*env)->FindClass(env, "java/lang/IllegalStateException");
        (*env)->ThrowNew(env, e, "Cert issue failed");
    }

    EVP_PKEY_free(ik);
    EVP_PKEY_free(pk);
    X509_free(issuer);
    X509_free(cert);

    return str;
}

jobject JNICALL version(JNIEnv *env, jclass cls) {
    cls = (*env)->FindClass(env, "com/lambdaworks/keys/Version");
    jstring openssl = (*env)->NewStringUTF(env, OPENSSL_VERSION_TEXT);
    jmethodID mid = (*env)->GetMethodID(env, cls, "<init>", "(Ljava/lang/String;)V");
    return (*env)->NewObject(env, cls, mid, openssl);
}

static const JNINativeMethod core_methods[] = {
    { "initialize", "(Ljava/lang/String;JJJ)Ljava/lang/String;",  (void *) initialize },
    { "interfaces", "()[Lcom/lambdaworks/keys/NetworkInterface;", (void *) interfaces },
    { "issueCert",  "(Ljava/lang/String;)Ljava/lang/String;",     (void *) issue_cert },
    { "version",    "()Lcom/lambdaworks/keys/Version;",           (void *) version    },
};

static const JNINativeMethod service_methods[] = {
    { "start",      "(Ljava/lang/String;I)V", (void *) start_server },
    { "stop",       "()V",                    (void *) stop_server  },
};

jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env;

    if ((*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) {
        return -1;
    }

    native_methods natives[] = {
        METHODS("KeysCore",       core_methods),
        METHODS("KeysService", service_methods),
    };

    for (size_t i = 0; i < sizeof(natives) / sizeof(native_methods); i++) {
        native_methods n = natives[i];
        jclass cls = (*env)->FindClass(env, n.class);
        if ((*env)->RegisterNatives(env, cls, n.methods, n.count) != JNI_OK) {
            return -1;
        }
    }

    SSL_load_error_strings();
    SSL_library_init();
    OpenSSL_add_all_algorithms();

    return JNI_VERSION_1_6;
}
