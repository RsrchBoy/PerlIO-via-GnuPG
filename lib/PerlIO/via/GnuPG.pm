#
# This file is part of PerlIO-via-GnuPG
#
# This software is Copyright (c) 2013 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#
package PerlIO::via::GnuPG;
BEGIN {
  $PerlIO::via::GnuPG::AUTHORITY = 'cpan:RSRCHBOY';
}
{
  $PerlIO::via::GnuPG::VERSION = '0.002';
}
# git description: 0.001-4-g3413f1d


# ABSTRACT: Layer to try to decrypt on read

use strict;
use warnings;

use IPC::Open3 'open3';
use Symbol 'gensym';

# debugging...
#use Smart::Comments '###';

# gpg --decrypt -q --status-file aksdja --no-tty
# gpg --decrypt -q --status-file aksdja --no-tty .pause.gpg

sub PUSHED {
    my ($class, $mode) = @_;

    return bless { }, $class;
}

sub FILL {
    my ($self, $fh) = @_;

    return shift @{ $self->{buffer} }
        if exists $self->{buffer};

    ### pull in all of fh and try to decrypt it...
    my $maybe_encrypted = do { local $/; <$fh> };

    ### $maybe_encrypted
    my ($in, $out, $error) = (gensym, gensym, gensym);
    my $run = 'gpg -qd --no-tty --command-fd 0';
    my $pid = open3($in, $out, $error, $run);

    ### $pid
    print $in $maybe_encrypted;
    close $in;
    my @output    = <$out>;
    my $error_msg = join '', <$error>;

    ### @output
    ### $error_msg
    waitpid $pid, 0;

    $self->{buffer} = [ @output ];
    return shift @{ $self->{buffer} };
}

!!42;

__END__

=pod

=encoding utf-8

=for :stopwords Chris Weyl

=head1 NAME

PerlIO::via::GnuPG - Layer to try to decrypt on read

=head1 VERSION

This document describes version 0.002 of PerlIO::via::GnuPG - released July 20, 2013 as part of PerlIO-via-GnuPG.

=head1 SYNOPSIS

    use PerlIO::via::GnuPG;

    open(my $fh, '<:via(GnuPG)', 'secret.txt.asc')
        or die "cannot open! $!";

    my @in = <$fh>; # or whatever...

=head1 DESCRIPTION

This is a L<PerlIO> module to decrypt files transparently.  It's pretty
simple, does not support writing, but works.

...and if it doesn't, please file an issue :)

=for Pod::Coverage FILL PUSHED

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<PerlIO|PerlIO>

=item *

L<PerlIO::via|PerlIO::via>

=back

=head1 SOURCE

The development version is on github at L<http://github.com/RsrchBoy/PerlIO-via-GnuPG>
and may be cloned from L<git://github.com/RsrchBoy/PerlIO-via-GnuPG.git>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/RsrchBoy/PerlIO-via-GnuPG/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Chris Weyl <cweyl@alumni.drew.edu>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Chris Weyl.

This is free software, licensed under:

  The GNU Lesser General Public License, Version 2.1, February 1999

=cut
