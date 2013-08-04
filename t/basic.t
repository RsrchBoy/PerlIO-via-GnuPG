use strict;
use warnings;

use Test::More;
use Test::Skip::UnlessExistsExecutable 'gpg';
use PerlIO::via::GnuPG;
use PerlIO::via::GnuPG::Maybe;

$ENV{GNUPGHOME} = './t/gpghome';

subtest ':via(GnuPG) opening encrypted text' => sub {
    open(my $fh, '<:via(GnuPG)', 't/input.txt.asc')
        or die "cannot open! $!";

    my @in = <$fh>;

    is_deeply
        [ @in                 ],
        [ "Hey, it worked!\n" ],
        'file decrypted',
        ;
};

subtest ':via(GnuPG::Maybe) opening encrypted text' => sub {
    open(my $fh, '<:via(GnuPG::Maybe)', 't/input.txt.asc')
        or die "cannot open! $!";

    my @in = <$fh>;

    is_deeply
        [ @in                 ],
        [ "Hey, it worked!\n" ],
        'file decrypted',
        ;
};

subtest ':via(GnuPG::Maybe) opening unencrypted text' => sub {
    open(my $fh, '<:via(GnuPG::Maybe)', 't/input.txt')
        or die "cannot open! $!";

    my @in = <$fh>;

    is_deeply
        [ @in                 ],
        [ "Hey, it worked!\n" ],
        'file passedthrough OK',
        ;
};

done_testing;
