#ifndef TEST_H
#define TEST_H

#include <pthread.h>
#include <signal.h>
#include <openssl/err.h>
#include <openssl/ssl.h>

#include "interface.h"
#include "pki.h"
#include "db.h"
#include "tinymt64.h"

extern void server(interface *, X509 *, EVP_PKEY *);
extern volatile sig_atomic_t stop;

struct server_cfg {
    char *passwd;
    char *cert;
    interface *ifa;
};

char *temp_dir();
char *chdir_temp_dir();
void rmdir_temp_dir(char *);
void corrupt(char *, off_t);

void db_init(uint8_t *, kdfp *);
idx *db_load(uint8_t *, kdfp *);
void db_destroy(idx *);

uint8_t *encode_id(uint64_t);
idx *db_with_entry(char *, uint8_t *);

void entry_equals(entry *, entry *);

void init_server(kdfp *, uint8_t *, size_t, uint8_t *kek);
pthread_t start_server(struct server_cfg *, uint8_t *);
void destroy_server(pthread_t, kdfp *, uint8_t *);

void start_client(uint8_t *);
void stop_client();
SSL *client(uint8_t *);
void disconnect(SSL *s);

entry *parse(char *, uint32_t *);

uint64_t rand64(tinymt64_t *, uint64_t);
uint64_t time_us();

void *run_server(void *arg);

#endif /* TEST_H */
