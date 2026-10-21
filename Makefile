PREFIX ?= /usr/local

all: minifetch

minifetch: minifetch-project.c
	gcc minifetch-project.c -o minifetch

install: all
	install -Dm755 minifetch $(DESTDIR)$(PREFIX)/bin/minifetch

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/minifetch

clean:
	rm -f minifetch

.PHONY: all install uninstall clean
