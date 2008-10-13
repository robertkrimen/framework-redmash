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

my $name = t::Test::Project->redmash_meta->name;

ok(-e $scratch->file("run"));
ok(-e $scratch->file("assets/root/static/css"));
ok(-e $scratch->file("assets/root/static/js"));
ok(-s $scratch->file("assets/root/static/css/$name.css"));
ok(-s $scratch->file("assets/tt/frame.tt.html"));

run(qw/about t::Test::Project/);
