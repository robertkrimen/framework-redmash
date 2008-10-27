package Framework::Redmash::Render::TT;

use Framework::Redmash::Carp;
use Framework::Redmash::Types;

my $map_path_to_tt = sub {
    my $context = shift;
    my $path = $context->path;
    $path =~ s/^\///;
    if ($path eq '' || $path =~ m/\/$/) {
        for my $include_path ($context->kit->tt->include_path) {
            for (qw/ index.tt.html home.tt.html /) {
                my $tt = "$include_path/$path$_";
                return "$path$_" if -f $tt;
            }
        }
        croak "Unable to find tt file for path $path";
    }
    elsif ($path =~ s/(\.\w{1,4})$/.tt$1/) {
    }
    else {
        $path .= '.tt.html';
    }
    return $path;
};

my $map_context_to_input = sub {
    my $context = shift;
    my $arguments = shift;
    return $context->stash->{template_input} if $context->stash->{template_input};
    return $context->stash->{template} if $context->stash->{template};
    return $arguments->{template_input} if $arguments->{template_input};
    return $arguments->{template} if $arguments->{template};
    return $map_path_to_tt->($context);
};

my $map_context_to_output = sub {
    my $context = shift;
    my $arguments = shift;
    return $context->stash->{template_output} if $context->stash->{template_output};
    return $arguments->{template_output} if $arguments->{template_output};
    my $path = $map_path_to_tt->($context);
    $path =~ s/\.tt(\.\w{1,4})$/$1/;
    return $context->kit->rsc->child($path);
};

sub render {
    my $self = shift;
    my $context = shift;
    my $arguments = shift || {};

    if (ref $arguments eq '') {
        $arguments = { template_input => $arguments };
    }

    my $input = $map_context_to_input->($context, $arguments);
    my $output = $map_context_to_output->($context, $arguments);

    my $file;
    if ($output->can('file')) {
        $file = $output->file;
    }
    elsif ($output->isa('Path::Class::File')) {
        $file = $output
    }

    if ($file && -f $file || -s _) {
        return $output unless $context->kit->testing;
    }

    $context->kit->tt->process(
        input => $input,
        context => { context => $context, %{ $context->stash } },
        output => $output
    );

    return $output;
}

1;
