package Framework::Redmash::UI;

use warnings;
use strict;

use MooseX::Scaffold;
MooseX::Scaffold->setup_scaffolding_import;

sub SCAFFOLD {
    my $class = shift;
    my %given = @_;

    my $kit_class = MooseX::Scaffold->repackage($class->name, undef, 1);

    $class->extends('Framework::Redmash::UI::Object');
    $class->has(kit => qw/is ro required 1/, isa => $kit_class);

    $class->meta->add_method($kit_class->redmash_meta->name => sub {
        return $_[0]->kit;
    });

#    my $redmash_meta = shift;
#    my %given = @_;

#    $redmash_meta->config_default($given{config_default}) if $given{config_default};
}

