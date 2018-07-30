#ifndef MAIN_H
#define MAIN_H

#define PASSWD_LEN 16
#define PASSWD_MAX 256

int client(SSL *s, int, kdfp *, char *, uint32_t);

uint32_t  add_entry(SSL *, size_t, uint32_t *);
uint32_t edit_entry(SSL *, char *, uint32_t *);

void generate(size_t);
entry *editor(entry *);
bool parse_kdfp(kdfp *, char *);

bool   init_server(kdfp *, char *);
void *start_server(void *);

extern void server(interface *, X509 *, EVP_PKEY *);

static char *globarg(char *);
static void error(char *, ...);

#endif /* MAIN_H */
