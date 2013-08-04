package PerlIO::via::GnuPG::Maybe;

# ABSTRACT: Layer to decrypt or pass-through unencrypted data on read

use strict;
use warnings;

use parent 'PerlIO::via::GnuPG';

sub _passthrough_unencrypted { 1 }

!!42;
__END__

=for Pod::Coverage FILL PUSHED

=head1 SYNOPSIS

    use PerlIO::via::GnuPG::Maybe;

    # cleartext.txt may or may not be encrypted/decryptable
    open(my $fh, '<:via(GnuPG::Maybe)', 'cleartext.txt')
        or die "cannot open! $!";

    my @in = <$fh>; # or whatever...

=head1 DESCRIPTION

This is a L<PerlIO> module to decrypt files transparently.  If you try to
open and read a file that is not encrypted, we will simply pass that file
through unmolested.  If you try to open and read one that is, we will try
to decrypt it and pass it back along to you.

It's pretty simple, does not support writing, but works.

...and if it doesn't, please file an issue :)

=head1 SEE ALSO

PerlIO

PerlIO::via

PerlIO::via::GnuPG

=cut
