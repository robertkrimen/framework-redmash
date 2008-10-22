package Framework::Redmash::Configuration;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

use Framework::Redmash::Manifest;
#use Framework::Redmash::Render;

has redmash_meta => qw/is ro required 1 isa Framework::Redmash::Meta/;

has name => qw/is rw isa Str/;

has config_default => qw/is ro isa Maybe[HashRef]/;

has manifest => qw/is ro isa Framework::Redmash::Manifest/, default => sub {
    return Framework::Redmash::Manifest->new;
};

has _build_list => qw/is ro required 1 lazy 1 isa ArrayRef/, default => sub { [] };
sub builder {
    my $self = shift;
    push @{ $self->_build_list }, @_;
}

sub build {
    my $self = shift;
    my $kit = shift;

    for my $builder (@{ $self->_build_list }) {
        $builder->($kit);
    }
}

#has render => qw/is ro isa Framework::Redmash::Render/, default => sub {
#    return Framework::Redmash::Render->new;
#};



1;
