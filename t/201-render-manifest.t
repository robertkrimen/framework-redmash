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

$kit->render_manifest->include(<<_END_);
    # Skip this line
/

    /this.html

# Previous line should be skipped
/this     # This is a comment for /this
/that/#Comment with no gap

/comment-and-content comment-and-content.tt.html # This is the comment
/just-content just-content.tt.html
_END_

$kit->render;

sub ok_render {
    my $path = shift;
    ok(my $rsc = $kit->rsc->child($path));
    ok(-f $rsc->file, $rsc->file . " does not exist");
}

ok_render('home.html');
ok_render('this.html');
ok_render('that/index.html');
ok_render('comment-and-content.html');
ok_render('just-content.html');



#ok_render('/');
#ok_render('a');
#ok_render('/b');
#ok_render('c.html');
#ok_render('d/');
#ok_render('/e/');

#is(scalar $kit->render(<<_END_), 6);
## Ignore this ...
#/
#a
#    # ... and this
#/b
#c
#    d/
#/e/
#_END_

#$kit->config->{testing} = 0;

#my $rsc = $kit->render('a');
#my $mtime = $rsc->file->stat->mtime;

#sleep 1.5;

#$rsc = $kit->render('a');
#is($rsc->file->stat->mtime, $mtime);

#$kit->config->{testing} = 1;

#$rsc = $kit->render('a');
#isnt($rsc->file->stat->mtime, $mtime);

#{
#    $kit->render_manifest->add(path => '/', content => 'other.tt.html');
#    $rsc = $kit->render('/');
#    is(scalar $rsc->file->slurp, "This is the other template\n");
#}
