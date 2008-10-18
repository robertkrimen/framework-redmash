package Framework::Redmash::Configuration;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

use Framework::Redmash::Manifest;
#use Framework::Redmash::Render;

has name => qw/is rw isa Str/;

has config_default => qw/is ro isa Maybe[HashRef]/;

has manifest => qw/is ro isa Framework::Redmash::Manifest/, default => sub {
    return Framework::Redmash::Manifest->new;
};

#has render => qw/is ro isa Framework::Redmash::Render/, default => sub {
#    return Framework::Redmash::Render->new;
#};

1;
