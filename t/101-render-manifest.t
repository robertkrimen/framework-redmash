#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

use Framework::Redmash::Manifest::Render;

plan qw/no_plan/;

{
    my $manifest = Framework::Redmash::Manifest::Render->new;
    $manifest->include(<<_END_);
    # Skip this line
/

    /this.html

# Previous line should be skipped
/this     # This is a comment for /this
/that/#Comment with no gap

/comment-and-content comment-and-content.tt.html # This is the comment
/just-content just-content.tt.html
_END_

    for (qw(
        /
        /this.html
        /this
        /that/
        /comment-and-content
        /just-content
    )) {
        ok($manifest->entry->{$_});
        is($manifest->entry->{$_}->path, $_);
    }

    is($manifest->entry->{'/this'}->comment, 'This is a comment for /this');
    is($manifest->entry->{'/that/'}->comment, 'Comment with no gap');
    is($manifest->entry->{'/comment-and-content'}->comment, 'This is the comment');

    is($manifest->entry->{'/comment-and-content'}->content, 'comment-and-content.tt.html');
    is($manifest->entry->{'/just-content'}->content, 'just-content.tt.html');

#    $manifest->include(
#        'assets/root/static/css/example.css' => {
#            content => '/* Some css */',
#        },
#        'assets/tmp',
#        'assets/root/static/js/example.js' => {
#            comment => 'This is a .js file',
#        },
#    );

#    ok($manifest->file->{'assets/tmp'});
#    is($manifest->file->{'assets/tmp'}->path, 'assets/tmp');

#    is($manifest->file->{'assets/root/static/css/example.css'}->content, '/* Some css */');
#    is($manifest->file->{'assets/root/static/js/example.js'}->comment, 'This is a .js file');

}
