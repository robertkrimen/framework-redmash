package Framework::Redmash::Meta;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

use Framework::Redmash::Configure::Meta;
use Framework::Redmash::Maker;

has kit_class => qw/is ro required 1 isa Str/;
sub kit_meta {
    return shift->kit_class->meta;
}

has base => qw/is rw isa Str/;
has base_class => qw/is rw isa Str/;

has configure => qw/is ro lazy_build 1/, handles => [qw/ config_default /];
sub _build_configure {
    my $self = shift;
    return Framework::Redmash::Configure::Meta->new(redmash_meta => $self);
}

has name => qw/is rw isa Str/;

has setup_manifest => qw/is ro isa Framework::Redmash::Manifest::Setup/, default => sub {
    return Framework::Redmash::Manifest::Setup->new;
};

sub BUILD_kit {
    my $self = shift;
    my $kit = shift;
    $self->setup_manifest->copy_into($kit->setup_manifest);
    for my $builder ($self->configure->build_list) {
        $builder->($kit, $kit->configure);
    }
}

sub bootstrap {
    my $self = shift;
    my %given = @_;

    my $kit_class = $self->kit_class;

    my $name = $given{name} or croak "Wasn't given name (when creating $kit_class)";
    $self->configure->name($name);

    my $base = $given{base} ||= 'Standard';
    $self->base($base);
    my $base_class = "Framework::Redmash::Base::$base";
    $self->base_class($base_class);

    # Should extend from base class object class (::Object)
    # $self->for_class->meta->superclasses($base_class);

    MooseX::Scaffold->load_class($base_class);
    $base_class->initialize($self->configure, $self, \%given);

    $self->initialize($self->configure, $self, \%given);

    $self->finalize;
}

sub initialize {
    my $self = shift;
    my $configure = shift;
    my $redmash_meta = shift;
    my $given = shift;

    $configure->config_default($given->{config_default}) if $given->{config_default};

    if (my $setup_manifest = $given->{setup_manifest}) {
        my @setup_manifest = ref $setup_manifest eq 'ARRAY' ? @$setup_manifest : ($setup_manifest);
        $configure->setup_manifest->include(@setup_manifest);
    }
}

sub finalize {
    my $self = shift;

    $self->finalize_config_default;

    $self->finalize_setup_manifest;
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

sub finalize_setup_manifest {
    my $self = shift;

    my $meta = $self->kit_meta;
    my $class = $self->kit_class;

    $self->setup_manifest->each(sub {
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
