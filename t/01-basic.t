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
    qw/base Standard/
);

ok(__PACKAGE__->redmash_meta);
ok(__PACKAGE__->redmash_meta->isa("Framework::Redmash::Meta"));
#ok(__PACKAGE__->isa("Framework::Redmash::Base::Standard"));

package main;

my $kit = t::Project->new;
$kit->ui;

ok($kit->can(qw/assets_dir/));

1;
