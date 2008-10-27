package Framework::Redmash::Configure::Meta;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

has redmash_meta => qw/is ro required 1 isa Framework::Redmash::Meta/, handles => [qw/ setup_manifest name /];

has config_default => qw/is ro isa Maybe[HashRef]/;

has _build_list => qw/is ro required 1 lazy 1 isa ArrayRef/, default => sub { [] };
sub build {
    my $self = shift;
    push @{ $self->_build_list }, @_;
}

sub build_list {
    my $self = shift;
    return @{ $self->_build_list };
}

1;
