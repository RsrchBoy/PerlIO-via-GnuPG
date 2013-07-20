use strict;
use warnings;

use Test::More;
use Test::Skip::UnlessExistsExecutable 'gpg';
use PerlIO::via::GnuPG;

$ENV{GNUPGHOME} = './t/gpghome';

open(my $fh, '<:via(GnuPG)', 't/input.txt.asc')
    or die "cannot open! $!";

my @in = <$fh>;

is_deeply
    [ @in                 ],
    [ "Hey, it worked!\n" ],
    'file decrypted',
    ;

done_testing;
