MIX = mix
CFLAGS += -g -O3 -ansi -pedantic -Wall -Wextra -Wno-unused-parameter

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)
CFLAGS += -I/usr/local/include -I/usr/include -L/usr/local/lib -L/usr/lib
CFLAGS += -lpostal
CFLAGS += -std=gnu99 -Wno-unused-function

ifeq ($(wildcard deps/libpostal),)
	LIBPOSTAL_PATH = ../libpostal
else
	LIBPOSTAL_PATH = deps/libpostal
endif

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
endif

.PHONY: all libpostal clean

all: libpostal

libpostal:
	$(MIX) compile

priv/expostal.so: src/expostal.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ src/expostal.c

clean:
	$(MIX) clean
	$(RM) priv/*
