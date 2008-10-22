package Framework::Redmash::TT;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

with qw/Framework::Redmash::Component/;

use URI::PathAbstract;
use Template;

sub include_path {
    my $self = shift;
    return $self->kit->assets_tt_dir."",
}

sub build_engine {
    my $self = shift;
    return {
        INCLUDE_PATH => [ $self->include_path ],
    };
}

# build_context ..
sub context {
}

# build_sticky_context ..

has engine => qw/is ro lazy_build 1 isa Template/;
sub _build_engine {
    my $self = shift;
    my $method = "build_engine";
    croak "Don't have method \"$method\"" unless my $build = $self->can($method);
    my $got = $build->($self, @_);

    return $got if blessed $got && $got->isa("Template");
    return Template->new($got) if ref $got eq "HASH";
    return Template->new unless $got;

    croak "Don't know how to build Template with $got";
}

sub process {
    my $self = shift;
    my %given = @_;

    my ($input, $output, $context, @process);

    {
        $input = $given{template} || $given{input};
        croak "Wasn't given a template" unless defined $input;
    }

    {
        $output = $given{output};
        my $output_content;
        $output = \$output_content unless exists $given{output};

        if (blessed $output) {
            if ($output->isa("Path::Resource")) {
                $output = $output->file;
            }
            if ($output->isa("Path::Class::File")) {
                $output = "$output";
            }
        }

        if (defined $output && ! ref $output) {
            $output = Path::Class::File->new($output);
            $output->parent->mkpath unless -d $output->parent;
            $output = "$output";
        }
    }

    {
        $context = $self->_context($given{context}, @_);
    }

    if ($given{process}) {
        @process = @{ $given{process} };
    }
    else {
        @process = qw/binmode :utf8/;
    }

    my $engine = $self->engine;
    $engine->process($input, $context, $output, @process) or croak "Couldn't process $input => $output: ", $engine->error;

    return $$output unless exists $given{output};

    return $output if ref $output eq "SCALAR";
}

has context_sticky => qw/is ro isa HashRef lazy_build 1/;
sub _build_context_sticky {
    my $self = shift;
    return {
        uri_for => sub { return $self->kit->interface->uri(@_) },
        uri => sub { return $self->kit->interface->uri(@_) },
        href => sub { return $self->kit->interface->href(@_) },
        src => sub { return $self->kit->interface->src(@_) },
    };
}

sub _context {
    my $self = shift;
    my $context = shift || {};

    {
        my $sticky = $self->context_sticky;
        $context->{ui} ||= $self;
        $context->{$_} = $sticky->{$_} for keys %{ $sticky };
    }

    my @context = $self->context($context, @_);
    if (1 == @context && ref $context[0] eq "HASH") {
        return $context[0];
    }
    elsif (0 == (@context % 2)) {
        my %context = @context;
        $context->{$_} = $context{$_} for keys %context;
    }
    elsif (@context) {
        croak "Don't know what to do with (@context)";
    }

    return $context;
}

1;

__END__

sub _render_page {
    my $self = shift;
    my %given = @_;

    $given{force} = 1 if ! exists $given{force} && $self->kit->testing;

    my $input = $given{template} || $given{input} or croak "Wasn't given a template";
    my $context = $given{context} || {};

    return $self->_render_rsc(%given, build => sub {
        my $rsc = shift;
        $self->process_tt(input => $input, output => $rsc, context => $context);
    });
}

sub _render_rsc {
    my $self = shift;
    my %given = @_;

    my $rsc = $given{rsc} or croak "Wasn't given resource";
    $rsc = $self->kit->rsc->child($rsc) unless blessed $rsc;
    my $build = $given{build} or croak "Wasn't given build CODE";

    if ($given{force} || ! -f $rsc->file || ! -s _) {
        $build->($rsc);
    }

    return $rsc;
}

