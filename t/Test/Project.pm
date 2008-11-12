package t::Test::Project;

use strict;
use warnings;

use Moose;
use Framework::Redmash qw/name test/;

#__PACKAGE__->redmash_meta->configure->render->add(name => 'home');

sub build {
    my $self = shift;
    $self->rsc->dir->mkpath;
    $self->rsc->file( 'built' )->touch;
}

package t::Test::Project::Alpha;

use Moose;

1;
