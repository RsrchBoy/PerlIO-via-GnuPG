use strict;
use warnings;

use Test::More;

use PerlIO::via::GnuPG;

open(my $fh, '<:via(GnuPG)', 't/input.txt.gpg')
    or die "cannot open! $!";

my @in = <$fh>;

is_deeply
    [ @in                 ],
    [ "Hey, it worked!\n" ],
    'file decrypted',
    ;

done_testing;
