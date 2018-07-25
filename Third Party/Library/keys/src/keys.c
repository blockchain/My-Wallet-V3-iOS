// Copyright (C) 2013 - Will Glozer. All rights reserved.

#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <fcntl.h>
#include <getopt.h>
#include <glob.h>
#include <libgen.h>
#include <sys/param.h>
#include <pthread.h>
#include <signal.h>
#include <unistd.h>

#include "config.h"
#include "client.h"
#include "base64.h"
#include "interface.h"
#include "protocol.h"
#include "pki.h"
#include "mcast.h"
#include "init.h"
#include "keys.h"
#include "export.h"

static entry template = {
    .count = 4,
    .attrs = {
        { {4, (uint8_t *)     "name"}, { .len = 0 } },
        { {8, (uint8_t *) "username"}, { .len = 0 } },
        { {8, (uint8_t *) "password"}, { .len = 0 } },
        { {5, (uint8_t *)    "extra"}, { .len = 0 } },
    }
};

static char *usage =
    "Usage: keys [options] <arg>                         \n"
    "  Options:                                          \n"
    "    -a, --add               Add entry               \n"
    "    -d, --delete            Delete entry            \n"
    "    -e, --edit              Edit entry              \n"
    "    -g, --gen      <n>      Generate password       \n"
    "    -l, --limit    <n>      Limit number of matches \n"
    "        --cert     <file>   Client certificate      \n"
    "        --dir      <dir>    Set working directory   \n"
    "        --export   <file>   Export db to file       \n"
    "        --import   <file>   Import db from file     \n"
    "        --kdfp     <N,r,p>  Scrypt KDF parameters   \n"
    "        --passwd            Change db password      \n"
    "        --rekey             Rekey entire db         \n"
    "        --timeout  <secs>   Set network timeout     \n"
    "  Server:                                           \n"
    "        --init     <dir>    Initialize db & certs   \n"
    "        --server            Run server              \n";

int main(int argc, char **argv) {
    SSL_load_error_strings();
    SSL_library_init();
    OpenSSL_add_all_algorithms();

    struct timeval timeout = { .tv_sec = 5 };
    kdfp kdfp = { .N = 16384, .r = 8, .p = 1 };
    int cmd        = 0;
    int init       = 0;
    int serve      = 0;
    char *arg      = NULL;
    char *pem      = "client.pem";
    char *dir      = "~/.keys";
    uint32_t limit = 1;
    int c, status  = 1;

    struct option opts[] = {
        { "add",     no_argument,       NULL,   'a'    },
        { "delete",  required_argument, NULL,   'd'    },
        { "edit",    required_argument, NULL,   'e'    },
        { "gen",     required_argument, NULL,   'g'    },
        { "limit",   required_argument, NULL,   'l'    },
        { "cert",    required_argument, NULL,   'C'    },
        { "dir",     required_argument, NULL,   'D'    },
        { "export",  required_argument, &cmd,   export },
        { "import",  required_argument, &cmd,   import },
        { "passwd",  no_argument,       &cmd,   passwd },
        { "rekey",   no_argument,       &cmd,   rekey  },
        { "timeout", required_argument, NULL,   'T'    },
        { "init",    required_argument, NULL,   'I'    },
        { "kdfp",    required_argument, NULL,   'S'    },
        { "server",  no_argument,       &serve, true   },
        { "help",    no_argument,       NULL,   '?'    },
        { NULL,      0,                 NULL,    0     }
    };

    while ((c = getopt_long(argc, argv, "ad:e:g:l:T:I:S:C:D:?", opts, NULL)) != -1) {
        switch (c) {
            case 'a':
                cmd = add;
                arg = optarg;
                break;
            case 'd':
                cmd = delete;
                arg = optarg;
                break;
            case 'e':
                cmd = edit;
                arg = optarg;
                break;
            case 'g':
                generate(strtoul(optarg, NULL, 10));
                return 0;
            case 'C':
                pem = globarg(optarg);
                break;
            case 'D':
                dir = optarg;
                break;
            case 'l':
                limit = strtoul(optarg, NULL, 10);
                break;
            case 't':
                timeout.tv_sec = strtoul(optarg, NULL, 10);
                break;
            case 'I':
                init = true;
                dir  = optarg;
                break;
            case 'S':
                if (!parse_kdfp(&kdfp, optarg)) goto done;
                break;
            case 0:
                if (cmd == import || cmd == export) {
                    arg = globarg(optarg);
                }
                break;
            case '?':
            case ':':
            default:
                printf("%s\n", usage);
                return 1;
        }
    }

    pthread_t tid = NULL;

    dir = globarg(dir);
    cmd = (cmd == 0 && optind < argc) ? find : cmd;
    arg = (cmd == find ? argv[optind] : arg);

    if (init) {
        if (!init_server(&kdfp, dir)) goto done;
    } else if (chdir(dir) == -1) {
        error("chdir '%s': %s\n", dir, strerror(errno));
        goto done;
    }

    if (serve) {
        pthread_create(&tid, NULL, start_server, "server.pem");
    }

    if (cmd > 0) {
        EVP_PKEY *pk, *sk;
        X509 *cert, *sert;
        sockaddr6 addr;

        read_pem(pem, NULL, NULL, &pk, 2, &sert, &cert);
        sk = X509_get_pubkey(sert);

        if (find_server(sk, &addr, 1000000, 20)) {
            printf("keys server at %s\n", name(&addr, sizeof(addr)));
            SSL_CTX *ctx = client_ctx(sert, cert, pk);
            SSL *s = client_socket(ctx, &addr, &timeout);

            if (ctx && s) {
                status = client(s, cmd, &kdfp, arg, limit);
                SSL_shutdown(s);
                close(SSL_get_fd(s));
                SSL_free(s);
            }

            SSL_CTX_free(ctx);
        } else {
            error("unable to locate server\n");
        }

        if (pk) EVP_PKEY_free(pk);
        if (cert) X509_free(cert);
        if (sert) X509_free(sert);
    } else if (serve) {
        sigset_t block;
        sigemptyset(&block);
        sigaddset(&block, SIGINT);
        pthread_sigmask(SIG_BLOCK, &block, NULL);
        pthread_join(tid, NULL);
        status = 0;
    } else if (!init && !serve) {
        printf("%s\n", usage);
    }

  done:

    EVP_cleanup();
    CRYPTO_cleanup_all_ex_data();
    ERR_remove_state(0);
    ERR_free_strings();
    sk_SSL_COMP_free(SSL_COMP_get_compression_methods());

    return status;
}

int client(SSL *s, int cmd, kdfp *kdfp, char *arg, uint32_t limit) {
    uint8_t kek[KEY_LEN];
    uint8_t data[KDFP_LEN];
    entry *matches[limit + 1];

    if (SSL_read(s, &data, KDFP_LEN) == KDFP_LEN) {
        struct kdfp tmp;

        read_kdfp(data, &tmp);

        if (prompt_kek("passwd: ", &tmp, kek, KEY_LEN, false)) {
            SSL_write(s, kek, KEY_LEN);
            OPENSSL_cleanse(kek, KEY_LEN);
        }

        if (cmd != export && cmd != import) {
            memcpy(kdfp, &tmp, KDFP_LEN);
        }
    }

    uint32_t count = 0;
    uint32_t code  = 1;

    switch (cmd) {
        case add:
            code = add_entry(s, PASSWD_LEN, &count);
            break;
        case delete:
            code = delete_entry(s, arg, &count);
            break;
        case edit:
            code = edit_entry(s, arg, &count);
            break;
        case find:
            count = find_entries(s, arg, limit + 1, matches);
            for (uint32_t i = 0; i < count && i < limit; i++) {
                print_entry(1, matches[i]);
                printf("\n");
                close_entry(matches[i]);
            }
            code = OK;
            break;
        case passwd:
            if (prompt_kek("new passwd: ", kdfp, kek, KEY_LEN, true)) {
                code = change_passwd(s, kek);
                OPENSSL_cleanse(kek, KEY_LEN);
            }
            break;
        case rekey:
            request(s, rekey, 0, 0);
            code = response(s, &count);
            break;
        case export:
            request(s, export, 0, 0);
            randombytes(kdfp->salt, SALT_LEN);
            if (prompt_kek("export passwd: ", kdfp, kek, KEY_LEN, true)) {
                count = recv_export(s, arg, kdfp, kek);
                code = response(s, &count);
                OPENSSL_cleanse(kek, KEY_LEN);
            }
            break;
        case import:
            request(s, import, 0, 0);
            count = send_export(s, arg, prompt_import_key);
            code  = count > 0 ? response(s, &count) : 1;
            break;
        default:
            break;
    }

    if (cmd == find && count > limit) {
        char *plural = limit == 1 ? "y" : "ies";
        printf("more than %d entr%s matched\n", limit, plural);
    }

    if (code != OK) {
        error("command failed with status %d\n", code);
    }

    return code;
}

uint32_t add_entry(SSL *s, size_t n, uint32_t *count) {
    uint8_t bytes[n];
    uint8_t passwd[n * 2];
    entry *entry;
    uint32_t code = 1;

    randombytes(bytes, n);
    encode64url(passwd, bytes, &n, false);
    template.attrs[2].val.len = n;
    template.attrs[2].val.str = passwd;

    if ((entry = editor(&template))) {
        send_entry(s, add, 0, entry);
        close_entry(entry);
        code = response(s, count);
    }

    return code;
}

uint32_t edit_entry(SSL *s, char *value, uint32_t *count) {
    entry *matches[2];
    entry *entry;
    size_t len = strlen(value);
    uint32_t code = 1;

    *count = find_entries(s, value, 2, matches);

    if (*count > 0) {
        if ((entry = editor(matches[0]))) {
            send_entry(s, edit, len, entry);
            SSL_write(s, value, len);
            close_entry(entry);
            code = response(s, count);
        }
    }

    for (uint32_t i = 0; i < *count; i++) {
        close_entry(matches[i]);
    }

    return code;
}

void generate(size_t n) {
    uint8_t bytes[n];
    uint8_t passwd[n * 2];
    randombytes(bytes, n);
    encode64url(passwd, bytes, &n, false);
    printf("%.*s\n", (int) n, passwd);
}

entry *editor(entry *entry) {
    char cmd[PATH_MAX], path[PATH_MAX];
    uint8_t bytes[ID_LEN];
    size_t size = ID_LEN;

    randombytes(bytes, size);
    encode64url((uint8_t *) path, bytes, &size, false);
    strncpy(&path[size], ".work", 6);

    int fd = open(path, O_RDWR | O_CREAT | O_EXCL, 0600);
    if (fd == -1) return NULL;
    print_entry(fd, entry);
    close(fd);

    entry = NULL;

    snprintf(cmd, PATH_MAX, "$EDITOR -- '%s'", path);
    while (system(cmd) == 0) {
        uint32_t line;
        size = 0;
        uint8_t *addr = mmfile(path, &size);
        if (!addr) goto done;

        entry = parse_entry(addr, size, &line);
        if (!entry) {
            error("entry invalid @ line %d\n", line);
            munmap(addr, size);
            continue;
        }

        entry->addr = addr;
        entry->size = size;
        break;
    }

  done:

    unlink(path);
    return entry;
}

bool init_server(kdfp *kdfp, char *dir) {
    char passwd[PASSWD_LEN + 1];
    if (!init(dir, kdfp, (uint8_t *) passwd, PASSWD_LEN)) {
        error("failed to intialize %s: %s\n", dir, strerror(errno));
        return false;
    }
    printf("initialized '%s', passwd: %.*s\n", dir, PASSWD_LEN, passwd);
    return true;
}

void *start_server(void *arg) {
    interface ifs[16];
    EVP_PKEY *pk;
    X509 *cert;
    char *pem = (char *) arg;

    if (active_interfaces(ifs, 16) > 0) {
        read_pem(pem, NULL, NULL, &pk, 1, &cert);
        server(&ifs[0], cert, pk);
    }

    return NULL;
}

bool parse_kdfp(kdfp *kdfp, char *params) {
    bool ok = true;
    char *p, *s;

    if (!(s = params = strdup(params))) return false;
    ok = ok && (p = strsep(&s, ",")) && (kdfp->N = strtoul(p, NULL, 10)) > 1;
    ok = ok && (p = strsep(&s, ",")) && (kdfp->r = strtoul(p, NULL, 10)) > 0;
    ok = ok && (p = strsep(&s, ",")) && (kdfp->p = strtoul(p, NULL, 10)) > 0;
    free(params);

    if (!ok) error("invalid KDF parameters\n");

    return ok;
}

static char *globarg(char *arg) {
    char *m = NULL;
    glob_t g;

    if (!glob(arg, GLOB_TILDE | GLOB_NOCHECK, NULL, &g) && g.gl_pathc > 0) {
        char *d, *f, *dir;
        d = strdup(g.gl_pathv[0]);
        f = strdup(g.gl_pathv[0]);
        if ((dir = realpath(dirname(d), NULL))) {
            char *file = basename(f);
            size_t len = strlen(dir) + strlen(file) + 2;
            m = malloc(len);
            snprintf(m, len, "%s/%s", dir, file);
            free(dir);
        }
        free(d);
        free(f);
    }
    globfree(&g);

    return m;
}

static void error(char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
}
