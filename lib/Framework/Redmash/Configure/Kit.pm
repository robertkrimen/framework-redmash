package Framework::Redmash::Configure::Kit;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

has kit => qw/is ro required 1 isa Framework::Redmash::Kit/;

sub render_target {
    my $self = shift;
    return $self->kit->finder->target(slot => 'render', @_);
}

sub before_target {
    my $self = shift;
    return $self->kit->finder->target(slot => 'before', @_);
}

sub after_target {
    my $self = shift;
    return $self->kit->finder->target(slot => 'after', @_);
}

sub make {
    return shift->kit->maker(@_);
}

sub maker {
    return shift->kit->maker(@_);
}

1;
