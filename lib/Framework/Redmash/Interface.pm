package Framework::Redmash::Interface;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

with qw/Framework::Redmash::Component/;

use URI::PathAbstract;
use Template;

sub rsc {
    return $_[0]->kit->rsc;
}

sub uri {
    my $self = shift;
    my $uri = $self->kit->uri;
    return $uri->clone unless @_;

    my @path = @_;
    my $query;
    $query = pop @path if ref $path[-1] eq "ARRAY" || ref $path[-1] eq "HASH";
    $uri = $uri->child(@path);
    $uri->query_form($query) if $query;
    return $uri;
}

sub href {
    my $self = shift;
    # TODO Escaping?
    my $uri = $self->uri(@_);
    return qq/href="$uri"/;
}

sub src {
    my $self = shift;
    # TODO Escaping?
    my $uri = $self->uri(@_);
    return qq/src="$uri"/;
}

1;
