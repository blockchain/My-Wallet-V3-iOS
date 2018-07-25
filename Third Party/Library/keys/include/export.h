#ifndef EXPORT_H
#define EXPORT_H

#include <openssl/ssl.h>

uint8_t **unique_ids(idx *, uint32_t *);
bool export_db(SSL *, idx *);
bool import_db(SSL *s, uint8_t *, uint32_t *);

uint32_t recv_export(SSL *, char *, kdfp *kdfp, uint8_t *);
uint32_t send_export(SSL *s, char *, bool (*)(kdfp *, uint8_t *));

bool prompt_export_key(kdfp *, uint8_t *);
bool prompt_import_key(kdfp *, uint8_t *);

int create_export(const char *, kdfp *);
int load_export(const char *, kdfp *);
uint8_t *next_entry(int, uint8_t *, uint32_t *);

#endif /* EXPORT_H */
