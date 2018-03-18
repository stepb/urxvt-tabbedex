DESTDIR =
PREFIX  = /usr
p       = $(DESTDIR)$(PREFIX)

all: urxvt-tabbedex.1.gz

.INTERMEDIATE: urxvt-tabbedex.1
urxvt-tabbedex.1: tabbedex
	if ! pod2man $< >$@; then rm -- $@; exit 1; fi

urxvt-tabbedex.1.gz: urxvt-tabbedex.1
	if ! gzip -9 <$< >$@; then rm -- $@; exit 1; fi

urxvt-tabbedex.html: tabbedex
	if ! pod2html $< >$@; then rm -- $@; exit 1; fi
	@rm -f -- pod2htmd.tmp

install: tabbedex urxvt-tabbedex.1.gz
	install -D -m 644 tabbedex '$p/lib/urxvt/perl/tabbedex'
	install -D -m 644 urxvt-tabbedex.1.gz '$p/share/man/man1/urxvt-tabbedex.1.gz'

uninstall:
	rm -f -- '$p/lib/urxvt/perl/tabbedex' '$p/share/man/man1/urxvt-tabbedex.1.gz'

install-local: tabbedex urxvt-tabbedex.1.gz
	install -D -m 644 tabbedex ~/.urxvt/ext/tabbedex
# TODO: This assumes user has ~/bin in their PATH:
	install -D -m 644 urxvt-tabbedex.1.gz ~/man/man1/urxvt-tabbedex.1.gz

install-local-symlink: tabbedex urxvt-tabbedex.1.gz
	mkdir -m 755 -p ~/.urxvt/ext ~/man/man1/
	ln -sf -- "$$(realpath tabbedex)" ~/.urxvt/ext
	ln -sf -- "$$(realpath urxvt-tabbedex.1.gz)" ~/man/man1/

uninstall-local:
	rm -f -- ~/.urxvt/ext/tabbedex ~/man/man1/urxvt-tabbedex.1.gz

.PHONY: install uninstall install-local install-local-symlink uninstall-local
