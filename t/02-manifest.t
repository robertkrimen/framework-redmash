#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

use Framework::Redmash::Manifest;

plan qw/no_plan/;

ok(1);

{
    my $manifest = Framework::Redmash::Manifest->new;
    $manifest->include(<<_END_);
    # Skip this line
run
run/root

# Previous line should be skipped
run/tmp
assets
assets/root     # This is a comment for assets/root
    assets/root/static
assets/root/static/css
assets/root/static/js#Comment with no gap
_END_

    for (qw(
        run
        run/root
        run/tmp
        assets
        assets/root
        assets/root/static
        assets/root/static/css
        assets/root/static/js
    )) {
        ok($manifest->file->{$_});
        is($manifest->file->{$_}->path, $_);
    }

    is($manifest->file->{'assets/root'}->comment, 'This is a comment for assets/root');
    is($manifest->file->{'assets/root/static/js'}->comment, 'Comment with no gap');

    $manifest->include(
        'assets/root/static/css/example.css' => {
            content => '/* Some css */',
        },
        'assets/tmp',
        'assets/root/static/js/example.js' => {
            comment => 'This is a .js file',
        },
    );

    ok($manifest->file->{'assets/tmp'});
    is($manifest->file->{'assets/tmp'}->path, 'assets/tmp');

    is($manifest->file->{'assets/root/static/css/example.css'}->content, '/* Some css */');
    is($manifest->file->{'assets/root/static/js/example.js'}->comment, 'This is a .js file');
}
