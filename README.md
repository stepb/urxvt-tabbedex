# URxvt Tabbed Extended plugin

An extended version of rxvt-unicode's tabbed perl extension with many
new features such as:

* activity and bell markers,
* terminal status in the tab bar,
* tabs renaming (also using OSC command),
* user commands (so keysyms can be used),
* tab bar auto-hiding,
* preserving of -e option,
* and more…

## Installing tabbedex

Since tabbedex extension does not come with rxvt-unicode, it has to be
installed separately.  Installation is as simple as invoking:

    curl https://raw.githubusercontent.com/mina86/urxvt-tabbedex/master/install | sh

or to install system-wide:

    curl https://raw.githubusercontent.com/mina86/urxvt-tabbedex/master/install | sudo sh

Running this command again (or executing `sh
~/.urxvt/urxvt-tabbedex/install`) will update the code.

## Enabling the extension

The plugin can be tested, without enabling it by default, by using
urxvt’s `-pe` switch as follows:

    urxvt -pe tabbedex

To enable it by default, it needs to be added to `perl-ext` or
`perl-ext-common` URxvt resource.  For example, `~/.Xresources` might
contain:

    URxvt.perl-ext:  matcher,tabbedex,searchable-scrollback<M-s>

For full documentation of that resource, consult RESOURCES section of
[urxvt man page](http://linux.die.net/man/1/urxvt).

## Configuration and usage

For configuration and usage see the sources of tabbedex file or read
the urxvt-tabbedex man page installed by the above command (in case of
local installation it is put in `~/man` directory which `man` will
look if `~/bin` is in `PATH`).
