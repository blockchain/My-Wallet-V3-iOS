#ifndef DB_H
#define DB_H

#include <stdbool.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/param.h>

#include "crypto.h"

#define      ID_LEN       16
#define    KDFP_LEN       32
#define     KEY_LEN       (BOX_KEY_LEN * 2)
#define   INDEX_LEN(size) (size - (KDFP_LEN + KEY_LEN + BOX_LEN(0) * 2))
#define   ENTRY_LEN(size) (size - BOX_LEN(0))

#define       ID(term, n) (term->ids + (ID_LEN * n))

typedef struct {
    uint32_t count;
    uint32_t len;
    uint8_t *str;
    uint8_t *ids;
} term;

typedef struct {
    void    *addr;
    size_t   size;
    uint8_t *key;
    uint32_t count;
    term     terms[];
} idx;

typedef struct {
    uint32_t len;
    uint8_t *str;
} string;

typedef struct {
    string key;
    string val;
} attr;

typedef struct {
    void    *addr;
    size_t   size;
    uint32_t count;
    attr     attrs[];
} entry;

bool init_index(char *, uint8_t *, kdfp *);
idx *open_index(char *, kdfp *);
bool load_index(idx **, uint8_t *);
void close_index(idx *idx);
bool update_index(char *, idx *, uint8_t *, kdfp *, uint8_t *, entry *);
void search_index(idx *, uint8_t *, size_t, uint8_t **, uint32_t *);
bool rekey_index(char *, idx *, uint8_t *, uint8_t *);

char *entry_path(char *, uint8_t *, char *);
entry *load_entry(char *, uint8_t *);
bool store_entry(char *, uint8_t *, entry *);
void close_entry(entry *);
entry *read_entry(uint8_t *, size_t);
void write_entry(uint8_t *, entry *);
size_t entry_size(entry *);

entry *parse_entry(uint8_t *, uint32_t, uint32_t *);
void print_entry(int, entry *);

bool update_db(idx *, uint8_t *, kdfp *, uint8_t *, entry *, bool);
bool rekey_db(idx *, uint8_t *);
bool update_kek(idx *, uint8_t *);
void frob_utimes(idx *);

void *mmfile(char *, size_t *);
bool  mmsync(char *, void *, size_t);
void wipe(void *, size_t);

void write_kdfp(uint8_t *, kdfp *);
void read_kdfp(uint8_t *, kdfp *);

#endif /* DB_H */
