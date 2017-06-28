include config.mk

ifneq ($(shell uname -s),Darwin)
  LDLIBS = -L/usr/local/lib -lm
else
  LIBFTDI_NAME = $(shell $(PKG_CONFIG) --exists libftdi1 && echo ftdi1 || echo ftdi)
  LDLIBS = -L/usr/local/lib -l$(LIBFTDI_NAME) -lm
endif

ifeq ($(STATIC),1)
LDFLAGS += -static
LDLIBS += $(shell for pkg in libftdi1 libftdi; do $(PKG_CONFIG) --silence-errors --static --libs $$pkg && exit; done; echo -lftdi; )
CFLAGS += $(shell for pkg in libftdi1 libftdi; do $(PKG_CONFIG) --silence-errors --static --cflags $$pkg && exit; done; )
else
LDLIBS += $(shell for pkg in libftdi1 libftdi; do $(PKG_CONFIG) --silence-errors --libs $$pkg && exit; done; echo -lftdi; )
CFLAGS += $(shell for pkg in libftdi1 libftdi; do $(PKG_CONFIG) --silence-errors --cflags $$pkg && exit; done; )
endif

all: ftdiflash$(EXE)

ftdiflash$(EXE): ftdiflash.o
	$(CC) -o $@ $(LDFLAGS) $^ $(LDLIBS)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp ftdiflash $(DESTDIR)$(PREFIX)/bin/ftdiflash

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/ftdiflash

clean:
	rm -f ftdiflash
	rm -f ftdiflash.exe
	rm -f *.o *.d

-include *.d

.PHONY: all install uninstall clean

