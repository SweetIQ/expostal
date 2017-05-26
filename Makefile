MIX = mix
CFLAGS = -g -O3 -ansi -pedantic -Wall -Wextra -Wno-unused-parameter

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)
CFLAGS += -lpostal

ifeq ($(wildcard deps/hoedown),)
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

priv/expostal.so: src/expostal.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ src/expostal.c

clean:
	$(MIX) clean
	$(RM) priv/expostal.so