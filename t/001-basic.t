#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

package t::Project;

use Test::More;

use Moose;
use MooseX::ClassAttribute;
use Framework::Redmash (
    qw/plugin Standard name test/
);

ok(__PACKAGE__->redmash_meta);
ok(__PACKAGE__->redmash_meta->isa("Framework::Redmash::Meta"));

package main;

my $kit = t::Project->new;

ok($kit->interface);
ok($kit->can(qw/assets_dir/));
ok($kit->configure);

1;
