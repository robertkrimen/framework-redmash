package Framework::Redmash::Kit;

use Moose;
use MooseX::ClassAttribute;
use Framework::Redmash::Carp;
use Framework::Redmash::Types;

use Framework::Redmash::Manifest::Setup;
use Framework::Redmash::Manifest::Render;
use Framework::Redmash::TT;
use Framework::Redmash::Context;
use Framework::Redmash::Render::TT;

use Config::JFDI;
use File::Copy;
use Path::Resource;
use File::Spec::Link;
use File::Find;
use Path::Class;
use MooseX::ClassAttribute();
use Class::Inspector;
use MooseX::Scaffold;
use Path::Finder;
use Text::FixEOL;
my $fixer = Text::FixEOL->new;

sub BUILD {
    my $self = shift;
    $self->redmash_meta->BUILD_kit($self);
}

has configure => qw/is ro lazy_build 1 isa Framework::Redmash::Configure::Kit/;
sub _build_configure {
    my $self = shift;
    return $self->make('Configure::Kit', kit => $self);
}

has setup_manifest => qw/is ro isa Framework::Redmash::Manifest::Setup/, default => sub {
    return Framework::Redmash::Manifest::Setup->new;
};

has render_manifest => qw/is ro isa Framework::Redmash::Manifest::Render/, default => sub {
    return Framework::Redmash::Manifest::Render->new;
};

has home_dir => qw/is ro coerce 1 lazy_build 1/, isa => Dir;
sub _build_home_dir {
    return Path::Class::Dir->new("./")->absolute;
}

has config_default => qw/is ro lazy_build 1/;
sub _build_config_default {
    return {};
}

has _config => qw/is ro lazy_build 1 isa Config::JFDI/;
sub _build__config {
    my $self = shift;
    return Config::JFDI->new(path => $self->home_dir."", name => $self->redmash_meta->name);
};
sub config {
    return shift->_config->get;
}
sub cfg {
    return shift->config;
}

sub testing {
    return shift->config->{testing} ? 1 : 0;
}

has rsc => qw/is ro lazy_build 1 isa Path::Resource/;
sub _build_rsc {
    my $self = shift;
    return Path::Resource->new(uri => $self->uri, dir => $self->run_root_dir);
}

# build_rsc { ... (Should return a hash or something)

has uri => qw/is ro lazy_build 1 isa URI::PathAbstract/;
sub _build_uri {
    my $self = shift;
    my $method = "build_uri";
    croak "Don't have method \"$method\"" unless my $build = $self->can($method);
    my $got = $build->($self, @_);

    return $got if blessed $got && $got->isa("URI::PathAbstract");
    return URI::PathAbstract->new($got);
}

sub build_uri {
    return $_[0]->cfg->{uri};
}

has tt => qw/is ro lazy_build 1 isa Framework::Redmash::TT/;
sub _build_tt {
    my $self = shift;
    return $self->make('TT', kit => $self);
}

has interface => qw/is ro lazy_build 1 isa Framework::Redmash::Interface/;
sub _build_interface {
    my $self = shift;
    return $self->make('Interface', kit => $self);
}

has finder => qw/is ro lazy_build 1 isa Path::Finder/;
sub _build_finder {
    my $self = shift;
    return Path::Finder->new;
}

sub publish_dir {
    my $self = shift;
    if (1 == @_) {
        return $self->publish_dir(from_dir => shift, to_dir => $self->run_root_dir, @_);
    }
    my %given = @_;

    my $from_dir = $given{from_dir} || $given{from} or croak "Wasn't given a dir to copy from";
    my $to_dir = $given{to_dir} || $given{to} or croak "Wasn't given a dir (or path) to copy to";
    my $copy = $given{copy};
    my $skip = $given{skip} || qr/^(?:\.svn|.git|CVS|RCS|SCCS)$/;

    find { no_chdir => 1, wanted => sub {
        my $from = $_;
        if ($from =~ $skip) {
            $File::Find::prune = 1;
            return;
        }
        my $from_relative = substr $from, length $from_dir;
        my $to = "$to_dir/$from_relative";

        return if -e $to || -l $to;
        if (! -l $from && -d _) {
            dir($to)->mkpath;
        }
        else {
            if ($copy) {
                File::Copy::copy($from, $to) or warn "Couldn't copy($from, $to): $!";
            }
            else {
                my $from = File::Spec::Link->resolve($from) || $from;
                $from = file($from)->absolute;
                symlink $from, $to or warn "Couldn't symlink($from, $to): $!";
            }
        }
    } }, $from_dir;
}

sub publish {
    my $self = shift;
    if (1 == @_) {
        return $self->publish(from => shift, to => $self->run_root_dir, @_);
    }
    my %given = @_;

    my $from = $given{from} or croak "Wasn't given a path to copy from";
    my $to = $given{to} or croak "Wasn't given a path to copy to";
    my $copy = $given{copy};

    if (-f $from && -d $to) {
        croak "Given a file to copy ($from) but destination is a directory ($to)";
    }

    return $self->publish_dir(@_) unless -f $from;

    my $dir = file($to)->parent;
    $dir->mkpath unless -d $dir;

    if ($copy) {
        File::Copy::copy($from, $to) or warn "Couldn't copy($from, $to): $!";
    }
    else {
        return if -l $to;
        my $from = File::Spec::Link->resolve($from) || $from;
        $from = file($from)->absolute;
        symlink $from, $to or warn "Couldn't symlink($from, $to): $!";
    }
}

sub render {
    my $self = shift;

    if (@_ > 1) {
        $self->_render(@_);
    }
    else {

        if (! @_) {
            $self->render_manifest->each(sub {
                $self->render(shift->path);
            });
            return;
        }

        my $given = shift;

        if (ref $given eq 'ARRAY') {
            my @result;
            for (@$given) {
                push @result, $self->render($_);
            }
            return @result;
        }
        elsif ($given =~ m/\n/) {
            $given = $fixer->eol_to_unix($given);
            my @result;
            for (split m/\n/, $given) {
                chomp;
                next if m/^\s*$/ || m/^\s*#/;
                s/^\s*//, s/\s*$// for $_;
                push @result, $self->render($_);
            }
            return @result;
        }
        else {
            my $path = $given;

            my $context = Framework::Redmash::Context->new(kit => $self, path => $path);

            my $arguments;
            {
                if (my $entry = $self->render_manifest->entry($path)) {
                    $arguments = $entry->content if $entry->content;
                }
            }

            my $match = $self->finder->find($path);
            croak "Didn't find anything for path $path" unless $match;

            my $action = $match->slot('render')->first->content;

            if (ref $action eq 'CODE') {
                return $action->($context, $arguments);
            }
            elsif ($action eq 'render:TT') {
                return Framework::Redmash::Render::TT->render($context, $arguments);
            }
            else {
                croak "Don't understand action $action";
            }
        }
    }
}

sub _render {
    my $self = shift;
    my %given = @_;

    $given{force} = 1 if ! exists $given{force} && $self->testing;

    my $input = $given{template} || $given{input} or croak "Wasn't given a template";
    my $context = $given{context} || {};

    return $self->_render_rsc(%given, build => sub {
        my $rsc = shift;
        $self->tt->process(input => $input, output => $rsc, context => $context);
    });
}

sub _render_rsc {
    my $self = shift;
    my %given = @_;

    my $rsc = $given{rsc} or croak "Wasn't given resource";
    $rsc = $self->rsc->child($rsc) unless blessed $rsc;
    my $build = $given{build} or croak "Wasn't given build CODE";

    if ($given{force} || ! -f $rsc->file || ! -s _) {
        $build->($rsc);
    }

    return $rsc;
}

has _maker => qw/is ro lazy_build 1 isa Framework::Redmash::Maker/, handles => [qw/ make maker /];
sub _build__maker {
    my $self = shift;
    return Framework::Redmash::Maker->new(redmash_meta => $self->redmash_meta);
}

1;
