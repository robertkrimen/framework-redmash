package Framework::Redmash::Types::Types;

use strict;
use warnings;

use strict;
use warnings qw/FATAL all/;

use MooseX::Types -declare => [qw//];
use MooseX::Types::Moose qw/Object Int Str Num/;
use MooseX::Types::Path::Class qw/File/;
use Scalar::Util qw/looks_like_number/;

subtype 'Path::Resource' => as Object => where { $_->isa('Path::Resource') };

coerce File, from 'Path::Resource', via { $_->file };

package Framework::Redmash::Types;

use strict;
use warnings;

use Class::MOP;

#use MooseX::Types;
#use MooseX::Types::Path::Class qw/:all/;

sub import {

    for my $types_class (qw/
        MooseX::Types::Path::Class
        MooseX::Types::Moose
        MooseX::Types::UUID
    /) {

        Class::MOP::load_class($types_class);
        $types_class->import(qw/:all/, { -into => scalar(caller) });
    }

    return 1;
}

1;
