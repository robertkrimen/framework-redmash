package Framework::Redmash::UI;

use warnings;
use strict;

use MooseX::ClassScaffold;

Scaffold->setup_scaffolding_import;

sub SCAFFOLD {
    my $self = shift;
    my $meta = shift;
    my %given = @_;

    my $kit_class = Scaffold->repackage($meta->name, undef, 1);

    Scaffold->extends($meta => 'Framework::Redmash::UI::Object');
    Scaffold->has($meta => kit => qw/is ro required 1/, isa => $kit_class);

#    my $redmash_meta = shift;
#    my %given = @_;

#    $redmash_meta->config_default($given{config_default}) if $given{config_default};
}

