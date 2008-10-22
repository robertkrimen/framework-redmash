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

sub ok_render {
    my $path = shift;
    ok(my $rsc = $kit->render($path));
    ok(-s $rsc->file);
    is(scalar $rsc->file->slurp, "$path\n");
}

ok_render('/');
ok_render('a');
ok_render('/b');
ok_render('c.html');
ok_render('d/');
ok_render('/e/');

is(scalar $kit->render(<<_END_), 6);
# Ignore this ...
/
a
    # ... and this
/b
c
    d/
/e/
_END_

$kit->config->{testing} = 0;

my $rsc = $kit->render('a');
my $mtime = $rsc->file->stat->mtime;

sleep 1.5;

$rsc = $kit->render('a');
is($rsc->file->stat->mtime, $mtime);

$kit->config->{testing} = 1;

$rsc = $kit->render('a');
isnt($rsc->file->stat->mtime, $mtime);

__END__

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

