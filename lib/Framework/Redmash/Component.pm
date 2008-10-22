package Framework::Redmash::Component;

use Moose::Role;

has kit => qw/is ro required 1 isa Framework::Redmash::Kit/;

1;
