#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Framework::Redmash' );
}

diag( "Testing Framework::Redmash $Framework::Redmash::VERSION, Perl $], $^X" );
