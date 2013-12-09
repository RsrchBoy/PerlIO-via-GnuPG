package PerlIO::via::GnuPG;

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

=for Pod::Coverage FILL PUSHED

=for :stopwords decrypt

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

=head1 SEE ALSO

PerlIO::via::GnuPG::Maybe

PerlIO

PerlIO::via

=cut
