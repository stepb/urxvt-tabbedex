PREFIX	= /usr

all: urxvt-tabbedex.1

urxvt-tabbedex.1: tabbedex
	if ! pod2man $< >$@; then rm -- $@; exit 1; fi

urxvt-tabbedex.html: tabbedex
	if ! pod2html $< >$@; then rm -- $@; exit 1; fi
	@rm -f -- pod2htmd.tmp

install: tabbedex urxvt-tabbedex.1
	install -D -m 644 tabbedex $(PREFIX)/lib/urxvt/perl/tabbedex
	install -D -m 644 urxvt-tabbedex.1 $(PREFIX)/share/man/man1/urxvt-tabbedex.1

uninstall:
	rm -f -- "$(PREFIX)/lib/urxvt/perl/tabbedex" "$(PREFIX)/share/man/man1/urxvt-tabbedex.1"

install-local: tabbedex urxvt-tabbedex.1
	install -D -m 644 tabbedex ~/.urxvt/ext/tabbedex
# TODO: This assumes user has ~/bin in their PATH:
	install -D -m 644 urxvt-tabbedex.1 ~/man/man1/urxvt-tabbedex.1

install-local-symlink: tabbedex urxvt-tabbedex.1
	mkdir -m 755 -p ~/.urxvt/ext ~/man/man1/
	ln -sf "$(shell realpath tabbedex)" ~/.urxvt/ext
	ln -sf "$(shell realpath urxvt-tabbedex.1)" ~/man/man1/

uninstall-local:
	rm -f -- ~/.urxvt/ext/tabbedex ~/man/man1/urxvt-tabbedex.1

.PHONY: install uninstall install-local uninstall-local
