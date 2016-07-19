all: urxvt-tabbedex.1

urxvt-tabbedex.1: tabbedex
	if ! pod2man $< >$@; then rm -- $@; exit 1; fi

urxvt-tabbedex.html: tabbedex
	if ! pod2html $< >$@; then rm -- $@; exit 1; fi
	@rm -f -- pod2htmd.tmp
