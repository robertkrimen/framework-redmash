#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

ok(1);

package t::Project;

use Test::More;

use Moose;
use Framework::Redmash (
    qw/base Standard name test/
);

__PACKAGE__->redmash_meta->configure->render->add(name => 'index');
__PACKAGE__->redmash_meta->configure->render->add(name => 'home');

ok(__PACKAGE__->redmash_meta);
ok(__PACKAGE__->redmash_meta->isa("Framework::Redmash::Meta"));
#ok(__PACKAGE__->isa("Framework::Redmash::Base::Standard"));

package main;

my $kit = t::Project->new;
$kit->ui;

ok($kit->can(qw/assets_dir/));

ok($kit->configuration);
my @list;
$kit->configuration->render->each(sub {
    my $action = shift;
    push @list, $action->name;
});
cmp_deeply(\@list, [ qw/index home/ ]);

1;
