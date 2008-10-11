package Framework::Redmash::Meta;

use Moose;

use Framework::Redmash::Carp;
use Framework::Redmash::Types;

use Framework::Redmash::Manifest;

has kit_class => qw/is ro required 1 isa Str/;
sub kit_meta {
    return shift->kit_class->meta;
}

has base => qw/is rw isa Str/;
has base_class => qw/is rw isa Str/;

has name => qw/is rw isa Str/;

has config_default => qw/is ro isa Maybe[HashRef]/;
has manifest => qw/is ro isa Framework::Redmash::Manifest/, default => sub {
    return Framework::Redmash::Manifest->new;
};

sub configure {
    my $self = shift;
    my %given = @_;

    my $kit_class = $self->kit_class;

    my $name = $given{name} or croak "Wasn't given name (when creating $kit_class)";
    $self->name($name);

    my $base = $given{base} ||= 'Standard';
    $self->base($base);
    my $base_class = "Framework::Redmash::Base::$base";
    $self->base_class($base_class);

    # Should extend from base class object class (::Object)
    # $self->for_class->meta->superclasses($base_class);

    MooseX::ClassScaffold->load_class($base_class);
    $base_class->configure($self, \%given);

    $self->config_default($given{config_default}) if $given{config_default};

    if (my $manifest = $given{manifest}) {
        my @manifest = ref $manifest eq 'ARRAY' ? @$manifest : ($manifest);
        $self->manifest->include(@manifest);
    }

    $self->finalize;
}

sub finalize {
    my $self = shift;

    $self->finalize_config_default;

    $self->finalize_manifest;
}

sub finalize_config_default {
    my $self = shift;
    
    return unless my $config_default = $self->config_default;

    my $code;
    if (ref $config_default eq "CODE") {
        $code = $config_default;
    }
    elsif (ref $config_default eq "HASH") {
        $code = sub { return $config_default };
    }
    else {
        croak "Don't understand config default $config_default";
    }

    $self->kit_meta->override(_build_config_default => $code);
}

sub finalize_manifest {
    my $self = shift;

    my $meta = $self->kit_meta;
    my $class = $self->kit_class;

    $self->manifest->each(sub {
        my $file = shift;
        my $path = $file->path;
        my @path = split m/\//, $path;
        my $last_dir = pop @path;

        my $dir = join "_", @path, $last_dir;
        my $parent_dir = @path ? join "_", @path : qw/home/;

        my $dir_method = "${dir}_dir";
        my $parent_dir_method = "${parent_dir}_dir";
        $dir_method =~ s/\W/_/g;
        $parent_dir_method =~ s/\W/_/g;

        next if $class->can($dir_method);

        $meta->add_attribute($dir_method => qw/is rw required 1 coerce 1 lazy 1/, isa => Dir, default => sub {
            return shift->$parent_dir_method->subdir($last_dir);
        }, @_);
    });
}

#sub _setup_kit_dir {
#    my $self = shift;
#    my $class = shift;
#    my $manifest = shift;

#    for my $path (sort grep { ! /^\s*#/ } split m/\n/, $manifest) {
#        my @path = split m/\//, $path;
#        my $last_dir = pop @path;

#        my $dir = join "_", @path, $last_dir;
#        my $parent_dir = @path ? join "_", @path : qw/home/;

#        my $dir_method = "${dir}_dir";
#        my $parent_dir_method = "${parent_dir}_dir";
#        $dir_method =~ s/\W/_/g;
#        $parent_dir_method =~ s/\W/_/g;

#        next if $class->can($dir_method);

#        $class->meta->add_attribute($dir_method => qw/is rw required 1 coerce 1 lazy 1/, isa => Dir, default => sub {
#            return shift->$parent_dir_method->subdir($last_dir);
#        }, @_);
#    }
#}

1;
