#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;
use Directory::Scratch;

plan qw/no_plan/;

use t::Test::Project;

my $kit = t::Test::Project->new;
my $scratch = Directory::Scratch->new;
$kit->assets_dir('t/assets');
$kit->run_dir($scratch->base);

ok(! -e $scratch->file("root/built"));
$kit->build;
ok(-e $scratch->file("root/built"));

