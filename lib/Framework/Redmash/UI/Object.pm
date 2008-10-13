package Framework::Redmash::UI::Object;

use Moose;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

with qw/Framework::Redmash::Component/;

use URI::PathAbstract;
use Template;

sub build_tt {
    my $self = shift;
    return {
        INCLUDE_PATH => [ $self->kit->assets_tt_dir."" ],
    };
}

# build_tt_context ..
sub tt_context {
}

# build_tt_sticky_context ..

sub rsc {
    return $_[0]->kit->rsc;
}

sub uri {
    my $self = shift;
    my $uri = $self->kit->uri;
    return $uri->clone unless @_;

    my @path = @_;
    my $query;
    $query = pop @path if ref $path[-1] eq "ARRAY" || ref $path[-1] eq "HASH";
    $uri = $uri->child(@path);
    $uri->query_form($query) if $query;
    return $uri;
}

sub href {
    my $self = shift;
    # TODO Escaping?
    my $uri = $self->uri(@_);
    return qq/href="$uri"/;
}

sub src {
    my $self = shift;
    # TODO Escaping?
    my $uri = $self->uri(@_);
    return qq/src="$uri"/;
}

has tt => qw/is ro lazy_build 1 isa Template/;
sub _build_tt {
    my $self = shift;
    my $method = "build_tt";
    croak "Don't have method \"$method\"" unless my $build = $self->can($method);
    my $got = $build->($self, @_);

    return $got if blessed $got && $got->isa("Template");
    return Template->new($got) if ref $got eq "HASH";
    return Template->new unless $got;

    croak "Don't know how to build Template with $got";
}

sub process_tt {
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
        $context = $self->_tt_context($given{context}, @_);
    }

    if ($given{process}) {
        @process = @{ $given{process} };
    }
    else {
        @process = qw/binmode :utf8/;
    }

    my $tt = $self->tt;
    $tt->process($input, $context, $output, @process) or croak "Couldn't process $input => $output: ", $tt->error;

    return $$output unless exists $given{output};

    return $output if ref $output eq "SCALAR";
}

has tt_context_sticky => qw/is ro isa HashRef lazy_build 1/;
sub _build_tt_context_sticky {
    my $self = shift;
    return {
        uri_for => sub { return $self->uri(@_) },
        uri => sub { return $self->uri(@_) },
        href => sub { return $self->href(@_) },
        src => sub { return $self->src(@_) },
    };
}

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

sub _tt_context {
    my $self = shift;
    my $context = shift || {};

    {
        my $sticky = $self->tt_context_sticky;
        $context->{ui} ||= $self;
        $context->{$_} = $sticky->{$_} for keys %{ $sticky };
    }

    my @context = $self->tt_context($context, @_);
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
1;
