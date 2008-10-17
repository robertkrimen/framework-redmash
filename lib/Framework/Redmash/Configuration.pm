package Framework::Redmash::Configuration;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

use Framework::Redmash::Manifest;

has name => qw/is rw isa Str/;

has config_default => qw/is ro isa Maybe[HashRef]/;
has manifest => qw/is ro isa Framework::Redmash::Manifest/, default => sub {
    return Framework::Redmash::Manifest->new;
};

1;
