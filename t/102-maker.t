#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use t::Test::Project;

my $kit = t::Test::Project->new;

my $object;
ok($object = $kit->make('Alpha'));
ok($object->isa('t::Test::Project::Alpha')); 
ok($object = $kit->make('Beta'));
ok($object->isa('t::Test::Project::Beta')); 
