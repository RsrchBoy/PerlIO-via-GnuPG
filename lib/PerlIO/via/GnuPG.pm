package PerlIO::via::GnuPG;

# ABSTRACT: Layer to try to decrypt on read

use strict;
use warnings;

use IPC::Open3 'open3';
use Symbol 'gensym';

# debugging...
use Smart::Comments '###';

# gpg --decrypt -q --status-file aksdja --no-tty
# gpg --decrypt -q --status-file aksdja --no-tty .pause.gpg


sub PUSHED {
    my ($class, $mode) = @_;

    my $buffer;
    return bless {
        #buffer => undef, # \$buffer,
    }, $class;
    #return bless my \$buffer, $class;
}

sub FILL {
    my ($self, $fh) = @_;

    return shift @{ $self->{buffer} }
        if exists $self->{buffer};

    ### pull in all of fh and try to decrypt it...
    my $maybe_encrypted = do { local $/; <$fh> };

    ### $maybe_encrypted
    my ($in, $out, $error) = (gensym, gensym, gensym);
    my $run = "gpg -qd --no-tty --command-fd 0";
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

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

=cut
