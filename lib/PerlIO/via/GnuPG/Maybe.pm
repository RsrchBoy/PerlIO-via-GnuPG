#
# This file is part of PerlIO-via-GnuPG
#
# This software is Copyright (c) 2013 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#
package PerlIO::via::GnuPG::Maybe;
BEGIN {
  $PerlIO::via::GnuPG::Maybe::AUTHORITY = 'cpan:RSRCHBOY';
}
$PerlIO::via::GnuPG::Maybe::VERSION = '0.004';
# ABSTRACT: Layer to decrypt or pass-through unencrypted data on read

use strict;
use warnings;

use parent 'PerlIO::via::GnuPG';

sub _passthrough_unencrypted { 1 }

!!42;

__END__

=pod

=encoding UTF-8

=for :stopwords Chris Weyl decrypt

=head1 NAME

PerlIO::via::GnuPG::Maybe - Layer to decrypt or pass-through unencrypted data on read

=head1 VERSION

This document describes version 0.004 of PerlIO::via::GnuPG::Maybe - released April 14, 2014 as part of PerlIO-via-GnuPG.

=head1 SYNOPSIS

    use PerlIO::via::GnuPG::Maybe;

    # cleartext.txt may or may not be encrypted;
    # returns the content or dies on any other error.
    open(my $fh, '<:via(GnuPG::Maybe)', 'cleartext.txt')
        or die "cannot open! $!";

    my @in = <$fh>; # or whatever...

=head1 DESCRIPTION

This is a L<PerlIO> module to decrypt files transparently.  If you try to
open and read a file that is not encrypted, we will simply pass that file
through unmolested.  If you try to open and read one that is encrypted,
it tries to decrypt it and pass it back along to you.

If you're looking for a stricter implementation, see L<PerlIO::via::GnuPG>;
it will die if the file is unencrypted.

It's pretty simple and does not support writing, but works.

...and if it doesn't, please file an issue :)

=for Pod::Coverage FILL PUSHED

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<PerlIO::via::GnuPG|PerlIO::via::GnuPG>

=item *

L<PerlIO|PerlIO>

=item *

L<PerlIO::via|PerlIO::via>

=item *

L<PerlIO::via::GnuPG|PerlIO::via::GnuPG>

=back

=head1 SOURCE

The development version is on github at L<http://https://github.com/RsrchBoy/PerlIO-via-GnuPG>
and may be cloned from L<git://https://github.com/RsrchBoy/PerlIO-via-GnuPG.git>

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
