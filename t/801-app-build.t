#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

use Framework::Redmash::App;
use Directory::Scratch;

plan qw/no_plan/;

my $scratch = Directory::Scratch->new;
my (@abort, @report);

sub run {
    Framework::Redmash::App->run({
        home => $scratch->base,
        abort => sub {
            push @abort, join '', @_;
            diag '! ', $abort[-1];
        },
        report => sub {
            push @report, join '', @_;
            diag $report[-1];
        },
    }, @_);
}

run(qw/setup t::Test::Project/);
ok(! -e $scratch->file("run/root/built"));
run(qw/build/);
ok(-e $scratch->file("run/root/built"));
