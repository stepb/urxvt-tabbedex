#! perl
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##
## Tabbed plugin for rxvt-unicode
## Modified by Michal Nazarewicz (mina86/AT/mina86.com), StephenB
## (mail4stb/AT/gmail.com), Steven Merrill
## <steven dot merrill at gmail.com>, Mark Pustjens
## <pustjens@dds.nl> and more...
##
## The following has been added:
##
## 1. Depending on time of last activity, activity character differs.
##    By default, after 4 seconds an asterisk becomes a plus sing,
##    after next 4 it becomes a colon, and finally, after another 8
##    seconds it becomes a dot.  This can be configured via
##    tabbar-timeouts resource.  It's format is:
##
##      ( <timeout> ":" <character> ":" )* <timeout> ":" <character> ":"
##
##    where <timeout> is timeout in seconds and <character> is
##    a single activity character.
##
## 2. The "[NEW]" button can be disabled (who on Earth uses mouse to
##    create new tab anyways?) by setting new-button resource to yes.
##
## 3. If title resource is true, tab's title is displayed after last
##    button.  This is handy if you have terminal with no window
##    decorations.  Colours can be configured via title-fg and
##    title-bg.
##
## 4. Incorporated Alexey Semenko <asemenko at gmail.com> patch adding
##    autohide resource.  If it's true tab bar is hidden if there is
##    no more then one tab opened.
##
## 5. Tabs are indexed in starting with zero hex. :] If you're such
##    a geek to use urxvt it shouldn't be a problem for you and it
##    saves few character when many tabs are opened.
##
## 6. As a minor modification: Final pipe character is removed (unless
##    title is displayed).  This make tab bar look nicer.
##
## Added by StephenB:
## 
## 7. Tabs can be named with Shift+Up (Enter to confirm, Escape to
##    cancel).
##
## 8. "[NEW]" button disabled by default.
##
## Added by Steven Merrill <steven dot merrill at gmail.com>
##
## 9. Ability to start a new tab or cycle through tabs via user
##    commands: tabbedex:(new|next|prev)_tab .
##    e.g. (in .Xdefaults) URxvt.keysym.M-t: perl:tabbedex:new_tab
##    (see the urxvt man file for more info about keysym)
##
## 10. Fix an issue whereby on_user_command would not properly get sent
##     to other extension packages if the mouse was not over the urxvt
##     window.
##
## Added by Thomas Jost:
##
## 11. Add several user commands: tabbedex:rename_tab,
##     tabbedex:move_tab_(left|right).
##     e.g. (see 9.) URxvt.keysym.C-S-Left: perl:tabbex:move_tab_left
##
## 12. Ability to disable the default keybindings using the
##     no-tabbedex-keys resource.
##
## Added by xanf (Illya Klymov):
##
## 13. Ability to display non-latin characters in tab title.
##
## Added by jpkotta:
##
## 14. Tabs inherit command line options.
##
## Added by Mark Pustjens <pustjens@dds.nl>
##
## 15. Resources are now read respecting the -name option.
##
## 16. Ability to prevent the last tab from closing.
##     Use the following in your ~/.Xdefaults to enable:
##     URXvt.tabbed.reopen-on-close: yes
##

use Encode qw(decode);

sub update_autohide {
   my ($self, $reconfigure) = @_;
   my $oldh = $self->{tabheight};
   if ($self->{autohide} && @{ $self->{tabs} } <= 1 &&
         ! (@{ $self->{tabs} } == 1 && $self->{tabs}[-1]->{name})) {
      $self->{tabheight} = 0;
   } else {
      $self->{tabheight} = $self->{maxtabheight};
   }
   if ($reconfigure && $self->{tabheight} != $oldh) {
      $self->configure;
      $self->copy_properties;
   }
}


sub tab_activity_mark ($$) {
   my ($self, $tab) = @_;
   return ' ' unless defined $tab->{lastActivity};
   return ' ' if $tab == $self->{cur};
   if (defined $self->{timeouts}) {
      my $diff = int urxvt::NOW - $tab->{lastActivity};
      for my $spec (@{ $self->{timeouts} }) {
         return $spec->[1] if $diff > $spec->[0];
      }
   }
   '*';
}


sub refresh {
   my ($self) = @_;

   # autohide makes it zero
   return unless $self->{tabheight};

   my $ncol = $self->ncol;

   my $text = " " x $ncol;
   my $rend = [($self->{rs_tabbar}) x $ncol];

   my ($ofs, $idx, @ofs) = (0, 0);

   if ($self->{new_button}) {
      substr $text, 0, 7, "[NEW] |";
      @$rend[0 .. 5] = ($self->{rs_tab}) x 6;
      push @ofs, [0, 6, -1 ];
      $ofs = 7;
   }

   for my $tab (@{ $self->{tabs} }) {
      my $name = $tab->{name} ? $tab->{name} : $idx;
      my $act = $self->tab_activity_mark($tab);
      my $txt = sprintf "%s%s%s", $act, $name, $act;
      my $len = length $txt;

      substr $text, $ofs, $len + 1, "$txt|";
      @$rend[$ofs .. $ofs + $len - 1] = ($self->{rs_tab}) x $len
         if $tab == $self->{cur};

      push @ofs, [ $ofs, $ofs + $len, $idx ];
      ++$idx;
      $ofs += $len + 1;
   }

   substr $text, --$ofs, 1, ' '; # remove last '|'

   if ($self->{tab_title} && $ofs + 3 < $ncol) {
      my $term = $self->{term};
      my @str = $term->XGetWindowProperty($term->parent, $self->{tab_title});
      if (@str && $str[2]) {
         my $str = '| ' . decode("utf8", $str[2]);
         my $len = length $str;
         $len = $ncol - $ofs if $ofs + $len > $ncol;
         substr $text, $ofs, $len, substr $str, 0, $len;
         @$rend[$ofs + 2 .. $ofs + $len - 1] = ($self->{rs_title}) x ($len - 2);
      }
   }

   $self->{tabofs} = \@ofs;

   $self->ROW_t (0, $text, 0, 0, $ncol);
   $self->ROW_r (0, $rend, 0, 0, $ncol);

   $self->want_refresh;
}


sub new_tab {
   my ($self, @argv) = @_;

   my $offset = $self->fheight;

   $self->{tabheight} = $self->{maxtabheight}
   unless $self->{autohide} && !(defined $self->{tabs} && @{ $self->{tabs} });

   # save a backlink to us, make sure tabbedex is inactive
   push @urxvt::TERM_INIT, sub {
      my ($term) = @_;
      $term->{parent} = $self;

      for (0 .. urxvt::NUM_RESOURCES - 1) {
         my $value = $self->{resource}[$_];

         $term->resource ("+$_" => $value)
            if defined $value;
      }

      foreach my $opt (keys %urxvt::OPTION) {
          my $value = $self->{option}{$opt};
          $term->option($urxvt::OPTION{$opt}, $value);
      }

      $term->resource (perl_ext_2 => $term->resource ("perl_ext_2") . ",-tabbedex");
   };

   push @urxvt::TERM_EXT, urxvt::ext::tabbedex::tab::;

   my $term = new urxvt::term
      $self->env, $urxvt::RXVTNAME,
      -embed => $self->parent,
      @argv;
}


sub configure {
   my ($self) = @_;

   my $tab = $self->{cur};

   # this is an extremely dirty way to force a configurenotify, but who cares
   $tab->XMoveResizeWindow (
      $tab->parent,
      0, $self->{tabheight} + 1,
      $self->width, $self->height - $self->{tabheight}
   );
   $tab->XMoveResizeWindow (
      $tab->parent,
      0, $self->{tabheight},
      $self->width, $self->height - $self->{tabheight}
   );
}


sub copy_properties {
   my ($self) = @_;
   my $tab = $self->{cur};

   my $wm_normal_hints = $self->XInternAtom ("WM_NORMAL_HINTS");

   my $current = delete $self->{current_properties};

   # pass 1: copy over properties different or nonexisting
   for my $atom ($tab->XListProperties ($tab->parent)) {
      my ($type, $format, $items) = $self->XGetWindowProperty ($tab->parent, $atom);

      # fix up size hints
      if ($atom == $wm_normal_hints) {
         my (@hints) = unpack "l!*", $items;

         $hints[$_] += $self->{tabheight} for (4, 6, 16);

         $items = pack "l!*", @hints;
      }

      my $cur = delete $current->{$atom};

      # update if changed, we assume empty items and zero type and format will not happen
      $self->XChangeProperty ($self->parent, $atom, $type, $format, $items)
         if $cur->[0] != $type or $cur->[1] != $format or $cur->[2] ne $items;

      $self->{current_properties}{$atom} = [$type, $format, $items];
   }

   # pass 2, delete all extraneous properties
   $self->XDeleteProperty ($self->parent, $_) for keys %$current;
}


sub my_resource {
   my $self = shift;
   $self->x_resource ("tabbed.$_[0]");
}


sub make_current {
   my ($self, $tab) = @_;

   if (my $cur = $self->{cur}) {
      delete $cur->{lastActivity};
      $cur->XUnmapWindow ($cur->parent) if $cur->mapped;
      $cur->focus_out;
   }

   $self->{cur} = $tab;

   $self->configure;
   $self->copy_properties;

   $tab->focus_out; # just in case, should be a nop
   $tab->focus_in if $self->focus;

   $tab->XMapWindow ($tab->parent);
   delete $tab->{lastActivity};
   $self->refresh;

   ();
}


sub on_focus_in {
   my ($self, $event) = @_;
   $self->{cur}->focus_in;
   ();
}

sub on_focus_out {
   my ($self, $event) = @_;
   $self->{cur}->focus_out;
   ();
}

sub on_key_press {
   my ($self, $event) = @_;
   $self->{cur}->key_press ($event->{state}, $event->{keycode}, $event->{time});
   1;
}

sub on_key_release {
   my ($self, $event) = @_;
   $self->{cur}->key_release ($event->{state}, $event->{keycode}, $event->{time});
   1;
}

sub on_button_release {
   my ($self, $event) = @_;

   if ($event->{row} == 0) {
      my $col = $event->{col};
      for my $button (@{ $self->{tabofs} }) {
         last if     $col <  $button->[0];
         next unless $col <= $button->[1];
         if ($button->[2] == -1) {
            $self->new_tab;
         } else {
            $self->make_current($self->{tabs}[$button->[2]]);
         }
      }
      return 1;
   }

   ();
}

sub on_init {
   my ($self) = @_;

   $self->{resource} = [map $self->resource ("+$_"), 0 .. urxvt::NUM_RESOURCES - 1];

   $self->resource (int_bwidth => 0);
   $self->resource (pty_fd => -1);

   $self->{option} = {};
   for my $key (keys %urxvt::OPTION) {
       $self->{option}{$key} = $self->option($urxvt::OPTION{$key});
   }

   # this is for the tabs terminal; order is important
   $self->option ($urxvt::OPTION{scrollBar}, 0);

   my $fg    = $self->my_resource ("tabbar-fg");
   my $bg    = $self->my_resource ("tabbar-bg");
   my $tabfg = $self->my_resource ("tab-fg");
   my $tabbg = $self->my_resource ("tab-bg");
   my $titfg = $self->my_resource ("title-fg");
   my $titbg = $self->my_resource ("title-bg");

   defined $fg    or $fg    = 3;
   defined $bg    or $bg    = 0;
   defined $tabfg or $tabfg = 0;
   defined $tabbg or $tabbg = 1;
   defined $titfg or $titfg = 2;
   defined $titbg or $titbg = 0;

   $self->{rs_tabbar} = urxvt::SET_COLOR (urxvt::DEFAULT_RSTYLE, $fg    + 2, $bg    + 2);
   $self->{rs_tab}    = urxvt::SET_COLOR (urxvt::DEFAULT_RSTYLE, $tabfg + 2, $tabbg + 2);
   $self->{rs_title}  = urxvt::SET_COLOR (urxvt::DEFAULT_RSTYLE, $titfg + 2, $titbg + 2);


   my $timeouts = $self->my_resource ("tabbar-timeouts");
   $timeouts = '16:.:8:::4:+' unless defined $timeouts;
   if ($timeouts ne '') {
      my @timeouts;
      while ($timeouts =~ /^(\d+):(.)(?::(.*))?$/) {
         push @timeouts, [ int $1, $2 ];
         $timeouts = defined $3 ? $3 : '';
      }
      if (@timeouts) {
         $self->{timeouts} = [ sort { $b->[0] <=> $a-> [0] } @timeouts ];
      }
   }

   $self->{new_button} =
      ($self->my_resource ('new-button') or 'false') !~ /^(?:false|0|no)/i;
   $self->{tab_title} =
      ($self->my_resource ('title') or 'true') !~ /^(?:false|0|no)/i;
   $self->{autohide} =
      ($self->my_resource ('autohide') or 'false') !~ /^(?:false|0|no)/i;
   $self->{no_default_keys} =
      ($self->my_resource ('no-tabbedex-keys') or 'false') !~ /^(?:false|0|no)/i;
    $self->{reopen_on_close} =
      ($self->my_resource ('reopen-on-close') or 'false') !~ /^(?:false|0|no)/i;

   ();
}


sub on_start {
   my ($self) = @_;

   $self->{maxtabheight} = $self->int_bwidth + $self->fheight + $self->lineSpace;
   $self->{tabheight} = $self->{autohide} ? 0 : $self->{maxtabheight};

   $self->{running_user_command} = 0;

   $self->cmd_parse ("\033[?25l");

   my @argv = $self->argv;

   do {
      shift @argv;
   } while @argv && $argv[0] ne "-e";

   if ($self->{tab_title}) {
      $self->{tab_title} = $self->{term}->XInternAtom("_NET_WM_NAME", 1);
   }

   $self->new_tab (@argv);

   if (defined $self->{timeouts}) {
      my $interval = ($self->{timeouts}[@{ $self->{timeouts} } - 1]->[0]);
      $interval = int($interval / 4);
      $self->{timer} = urxvt::timer->new
                                   ->interval($interval < 1 ? 1 : $interval)
                                   ->cb ( sub { $self->refresh; } );
   }

   ();
}


sub on_configure_notify {
   my ($self, $event) = @_;

   $self->configure;
   $self->refresh;

   ();
}


sub on_user_command {
  my ($self, $event) = @_;

  $self->{cur}->{term}->{parent}->tab_user_command($self->{cur}, $event, 1);

  ();
}


sub on_wm_delete_window {
   my ($self) = @_;
   $_->destroy for @{ $self->{tabs} };
   1;
}


sub tab_start {
   my ($self, $tab) = @_;

   $tab->XChangeInput ($tab->parent, urxvt::PropertyChangeMask);

   push @{ $self->{tabs} }, $tab;

#   $tab->{name} ||= scalar @{ $self->{tabs} };
   $self->make_current ($tab);

   ();
}


sub tab_destroy {
   my ($self, $tab) = @_;

   if ($self->{reopen_on_close} && $#{ $self->{tabs} } == 0) {
      $self->new_tab;
      $self->make_current ($self->{tabs}[-1]);
   }

   $self->{tabs} = [ grep $_ != $tab, @{ $self->{tabs} } ];
   $self->update_autohide ();

   if (@{ $self->{tabs} }) {
      if ($self->{cur} == $tab) {
         delete $self->{cur};
         $self->make_current ($self->{tabs}[-1]);
      } else {
         $self->refresh;
      }
   } else {
      # delay destruction a tiny bit
      $self->{destroy} = urxvt::iw->new->start->cb (sub { $self->destroy });
   }

   ();
}


sub tab_key_press {
   my ($self, $tab, $event, $keysym, $str) = @_;

   if ($tab->{is_inputting_name}) {
      if ($keysym == 0xff0d || $keysym == 0xff8d) { # enter
         $tab->{name} = $tab->{new_name};
         $tab->{is_inputting_name} = 0;
         $self->update_autohide (1);
      } elsif ($keysym == 0xff1b) { # escape
         $tab->{name} = $tab->{old_name};
         $tab->{is_inputting_name} = 0;
         $self->update_autohide (1);
      } elsif ($keysym == 0xff08) { # backspace
         substr $tab->{new_name}, -1, 1, "";
         $tab->{name} = "$tab->{new_name}█";
      } elsif ($str !~ /[\x00-\x1f\x80-\xaf]/) {
         $tab->{new_name} .= $str;
         $tab->{name} = "$tab->{new_name}█";
      }
      $self->refresh;
      return 1;
   }

   return () if ($self->{no_default_keys});

   if ($event->{state} & urxvt::ShiftMask) {
      if ($keysym == 0xff51 || $keysym == 0xff53) {
         if (@{ $self->{tabs} } > 1) {
            $self->change_tab($tab, $keysym - 0xff52);
         }
         return 1;

      } elsif ($keysym == 0xff54) {
         $self->new_tab;
         return 1;

      } elsif ($keysym == 0xff52) {
         $self->rename_tab($tab);
         return 1;
      }
   } elsif ($event->{state} & urxvt::ControlMask) {
      if ($keysym == 0xff51 || $keysym == 0xff53) {
         $self->move_tab($tab, $keysym - 0xff52);
         return 1;
      }
   }

   ();
}


sub tab_property_notify {
   my ($self, $tab, $event) = @_;

   $self->copy_properties
      if $event->{window} == $tab->parent;

   ();
}


sub tab_add_lines {
   my ($self, $tab) = @_;
   my $mark = $self->tab_activity_mark($tab);
   $tab->{lastActivity} = int urxvt::NOW;
   $self->refresh if $mark ne $self->tab_activity_mark($tab);
   ();
}


sub tab_user_command {
  my ($self, $tab, $cmd, $proxy_events) = @_;

  if ($cmd eq 'tabbedex:new_tab') {
    $self->new_tab;
  }
  elsif ($cmd eq 'tabbedex:next_tab') {
    $self->change_tab($tab, 1);
  }
  elsif ($cmd eq 'tabbedex:prev_tab') {
    $self->change_tab($tab, -1);
  }
  elsif ($cmd eq 'tabbedex:move_tab_left') {
    $self->move_tab($tab, -1);
  }
  elsif ($cmd eq 'tabbedex:move_tab_right') {
    $self->move_tab($tab, 1);
  }
  elsif ($cmd eq 'tabbedex:rename_tab') {
    $self->rename_tab($tab);
  }
  else {
    # Proxy the user command through to the tab's term, while taking care not
    # to get caught in an infinite loop.
    if ($proxy_events && $self->{running_user_command} == 0) {
      $self->{running_user_command} = 1;
      urxvt::invoke($tab->{term}, 20, $cmd);
      $self->{running_user_command} = 0;
    }
  }

  ();
}

sub change_tab {
  my ($self, $tab, $direction) = @_;

  my $idx = 0;
  ++$idx while $self->{tabs}[$idx] != $tab;
  $idx += $direction;
  $self->make_current ($self->{tabs}[$idx % @{ $self->{tabs}}]);

  ();
}

sub move_tab {
  my ($self, $tab, $direction) = @_;

  if (@{ $self->{tabs} } > 1) {
    my $idx1 = 0;
    ++$idx1 while $self->{tabs}[$idx1] != $tab;
    my $idx2 = ($idx1 + $direction) % @{ $self->{tabs} };

    ($self->{tabs}[$idx1], $self->{tabs}[$idx2]) =
      ($self->{tabs}[$idx2], $self->{tabs}[$idx1]);
    $self->make_current ($self->{tabs}[$idx2]);
  }

  ();
}

sub rename_tab {
  my ($self, $tab) = @_;

  $tab->{is_inputting_name} = 1;
  $tab->{old_name} = $tab->{name} ? $tab->{name} : "";
  $tab->{new_name} = "";
  $tab->{name} = "█";
  $self->update_autohide (1);
  $self->refresh;

  ();
}

package urxvt::ext::tabbedex::tab;

# helper extension implementing the subwindows of a tabbed terminal.
# simply proxies all interesting calls back to the tabbedex class.

{
   for my $hook qw(start destroy user_command key_press property_notify add_lines) {
      eval qq{
         sub on_$hook {
            my \$parent = \$_[0]{term}{parent}
               or return;
            \$parent->tab_$hook (\@_)
         }
      };
      die if $@;
   }
}
