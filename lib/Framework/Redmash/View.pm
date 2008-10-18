package Framework::Redmash::Render;

use Moose;

use Tie::IxHash;

has _actions => qw/is ro required 1/, default => sub {
    my %actions;
    tie %actions, 'Tie::IxHash';
    return \%actions;
};

sub _action {
    my $self = shift;
    return $_[0] if @_ == 1 && blessed $_[0];
    return Framework::Redmash::Render::Action->new(@_);
}

sub action {
    my $self = shift;
    return $self->_actions unless @_;
    my $name = shift;
    return $self->_actions->{$name};
}

sub add {
    my $self = shift;
    my $action = $self->_action(@_);
    $self->_actions->{$action->name} = $action;
}

sub each {
    my $self = shift;
    my $code = shift;

    for (keys %{ $self->_actions }) {
        $code->($self->action->{$_})
    }
}

package Framework::Redmash::Render::Action;

use Moose;

has name => qw/is ro required 1/;

#has match => qw/reader _match lazy_build 1/;
#sub _build_match {
#    my $self = shift;
#    my $name = $self->name;
#    return qr/

#}

1;
