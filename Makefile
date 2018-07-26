DESTDIR   =
PREFIX    = /usr
LIBDIR    = lib
# Set to empty value to prevent man pages from being installed:
MANDIR    = share/man
# Set to empty value to prevent documentation from being installed:
DOCDIR    = share/doc/urxvt-tabbedex

L         = $(DESTDIR)/$(PREFIX)/$(LIBDIR)/urxvt
M         = $(DESTDIR)/$(PREFIX)/$(MANDIR)/man1
D         = $(DESTDIR)/$(PREFIX)/$(DOCDIR)

DIST      = tabbedex command-runner.sample


all: man html
man: tabbedex.1.gz command-runner.sample.1.gz pgid-cd.pl.1.gz
html: tabbedex.html command-runner.sample.html pgid-cd.pl.html


%.1: %
	if ! pod2man $< >$@; then rm -- $@; exit 1; fi

%.1.gz: %.1
	if ! gzip -9 <$< >$@; then rm -- $@; exit 1; fi

%.html: %
	if ! pod2html $< >$@; then rm -- $@; exit 1; fi
	@rm -f -- pod2htmd.tmp


clean:
	rm -f -- *.1 *.1.gz *.html


install: AUTHORS LICENSE $(DIST) man html
	install -D -m 644 tabbedex                   $L/perl/tabbedex
	install -D -m 644 command-runner.sample      $L/tabbedex-command-runner.sample
	install -D -m 755 pgid-cd.pl                 $L/tabbedex-pgid-cd
ifneq ($(MANDIR),)
	install -D -m 644 tabbedex.1.gz              $M/urxvt-tabbedex.1.gz
	install -D -m 644 command-runner.sample.1.gz $M/tabbedex-command-runner.1.gz
	install -D -m 644 pgid-cd.pl.1.gz            $M/tabbedex-pgid-cd.1.gz
endif
ifneq ($(DOCDIR),)
	install -D -m 644 AUTHORS                    $D/AUTHORS
	install -D -m 644 LICENSE                    $D/LICENSE
	install -D -m 644 tabbedex.html              $D/tabbedex.html
	install -D -m 644 command-runner.sample.html $D/command-runner.html
	install -D -m 644 pgid-cd.pl.html            $D/pgid-cd.html
endif

uninstall:
	rm -f -- $L/perl/tabbedex $L/tabbedex-command-runner.sample \
	         $L/tabbedex-pgid-cd
ifneq ($(MANDIR),)
	rm -f -- $M/urxvt-tabbedex.1.gz $M/tabbedex-command-runner.1.gz \
	         $M/tabbedex-pgid-cd.1.gz
endif
ifneq ($(DOCDIR),)
	rm -rf -- $D
endif


install-local: $(DIST) man
	install -D -m 644 tabbedex                   ~/.urxvt/ext/tabbedex
	install -D -m 644 command-runner.sample      ~/.urxvt/tabbedex-command-runner.sample
	install -D -m 755 pgid-cd.pl                 ~/.urxvt/tabbedex-pgid-cd
ifneq ($(MANDIR),)
# TODO: This assumes user has ~/bin in their PATH:
	install -D -m 644 tabbedex.1.gz              ~/man/man1/urxvt-tabbedex.1.gz
	install -D -m 644 command-runner.sample.1.gz ~/man/man1/tabbedex-command-runner.1.gz
	install -D -m 644 pgid-cd.pl.1.gz            ~/man/man1/tabbedex-pgid-cd.1.gz
endif

install-local-symlink: $(DIST) man
	mkdir -m 755 -p ~/.urxvt/ext ~/man/man1/
	ln -sf -- "$$(realpath tabbedex)"                   ~/.urxvt/ext
	ln -sf -- "$$(realpath command-runner.sample)"      ~/.urxvt/tabbedex-command-runner.sample
	ln -sf -- "$$(realpath pgid-cd.pl)"                 ~/.urxvt/pgid-cd
ifneq ($(MANDIR),)
	ln -sf -- "$$(realpath tabbedex.1.gz)"              ~/man/man1/urxvt-tabbedex.1.gz
	ln -sf -- "$$(realpath command-runner.sample.1.gz)" ~/man/man1/tabbedex-command-runner.1.gz
	ln -sf -- "$$(realpath pgid-cd.pl.1.gz)"            ~/man/man1/tabbedex-pgid-cd.1.gz
endif

uninstall-local:
	rm -f -- ~/.urxvt/ext/tabbedex ~/.urxvt/tabbedex-command-runner.sample \
	         ~/.urxvt/tabbedex-pgid-cd
ifneq ($(MANDIR),)
	rm -f -- ~/man/man1/urxvt-tabbedex.1.gz \
	         ~/man/man1/tabbedex-command-runner.1.gz \
	         ~/man/man1/tabbedex-pgid-cd.1.gz
endif


.PHONY: all man html clean
.PHONY: install uninstall install-local install-local-symlink uninstall-local
