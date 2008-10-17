package Framework::Redmash;

use warnings;
use strict;

=head1 NAME

Framework::Redmash - Framework for quickly setting up a webpage/website using Template Toolkit

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    package MyProject;

    use Framework::Redmash name => 'myproject';

    # Then, from the commandline ...
    
    redmash setup
    redmash about

=head1 DESCRIPTION

This is beta!

Framework::Redmash is an attempt to take the drudgery out of setting up a website. After you run 'setup' you should have
a basic assets/ directory, including a standard frame .tt and some baseline .css

=cut

use MooseX::Scaffold;
MooseX::Scaffold->setup_scaffolding_import;

use Framework::Redmash::Meta;

sub SCAFFOLD {
    my $class = shift;

    $class->extends('Framework::Redmash::Object');

    $class->class_has(redmash_meta => qw/is ro isa Framework::Redmash::Meta/, default => sub {
        return Framework::Redmash::Meta->new(kit_class => $class->name);
    });

    $class->name->redmash_meta->bootstrap(@_);
}

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 SOURCE

You can contribute or fork this project via GitHub:

L<http://github.com/robertkrimen/PCK/tree/master>

    git clone git://github.com/robertkrimen/PCK.git PCK

=head1 BUGS

Please report any bugs or feature requests to C<bug-framework-redmash at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Framework-Redmash>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Framework::Redmash


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Framework-Redmash>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Framework-Redmash>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Framework-Redmash>

=item * Search CPAN

L<http://search.cpan.org/dist/Framework-Redmash>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Framework::Redmash
