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
# git description: 0.002-13-gc9e4ff1
$PerlIO::via::GnuPG::VERSION = '0.003';

# ABSTRACT: Layer to try to decrypt on read

use strict;
use warnings;

use IPC::Open3 'open3';
use Symbol 'gensym';

# gpg --decrypt -q --status-file aksdja --no-tty
# gpg --decrypt -q --status-file aksdja --no-tty .pause.gpg

sub PUSHED {
    my ($class, $mode) = @_;

    return bless { }, $class;
}

sub _passthrough_unencrypted { 0 }

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
    my @output = <$out>;
    my @errors = <$error>;

    waitpid $pid, 0;

    ### @output
    ### @errors

    ### filter warnings out...
    @errors = grep { ! /WARNING:/ } @errors;

    if (@errors) {
        my $not_encrypted = scalar grep { /no valid OpenPGP data found/ } @errors;

        ### passthrough: $self->_passthrough_unencrypted
        if ($not_encrypted) {
            die "file does not appear to be encrypted!: @errors"
                unless $self->_passthrough_unencrypted;
            # FIXME @output = split /\n/, $maybe_encrypted;
            @output = ($maybe_encrypted);
        }
        else {
            die "Error decrypting file: @errors";
        }
    }

    $self->{buffer} = [ @output ];
    return shift @{ $self->{buffer} };
}

!!42;

__END__

=pod

=encoding UTF-8

=for :stopwords Chris Weyl decrypt

=head1 NAME

PerlIO::via::GnuPG - Layer to try to decrypt on read

=head1 VERSION

This document describes version 0.003 of PerlIO::via::GnuPG - released April 08, 2014 as part of PerlIO-via-GnuPG.

=head1 SYNOPSIS

    use PerlIO::via::GnuPG;

    # dies on error, and if the file is not encrypted
    open(my $fh, '<:via(GnuPG)', 'secret.txt.asc')
        or die "cannot open! $!";

    my @in = <$fh>; # or whatever...

=head1 DESCRIPTION

This is a L<PerlIO> module to decrypt files transparently.  It's pretty
simple and does not support writing, but works.

...and if it doesn't, please file an issue :)

=for Pod::Coverage FILL PUSHED

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<PerlIO::via::GnuPG::Maybe|PerlIO::via::GnuPG::Maybe>

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
