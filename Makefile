MIX = mix
CFLAGS = -g -O3 -ansi -pedantic -Wall -Wextra -Wno-unused-parameter

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)
CFLAGS += -lpostal

ifeq ($(wildcard deps/libpostal),)
	LIBPOSTAL_PATH = ../libpostal
else
	LIBPOSTAL_PATH = deps/libpostal
endif

CFLAGS += -I/usr/local/include

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

priv/parser.so: src/parser.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ src/parser.c

priv/expand.so: src/expand.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ src/expand.c

clean:
	$(MIX) clean
	$(RM) priv/*