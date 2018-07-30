CFLAGS := -std=c99 -Wall -Wextra
LIBS   := -lssl -lcrypto -lm -lz
SSE2   := yes

TARGET ?= $(shell uname -s 2>/dev/null || echo unknown)
override TARGET := $(shell echo $(TARGET) | tr [A-Z] [a-z])

ifeq ($(TARGET), android)
	CC      := arm-linux-androideabi-gcc
	SYSROOT := $(ANDROID_NDK)/platforms/android-14/arch-arm/
	CFLAGS  += --sysroot=$(SYSROOT)
	LDFLAGS += -Wl,--fix-cortex-a8 --sysroot=$(SYSROOT)
	LIBS    += -lc
	SSE2    :=
	NACL    ?= deps/android
	OPENSSL ?= /usr/local/openssl-1.0.1g-android-arm
else
	NACL    ?= deps/nacl/build/$(shell hostname -s)
	OPENSSL ?= /usr/local/openssl-1.0.1g
endif

ifeq ($(TARGET), linux)
	CFLAGS  += -D_POSIX_C_SOURCE=200809L -D_BSD_SOURCE
	LIBS    += -lpthread -ldl
endif

CFLAGS  += -DHAVE_CONFIG_H -I include -I $(OPENSSL)/include
LDFLAGS += -L $(OPENSSL)/lib

SRC      := $(filter-out $(if $(SSE2),%-nosse.c,%-sse.c),$(wildcard src/*.c))
OBJ       = $(patsubst src/%.c,$(OBJ_DIR)/%.o,$(SRC)) $(OBJ_DIR)/randombytes.o
OBJ_DIR  := obj

ifeq ($(TARGET), android)
	OBJ := $(patsubst %/interface.o,%/netlink.o,$(OBJ))
endif

TEST_OBJ := $(patsubst test/%c,$(OBJ_DIR)/%o,$(wildcard test/*.c))

all: keys

clean:
	@$(RM) $(OBJ) $(TEST_OBJ)
	@$(RM) -r $(OBJ_DIR)/include
	@$(RM) -r $(OBJ_DIR)/lib

keys: $(OBJ)
	@echo LINK $@
	@$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

libkeys.so: $(filter-out %keys.o %client.o,$(OBJ)) $(OBJ_DIR)/native.o
	@echo LINK $@
	$(CC) -shared $(LDFLAGS) -o $@ $^ $(CFLAGS) $(LIBS) -llog

test: tests
	./tests

tests: $(filter-out %keys.o,$(OBJ)) $(TEST_OBJ)
	@echo LINK $@
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

$(OBJ):      nacl | $(OBJ_DIR)
$(TEST_OBJ): nacl | $(OBJ_DIR)

$(OBJ_DIR):
	@mkdir -p $@

$(OBJ_DIR)/%.o : src/%.c
	@echo CC $<
	@$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_DIR)/%.o : src/android/%.c
	@echo CC $<
	@$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_DIR)/%.o : test/%.c
	@echo TESTCC $<
	@$(CC) $(CFLAGS) -c -o $@ $<

# NaCl build

nacl: $(OBJ_DIR)/lib/libnacl.a | $(OBJ_DIR)
	$(eval  CFLAGS += -I $(OBJ_DIR)/include)
	$(eval LDFLAGS += -L $(OBJ_DIR)/lib)
	$(eval    LIBS += -lnacl)

$(NACL)/bin/okabi:
	@echo Building NaCl
	@cd deps/nacl && ./do

$(OBJ_DIR)/include/crypto_box.h: $(NACL)/bin/okabi
	@mkdir -p $(OBJ_DIR)/include
	@$(eval NACL_ARCH := $(shell $(NACL)/bin/okabi | head -1))
	@echo CP $(NACL)/include/$(NACL_ARCH)
	@cp -r $(NACL)/include/$(NACL_ARCH)/*.h $(OBJ_DIR)/include

$(OBJ_DIR)/lib/libnacl.a: $(OBJ_DIR)/include/crypto_box.h
	@mkdir -p $(OBJ_DIR)/lib
	@$(eval NACL_ARCH := $(shell $(NACL)/bin/okabi | head -1))
	@echo CP $(NACL)/lib/$(NACL_ARCH)/libnacl.a
	@cp $(NACL)/lib/$(NACL_ARCH)/libnacl.a $@

$(OBJ_DIR)/randombytes.o: $(OBJ_DIR)/lib/libnacl.a
	@$(eval NACL_ARCH := $(shell $(NACL)/bin/okabi | head -1))
	@echo CP $(NACL)/lib/$(NACL_ARCH)/randombytes.o
	@cp $(NACL)/lib/$(NACL_ARCH)/randombytes.o $@

.PHONY: all clean test nacl
