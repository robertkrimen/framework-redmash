package Framework::Redmash::Base::Standard;

use Moose;

sub configure {
    my $self = shift;
    my $redmash_meta = shift;
    my $given = shift;

    $redmash_meta->manifest->include(<<_END_);
run
run/root
run/tmp
assets
assets/root
assets/root/static
assets/root/static/css
assets/root/static/js
assets/tt
_END_
}

1;
