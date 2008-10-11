package Framework::Redmash::Manifest;

use Moose;

has _files => qw/is ro required 1/, default => sub { {} };

sub _file {
    my $self = shift;
    return $_[0] if @_ == 1 && blessed $_[0];
    return Framework::Redmash::Manifest::File->new(@_);
}

sub files {
    return shift->_files;
}

sub file {
    my $self = shift;
    return $self->_files unless @_;
    my $path = shift;
    return $self->_files->{$path};
}

sub add {
    my $self = shift;
    my $file = $self->_file(@_);
    $self->_files->{$file->path} = $file;
}

sub each {
    my $self = shift;
    my $code = shift;

    for (sort keys %{ $self->_files }) {
        $code->($self->file->{$_})
    }
}

sub include {
    my $self = shift;

    while (@_) {
        local $_ = shift;
        if ($_ =~ m/\n/) {
            $self->_include_list($_);
        }
        else {
            my $path = $_;
            my %file;
            %file = %{ shift() } if ref $_[0] eq 'HASH';
            $self->add(path => $_ => %file);
        }
    }
}

sub _include_list {
    my $self = shift;
    my $list = shift;

    for (split m/\n/, $list) {
        chomp;
        next if m/^\s*$/ || m/^\s*#/;
        my ($path, $comment) = m/^([^#]+)(?:\s*#\s*(.*))?$/;
        s/^\s*//, s/\s*$// for $path;
        $self->add(path => $path, comment => $comment);
    }
}

package Framework::Redmash::Manifest::File;

use Moose;

has path => qw/is ro required 1/;
has comment => qw/is ro isa Maybe[Str]/;
has content => qw/is ro isa Maybe[Str]/;

1;
