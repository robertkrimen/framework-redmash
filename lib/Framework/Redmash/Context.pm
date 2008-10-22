package Framework::Redmash::Context;

use strict;
use warnings;

use Moose;

has kit => qw/is ro required 1 isa Framework::Redmash::Kit/, handles => [qw/ interface /];
has path => qw/is ro required 1/;
has stash => qw/is ro lazy_build 1 isa HashRef/;
sub _build_stash {
    return {};
}

1;
