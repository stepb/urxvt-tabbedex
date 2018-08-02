#!/usr/bin/env perl

=head1 NAME

pgid-cd.pl - change directory to that of given process and run command

=head1 SYNOPSIS

pgid-cd.pl [ -v ] ( I<pgid> | -1 ) I<command> [ I<args> ... ]

=head1 DESCRIPTION

Tries to detect current working directory (or CWD) of specified process group
and runs specified command in that directory.

CWD detection is brittle and can lead to unexpected results.  It is likely to
fail if all processes in given process group run as a user other than current
user (current user will simply lack permission to read CWD information).
Furthermore, if different processes in process group have different CWDs the
script will pick arbitrary one (it can access).  And of course there's no hope
of it working via remote connection (e.g. SSH).

=head1 OPTIONS

=over

=item B<-v>

If changing directory fails, print all encountered errors.  Otherwise silently
start the command.  Note: if present, this *must* be the first argument.

=item I<pgid> or B<-1>

ID of the process group to detect CWD of.  B<-1> disables CWD detection and the
script then simply executes the command.

=item I<command> [ I<args> ... ]

Command to execute.

=back

=head1 TABBEDEX

The script was designed to work with tabbedex urxvt plugin and in particular its
B<tab-arguments> configuration resource.  For example, if this script is located
in B<~/.urxvt/tabbedex-pgid-cd> one can use the following configuration:

    URxvt.tabbedex.tab-arguments: \
        -e %~/.urxvt/tabbedex-pgid-cd %p %E

or if it's in B</usr/lib/urxvt/tabbadex-pgid-cd> then:

    URxvt.tabbedex.tab-arguments: \
        -e /usr/lib/urxvt/tabbadex-pgid-cd %p %E

Tabbedex will replace B<%p> sequence with an ID of a process in foreground of
current tab such that command in the new tab will inherit current working
directory from existing tab.

=head1 SEE ALSO

L<urxvt-tabbed(1)> and L<tabbedex-command-runner(1)>

=cut

use warnings;
use strict;

sub error {
	print STDERR join(': ', $0, @_), "\n";
}

sub fatal {
	error @_;
	error 'use Ctrl+C to terminate this script';
	sleep;
	exit 1;
}

my $verbose = $ARGV[0] eq '-v';
if ($verbose) {
	shift @ARGV;
}

my $pgid = shift @ARGV;
if ($pgid !~ /^(?:-1|\d+)$/ || !@ARGV) {
	fatal 'usage: $0 [ -v ] ( <pgid> | -1 ) <command> [ <args> ... ]';
}

if ($pgid == -1) {
	goto DONE;
} elsif (!-d '/proc') {
	error('/proc missing, unable to determine CWD of other processes');
	goto DONE;
}

my @errors;

sub try_pid {
	my ($pid) = @_;
	my $path = "/proc/$pid/cwd";
	my $cwd = eval { readlink $path };
	if ($@) {
		push @errors, "$path: $@";
	} elsif (!defined $cwd) {
		push @errors, "$path: $!";
	} elsif (!chdir $cwd) {
		push @errors, "$cwd: $!";
	} else {
		goto DONE;
	}
}

# If $pgid is still alive we can use its CWD
if (-d "/proc/$pgid") {
	try_pid($pgid);
}

# If $pgid is no longer with us, we need to go through all running
# processes and filter the ones which are in process group $pgid.
if (opendir(my $dir, '/proc')) {
	while (my $pid = readdir $dir) {
		if ($pid =~ /^[0-9]+$/ && $pid != $pgid &&
		    open(my $fh, '<', "/proc/$pid/stat")) {
			if ($pgid == (split ' ', scalar <$fh>)[4]) {
				try_pid $pid;
			}
		}
	}
} else {
	push @errors, "/proc: $!";
}

if ($verbose) {
	for (@errors) {
		chomp;
		error $_;
	}
	error("can't find " . (@errors ? 'CWD of' : 'process in') .
	      " group $pgid; won't change directory");
}

DONE:
{ exec { $ARGV[0] } @ARGV }
fatal $ARGV[0], "$!";
