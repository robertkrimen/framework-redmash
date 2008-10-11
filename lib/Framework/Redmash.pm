package Framework::Redmash;

use warnings;
use strict;

=head1 NAME

Framework::Redmash -

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use MooseX::ClassScaffold;

Scaffold->setup_scaffolding_import;

use Framework::Redmash::Meta;

sub SCAFFOLD {
    my $self = shift;
    my $meta = shift;

    Scaffold->extends($meta => 'Framework::Redmash::Object');
    Scaffold->class_has($meta => redmash_meta => qw/is ro isa Framework::Redmash::Meta/, default => sub {
        return Framework::Redmash::Meta->new(kit_class => $meta->name);
    });

    $meta->name->redmash_meta->configure(@_);
#    my $redmash_meta = shift;
#    my %given = @_;

#    $redmash_meta->config_default($given{config_default}) if $given{config_default};
}

__END__
#use MooseX::ClassAttribute();
#use Moose::Exporter;
#my ($import, $export) = Moose::Exporter->build_import_methods(
#    with_caller => [],
#);

#sub import {
#    my $CALLER = Moose::Exporter::_get_caller(@_);
#    my $self = shift;
#    my $class = __PACKAGE__;

#    if ( $CALLER eq 'main' ) {
#        warn
#            qq{$class does not export its sugar to the 'main' package.\n};
#        return;
#    }

#    $class->setup_class($CALLER, @_);

#    @_ = ($_[0]);
#    goto $import;
#}

#sub init_meta {
#    # Empty for a reason (setup_class does the work)
#}

#sub setup_class {
#    my $self = shift;
#    my $for_class = shift;
#    my %given = @_;

#    Moose->init_meta(for_class => $for_class);

#    Moose::Util::MetaRole::apply_metaclass_roles(
#        for_class => $for_class,
#        metaclass_roles => [ 'MooseX::ClassAttribute::Role::Meta::Class' ],
#    );
#    Class::MOP::Class
#            ->initialize($for_class)
#            ->add_class_attribute(
#                redmash_meta => qw/is ro isa Framework::Redmash::Meta/, default => sub {
#                    return Framework::Redmash::Meta->new(for_class => $for_class);
#                },
#            );

#    $for_class->redmash_meta->initialize(@_);
#}

#my ($import, $export) = Moose::Exporter->setup_import_methods;
my ($import, $export) = Moose::Exporter->build_import_methods;

sub import {
    my $for_class = Moose::Exporter::_get_caller(@_);

#    my $class = shift;
#    warn $class;
warn $for_class;
    goto &$import;
    die;
}

*unimport = $export;

sub init_meta {
    my $self = shift;
    warn "@_";
    return Moose->init_meta( @_, baseclass => 'Framework::Redmash::Object' );
}


=head1 SYNOPSIS


=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

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
