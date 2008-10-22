package Framework::Redmash::Maker;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

use MooseX::Scaffold;
use Class::Inspector;

has redmash_meta => qw/is ro required 1 isa Framework::Redmash::Meta/;
has make_map => qw/is ro required 1 isa HashRef/, default => sub { {} };

sub make {
    my $self = shift;
    my $target = shift;
    return $self->maker($target)->(@_);
}

sub maker {
    my $self = shift;
    my $target = shift;

    if (@_) {
        $self->make_map->{$target} = shift;
    }
    else {
        my $maker = $self->make_map->{$target};
        return $maker if ref $maker eq 'CODE';

        unless ($maker) {
            my $package = $target;
            if ($package =~ s/^\+//) {
                $maker = $package;
            }
            else {
                for ($self->_kit_package($package), $self->_redmash_package($package)) {
                    if ($self->_available($_)) {
                        $maker = $_;
                        last;
                    }
                }
            }
            croak "Unable to find maker for $package" unless $maker;
        }

        return $self->make_map->{$target} = sub {
            return $maker->new(@_);
        };
    }
}

sub _available {
    my $self = shift;
    my $package = shift;

    return 1 if Class::Inspector->loaded($package);
    if (Class::Inspector->installed($package)) {
        eval "require $package;";
        die $@ if $@;
        return 1;
    }
    return 0;
}

sub _kit_package {
    my $self = shift;
    my $package = shift;

    my $kit_class = $self->redmash_meta->kit_class;
    return "${kit_class}::${package}";
}

sub _redmash_package {
    my $self = shift;
    my $package = shift;
    return "Framework::Redmash::${package}";
}

1;
