DESTDIR   =
PREFIX    = /usr
p         = $(DESTDIR)$(PREFIX)
MANPAGES := urxvt-tabbedex.1.gz command-runner.1.gz
DIST     := tabbedex command-runner.sample $(MANPAGES)

all: $(MANPAGES)

.INTERMEDIATE: urxvt-tabbedex.1 command-runner.1

urxvt-tabbedex.1: tabbedex
	if ! pod2man $< >$@; then rm -- $@; exit 1; fi

command-runner.1: command-runner.sample
	if ! pod2man $< >$@; then rm -- $@; exit 1; fi

%.1.gz: %.1
	if ! gzip -9 <$< >$@; then rm -- $@; exit 1; fi

urxvt-tabbedex.html: tabbedex
	if ! pod2html $< >$@; then rm -- $@; exit 1; fi
	@rm -f -- pod2htmd.tmp

install: $(DIST)
	install -D -m 644 tabbedex '$p/lib/urxvt/perl/tabbedex'
	install -D -m 644 command-runner.sample '$p/lib/urxvt/perl/tabbedex-command-runner.sample'
	install -D -m 644 urxvt-tabbedex.1.gz '$p/share/man/man1/urxvt-tabbedex.1.gz'
	install -D -m 644 command-runner.1.gz '$p/share/man/man1/tabbedex-command-runner.1.gz'

uninstall:
	rm -f -- '$p/lib/urxvt/perl/tabbedex' \
	         '$p/lib/urxvt/perl/tabbedex-command-runner.sample' \
	         '$p/share/man/man1/urxvt-tabbedex.1.gz' \
	         '$p/share/man/man1/tabbedex-command-runner.1.gz'

install-local:  $(DIST)
	install -D -m 644 tabbedex ~/.urxvt/ext/tabbedex
	install -D -m 644 command-runner.sample ~/.urxvt/tabbedex-command-runner.sample
# TODO: This assumes user has ~/bin in their PATH:
	install -D -m 644 urxvt-tabbedex.1.gz ~/man/man1/urxvt-tabbedex.1.gz
	install -D -m 644 command-runner.1.gz ~/man/man1/tabbedex-command-runner.1.gz

install-local-symlink:  $(DIST)
	mkdir -m 755 -p ~/.urxvt/ext ~/man/man1/
	ln -sf -- "$$(realpath tabbedex)" ~/.urxvt/ext
	ln -sf -- "$$(realpath command-runner.sample)" ~/.urxvt/tabbedex-command-runner.sample
	ln -sf -- "$$(realpath urxvt-tabbedex.1.gz)" ~/man/man1/
	ln -sf -- "$$(realpath command-runner.1.gz)" ~/man/man1/

uninstall-local:
	rm -f -- ~/.urxvt/ext/tabbedex \
	         ~/.urxvt/tabbedex-command-runner.sample \
	         ~/man/man1/urxvt-tabbedex.1.gz \
	         ~/man/man1/tabbedex-command-runner.1.gz

.PHONY: install uninstall install-local install-local-symlink uninstall-local
